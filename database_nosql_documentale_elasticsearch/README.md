# Database NoSQL Documentale - Elasticsearch & Docker

Questa directory contiene l'implementazione del modulo **NoSQL Documentale** del progetto d'esame. L'infrastruttura è basata su **Elasticsearch** (motore di ricerca e indicizzazione) orchestrato tramite **Docker**, ed è dedicata all'analisi testuale e sentimentale.

## 1. Dominio Applicativo e Dataset

A differenza dei database relazionali (focalizzati sulle transazioni strutturate) e a grafo (focalizzati sulla topologia spaziale), Elasticsearch eccelle nella **ricerca full-text** e nell'analisi di testi destrutturati.

Per sfruttare appieno queste caratteristiche, il dominio scelto è l'analisi delle recensioni della community di Steam per l'atteso JRPG **Clair Obscur: Expedition 33**.
Il dataset è composto da **50 documenti JSON (recensioni)**. Per garantire realismo e varietà lessicale:
* Le prime **23 recensioni** sono dati reali estratti direttamente dalla piattaforma Steam.
* Le restanti **27 recensioni** sono state generate sinteticamente per raggiungere un campione statisticamente rilevante e testare scenari specifici (es. critiche sulla "mappa", bug tecnici, lodi al combat system).

Ogni documento (recensione) presenta una struttura ibrida, contenente campi esatti (`keyword`), metriche quantitative (`integer`, `float`) e testo destrutturato (`text`).

---

## 2. Infrastruttura Containerizzata (Docker)

Per allineare il progetto agli standard industriali di Data Engineering, l'ambiente non è stato installato "bare-metal" sul sistema operativo locale, ma è stato completamente containerizzato. Il file `docker-compose.yml` orchestra due servizi interdipendenti: **Elasticsearch** (motore) e **Kibana** (interfaccia grafica/console).

**Scelte di Configurazione Architetturale (YAML):**
1. **Security Bypass (`xpack.security.enabled=false`):** Ottimizzazione specifica per ambienti di sviluppo/test locale. Permette la comunicazione HTTP in chiaro, evitando l'inserimento di password hardcoded (vulnerabilità di sicurezza) o la complessa gestione di certificati SSL negli script applicativi.
2. **Healthcheck e Dipendenze:** Il servizio Kibana è configurato con `depends_on: condition: service_healthy`. Questo impedisce a Kibana di avviarsi e bloccarsi (crash loop) prima che il nodo Elasticsearch abbia finito il boot e risposto positivamente a un ping interno di controllo (`curl`).
3. **Resource Capping (`ES_JAVA_OPTS=-Xms1g -Xmx1g`):** La memoria dell'Heap Java del motore è stata rigorosamente limitata a 1GB per evitare saturazioni della RAM sul sistema host.

---

## 3. Scelte Ingegneristiche e Architettura del Software

### A. Elaborazione del Linguaggio Naturale (NLP)
Il mapping dell'indice non si limita ad accogliere dati, ma prepara il testo per l'indicizzazione intelligente. Al campo `review_text` è stato applicato esplicitamente l'`analyzer: "italian"`. Questo costrutto attiva il motore NLP di Elasticsearch, il quale:
* Rimuove le *stop-words* (articoli, preposizioni, congiunzioni).
* Applica lo *stemming* (riduce le parole alla loro radice, in modo che cercare "mappa" trovi anche "mappe").

### B. Separation of Concerns (Separazione delle Responsabilità)
Nel calcolo del *Sentiment* (Query 1), si è scelto di mantenere una rigorosa separazione dei ruoli tra **Database** e **Client Applicativo (Python)**.
* **Il Motore (Elasticsearch)** si limita a estrarre ed aggregare i valori assoluti (*doc_count*). Non esegue script interni (come *Painless*) per calcolare percentuali matematiche, risparmiando cicli CPU del server e massimizzando la velocità di risposta per cui è progettato.
* **Il Client (Python)** riceve i dati aggregati in millisecondi, esegue le operazioni di divisione e formatta l'output calcolando le percentuali finali a schermo (es. 74.0% Positivo).

---

## 4. Struttura del Repository

* 📄 `docker-compose.yml`: Il manifesto per la creazione dell'infrastruttura di rete e dei container.
* 📄 `01_script_kibana_dev_tools.txt`: Dump crudo delle query JSON. Dimostra la padronanza nativa della **Query DSL** di Elasticsearch interrogando il motore direttamente tramite interfaccia REST, bypassando linguaggi intermedi.
* 🐍 `query_elasticsearch_steam.py`: L'applicativo Python documentato. Si occupa della distruzione/creazione dell'indice, dell'ingestione massiva (tramite `helpers.bulk` per evitare latenze di rete da chiamate singole) e dell'esecuzione delle query analitiche finali.

---

## 5. Guida all'Avvio e Troubleshooting Operativo

### Step 1: Avvio dell'Infrastruttura
L'infrastruttura Docker gestisce autonomamente l'ambiente, ma l'avvio differisce a seconda che sia la prima volta o una sessione successiva:

* **Al primo avvio assoluto:** È necessario costruire l'infrastruttura. Aprire il terminale nella directory corrente ed eseguire il comando:
  ```bash
  docker-compose up -d
  ```

* **Per le sessioni successive:** Non è più necessario l'uso del terminale. I container sono già costruiti e persistenti: basterà aprire l'interfaccia grafica di **Docker Desktop**, recarsi nella sezione "Containers" e cliccare sul tasto Play (▶️) relativo al gruppo del progetto per riaccendere il motore. Attendere che lo stato di Elasticsearch diventi **"Running"**.

### Step 2: Allineamento Versioni (Troubleshooting Client-Server)
Un errore sistemistico comune (`BadRequestError 400`) deriva dal disallineamento (*Version Mismatch*) tra il motore e il linguaggio Python.

Il file YAML impone la creazione di un server Elasticsearch in versione **8.x**. Tuttavia, un generico comando `pip install elasticsearch` scarica nativamente l'ultima versione disponibile (es. v9.x). Poiché il client v9 utilizza header HTTP non riconosciuti dal server v8, la connessione viene rifiutata.

Per risolvere e imporre a Python di parlare il medesimo "dialetto" del database, è obbligatorio installare esplicitamente un pacchetto della famiglia 8.x:
```bash
pip install "elasticsearch<9.0.0"
```

### Step 3: Esecuzione delle Analisi
Una volta accesa l'infrastruttura e allineati i pacchetti, avviare il motore analitico posizionandosi con il terminale all'interno della directory del progetto:
```bash
python query_elasticsearch_steam.py
```

**Output delle Query Implementate:**

Lo script restituirà a schermo:
1. **Aggregazione (`aggs`):** Il calcolo assoluto e percentuale del sentiment generale (Consigliato vs Non Consigliato).
2. **Ricerca Full-Text (`match`):** L'elenco delle recensioni che criticano o citano l'assenza della "mappa" di gioco, sfruttando l'analizzatore semantico italiano, con stampa integrale dei commenti.
3. **Filtro Range & Ordinamento (`range`, `sort`):** Estrazione delle sole recensioni ritenute maggiormente influenti dalla community (≥ 100 voti utili), classificate per utilità decrescente.
4. **Query Booleana Complessa (`bool`, `must`, `filter`):** Un incrocio restrittivo che individua esclusivamente i giocatori che citano esplicitamente il termine "JRPG", filtrati unicamente tra coloro che hanno lasciato un feedback positivo.
