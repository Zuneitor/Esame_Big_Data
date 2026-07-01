# Database a Grafo (Neo4j) - Mobilità Urbana Tokyo (Persona 5)

Questa directory contiene gli script Cypher e l'architettura Python necessari per modellare, popolare e interrogare un database Neo4j dedicato alla **mobilità urbana della rete metropolitana di Tokyo**.

Il database a grafo rappresenta il modulo del progetto dedicato all'analisi topologica e spaziale. Il dominio applicativo è ispirato ai luoghi e alle dinamiche di spostamento del videogioco *Persona 5*, modellando le stazioni reali di Tokyo, le linee metropolitane e i punti di interesse (POI) chiave.

---

## Obiettivo dell'Infrastruttura a Grafo

A differenza dei classici database relazionali, Neo4j è stato impiegato per risolvere problemi computazionalmente complessi legati al routing e all'esplorazione spaziale. Il grafo risponde a domande analitiche avanzate, quali:

- Qual è il percorso topologico più breve (minor numero di hop) tra due fermate della metropolitana?
- Quanto tempo si trascorre effettivamente in viaggio, tenendo conto delle velocità medie delle singole linee?
- Qual è l'impatto in termini di tempo perso dovuto ai cambi di linea lungo un tragitto?
- Quali Punti di Interesse (POI) sono raggiungibili da una stazione di partenza, ponendo un vincolo massimo sul numero di cambi di treno consentiti?

---

## Struttura del Repository e Ordine di Esecuzione

Per garantire la riproducibilità del progetto, i file sono stati rigorosamente numerati in base all'ordine logico di esecuzione (Pipeline di Ingestione):

| File/Cartella | Funzione Architetturale |
|---|---|
| 📂 `records_nodi/` | Directory contenente i dataset CSV grezzi per l'ingestione massiva iniziale. |
| 📄 `00_reset_database.cypher` | Script di pulizia totale (Drop nodes, relationships, indexes). |
| 📄 `01_create_indexes.cypher` | Creazione indici per ottimizzare i tempi di attraversamento del grafo. |
| 📄 `02_import_nodes.md` | Documentazione della *Data Ingestion* massiva avvenuta tramite l'interfaccia nativa di Neo4j per ottimizzare i tempi di caricamento (Nodi `Fermata`, `Linea`, `PuntoInteresse`). |
| 📄 `03_create_relationships.cypher` | Script di generazione massiva dei collegamenti basato su costrutto `UNWIND` per elaborazione in batch. |
| 📄 `04_installazione_driver.md` | Istruzioni per l'impostazione dell'ambiente virtuale e requisiti. |
| 📄 `05_queries.cypher` | Logica Cypher pura delle interrogazioni, documentata e commentata. |
| 🐍 `query_mobilita_tokyo_neo4j.py` | Motore di esecuzione unificato in Python. |

---

## Modello del Grafo (Data Model)

Il dominio è strutturato su tre Nodi principali e due Relazioni chiave.

**Nodi Logici:**
* `(:Fermata)`: Stazioni della rete metropolitana e ferroviaria.
* `(:Linea)`: Linee di trasporto (es. Yamanote Line, Ginza Line).
* `(:PuntoInteresse)`: Luoghi esplorabili (es. Café Leblanc, Arcade Gigolo, Shujin Academy).

**Relazioni e Costrutto Multiplex (Grafo Multiplo):**

Il database implementa un'architettura a grafo multiplo, consentendo la coesistenza di più relazioni parallele tra i medesimi nodi, fondamentali per rappresentare stazioni servite da linee diverse. Questo è gestito differenziando le *chiavi di identificazione* dagli *attributi descrittivi* in fase di `MERGE`:

* `(:Fermata)-[:COLLEGATA_A {linea}]->(:Fermata)`
  * **Identificativo (Chiave):** La proprietà `linea` è inserita direttamente nel blocco `MERGE`. Questo garantisce che se due stazioni (es. *Shibuya* e *Aoyama-Itchome*) sono collegate sia dalla linea Hanzomon che dalla linea Ginza, Neo4j creerà due relazioni parallele senza che l'una sovrascriva l'altra.
  * **Attributi Calcolati (SET):** Sulla relazione vengono poi scritti i dati dinamici `distanza_km` e `durata_minuti` (calcolata incrociando lo spazio con la velocità media del nodo Linea associato).

* `(:PuntoInteresse)-[:VICINO_A]->(:Fermata)`
  * **Attributi Descrittivi (SET):** La relazione non necessita di chiavi multiple poiché ogni POI ha un unico collegamento spaziale alla sua stazione di riferimento. Possiede come semplici attributi le proprietà `distanza_metri` e `tempo_piedi_min`.

---

## Analisi Cypher: Le Query Dimostrative

Le logiche di interrogazione superano la semplice estrazione di nodi, implementando funzioni algoritmiche interne a Cypher (`reduce`, `nodes()`, `relationships()`, `shortestPath`).

### Query 1: Percorso Topologico Ottimizzato con Penalità
La query individua la rotta più breve tra due stazioni (es. *Yongen-Jaya* e *Akihabara*). 
Attraverso la scomposizione del percorso in un array di segmenti e l'utilizzo di cicli iterativi (`reduce` abbinati a clausole `CASE`), l'algoritmo valuta passo-passo se il passeggero rimane sulla stessa linea o se effettua un cambio. In caso di cambio linea, viene applicata dinamicamente una penalità di tempo (+5 minuti) al tempo di percorrenza netto.

### Query 2: Esplorazione POI con Vincolo sui Cambi
Partendo da un nodo di origine (es. *Yongen-Jaya*), il grafo si espande a macchia d'olio esplorando tutte le rotte possibili (fino a 5 hop). Successivamente, filtra i percorsi permettendo di stampare a schermo esclusivamente i Punti di Interesse raggiungibili effettuando **al massimo 2 cambi di linea**. L'output aggrega i dati sfruttando il raggruppamento implicito di Cypher e ordinando i luoghi dal più comodo al più distante.

---

## Esecuzione e Ottimizzazione di Rete (Python)

L'esecuzione di uno script analitico su un **DBMS NoSQL indipendente** come Neo4j differisce radicalmente dalla gestione di un database relazionale locale e "in-process" (come SQLite). Per massimizzare le performance e strutturare il codice secondo standard di produzione, lo script `query_mobilita_tokyo_neo4j.py` è stato ingegnerizzato seguendo tre *best practices* industriali.

Di seguito vengono analizzati i dettagli tecnici e le relative spiegazioni semplificate:

### 1. Single Driver Instance & Session Management
* **Il termine tecnico:** Ogni volta che un'applicazione deve comunicare con un server esterno, deve instaurare una connessione a livello di trasporto tramite un **handshake TCP** (una sequenza di pacchetti di sincronizzazione, verifica dei certificati e autenticazione delle credenziali). Questa operazione è computazionalmente onerosa ("pesante") e introduce latenza di rete.
* **Spiegazione semplice (For Dummies):** Immagina di dover fare dieci domande a una persona che si trova in un'altra stanza. Invece di camminare, aprire la porta, fare una domanda, richiudere la porta, tornare indietro e ripetere tutto dieci volte (approccio inefficiente), apri la porta una sola volta, fai tutte le domande in sequenza e poi chiudi la porta quando hai finito. Nello script, il *Driver* apre il tunnel di comunicazione una volta sola all'avvio, la *Sessione* invia tutte le query Cypher insieme, e infine il tunnel viene sigillato pulitamente.

### 2. Isolamento dell'Ambiente (Multi-Tenancy & Tenant)
* **Il termine tecnico:** Neo4j opera come un **DBMS (Database Management System)**, ovvero un sistema software centralizzato progettato per ospitare, gestire e isolare molteplici database logici indipendenti (architettura *multi-tenant*) sulla stessa porta logica. Di default, i driver cercano un'istanza predefinita chiamata `neo4j`.
* **Spiegazione semplice (For Dummies):** Un DBMS è come un grande condominio. Il condominio intero si trova all'indirizzo del tuo computer, ma dentro ci sono diversi appartamenti. Il database predefinito di sistema (`system`) serve solo all'amministratore per gestire le chiavi e la sicurezza, e non deve essere toccato. Popolare il database di base significa lasciare i propri mobili nell'androne del palazzo. Per questo progetto è stato creato un "appartamento" privato e isolato chiamato `trasporti.persona5`. Nello script Python è stato specificato esplicitamente questo target per evitare che i comandi andassero a bussare alla porta sbagliata.

### 3. Protocollo di Connessione Diretto (Bolt Protocol)
* **Il termine tecnico:** Viene utilizzato l'URI di connessione basato sul protocollo `bolt://127.0.0.1:7687` anziché sul protocollo generalista `neo4j://`. Il protocollo `neo4j://` attiva funzioni di *routing dinamico*, interrogando il server per ottenere una tabella di routing interna (operazione fondamentale in cluster distribuiti con repliche di lettura/scrittura). Su un'istanza locale a nodo singolo (Single-Node), questo controllo è ridondante e rallenta l'inizializzazione.
* **Spiegazione semplice (For Dummies):** Il protocollo `neo4j://` si comporta come un navigatore satellitare che, prima di farti partire, contatta una centrale per verificare il traffico e le autostrade disponibili in tutta la nazione. Visto che il database si trova sul tuo stesso computer, usare `bolt://` equivale a prendere una strada privata diretta e senza semafori, azzerando i tempi di attesa.

---

## Guida all'Avvio e Gestione degli Ambienti Python

La configurazione dell'ambiente di esecuzione richiede attenzione a causa della coesistenza di diversi interpreti Python sul sistema operativo (specialmente in presenza di distribuzioni di terze parti come Anaconda).

### 1. Avvio del DBMS Locale
Prima di lanciare qualsiasi riga di codice, il server deve essere attivo:
1. Aprire l'applicazione **Neo4j Desktop**.
2. Individuare il database dedicato `trasporti.persona5`.
3. Cliccare sul pulsante **Start** e attendere che lo stato diventi verde (**RUNNING**).

### 2. Il Dilemma degli Ambienti Virtuali: `py` vs `python`
Durante lo sviluppo di progetti multi-database, è frequente imbattersi nell'errore `ModuleNotFoundError: No module named 'neo4j'`. Questo accade a causa del conflitto tra gli ambienti Python di Windows.

* **Librerie Integrate vs Librerie Esterne:** La libreria per il database relazionale (`sqlite3`) è inclusa nativamente nella "scatola di montaggio" di Python, quindi è accessibile ovunque. Il driver di Neo4j, invece, è un pacchetto esterno che va scaricato esplicitamente da internet tramite il gestore di pacchetti `pip`.
* **La "Bolla" di Anaconda:** Quando si apre un terminale in cui è attivo l'ambiente globale di Anaconda — segnalato dal prefisso `(base)` all'inizio della riga — il comando `pip install neo4j` scarica il driver all'interno di quella specifica "bolla" protetta.
* **Il Conflitto dei Comandi:** * Se si esegue lo script con il comando generico di Windows `py nome_file.py`, il sistema utilizzerà l'interprete Python base del computer, il quale ignora completamente cosa ci sia dentro la bolla di Anaconda, sollevando un errore di modulo mancante.
    * Per costringere il computer a usare il motore corretto (quello in cui è stato installato il driver), è necessario utilizzare esplicitamente il comando completo `python`.

### 3. Sequenza di Comandi da Terminale

Aprire la PowerShell (o il prompt dei comandi) posizionandosi all'interno della cartella estratta `database_grafo_neo4j_mobilita` ed eseguire la seguente pipeline:

```bash
# Step 1: Installazione del driver ufficiale all'interno dell'ambiente attivo
pip install neo4j

# Step 2: Esecuzione dello script analitico forzando l'uso dell'interprete corretto
python query_mobilita_tokyo_neo4j.py
