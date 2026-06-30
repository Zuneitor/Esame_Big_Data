from neo4j import GraphDatabase

# ==============================================================================
# ARCHITETTURA DI CONNESSIONE E OTTIMIZZAZIONE DI RETE
# ==============================================================================
# A differenza dei database relazionali locali (es. SQLite), Neo4j opera come
# un server indipendente. Aprire il "tunnel" di comunicazione TCP verso la porta
# 7687 è un'operazione computazionalmente "pesante" (handshake, autenticazione).
# Per ottimizzare le performance, questo script implementa una connessione 
# singola (Single Driver Instance): il tunnel viene aperto una sola volta, 
# tutte le query vengono sparate in sequenza all'interno della stessa sessione,
# e infine la connessione viene chiusa pulitamente.
# ==============================================================================

# Credenziali di accesso al DBMS locale
URI = "bolt://127.0.0.1:7687"
USERNAME = "neo4j"
PASSWORD = "12345678"

# Inizializzazione del Driver
driver = GraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))

# ------------------------------------------------------------------------------
# DEFINIZIONE DELLE QUERY CYPHER
# ------------------------------------------------------------------------------

query_percorso_breve = """
MATCH (partenza:Fermata {nome: 'Yongen-Jaya'})
MATCH (arrivo:Fermata {nome: 'Akihabara'})
MATCH percorso = shortestPath((partenza)-[:COLLEGATA_A*]-(arrivo))
WITH percorso, relationships(percorso) AS binari
WITH percorso, binari,
     reduce(tempo = 0.0, b IN binari | tempo + b.durata_minuti) AS minuti_in_treno
WITH percorso, binari, minuti_in_treno,
     reduce(penalita = 0, i IN range(1, size(binari) - 1) |
        CASE 
            WHEN binari[i].linea <> binari[i-1].linea THEN penalita + 5 
            ELSE penalita 
        END
     ) AS minuti_cambio_linea
RETURN 
    [n IN nodes(percorso) | n.nome] AS Itinerario_Stazioni,
    [b IN binari | b.linea_nome] AS Elenco_Linee_Prese,
    round(minuti_in_treno, 1) AS Tempo_Puro_Treno,
    minuti_cambio_linea AS Tempo_Perso_Cambi,
    round(minuti_in_treno + minuti_cambio_linea, 1) AS Tempo_Totale_Viaggio;
"""

query_poi_vicini = """
MATCH (partenza:Fermata {nome: 'Yongen-Jaya'})
MATCH percorso = (partenza)-[:COLLEGATA_A*0..5]-(arrivo:Fermata)
MATCH (arrivo)<-[:VICINO_A]-(poi:PuntoInteresse)
WITH poi, arrivo, relationships(percorso) AS binari
WITH poi, arrivo,
     reduce(cambi = 0, i IN range(1, size(binari) - 1) |
        CASE 
            WHEN binari[i].linea <> binari[i-1].linea THEN cambi + 1 
            ELSE cambi 
        END
     ) AS numero_cambi
WHERE numero_cambi <= 2
RETURN 
    poi.nome AS Punto_Di_Interesse, 
    arrivo.nome AS Stazione,
    min(numero_cambi) AS Cambi_Necessari
ORDER BY Cambi_Necessari ASC, Punto_Di_Interesse ASC;
"""

# ------------------------------------------------------------------------------
# ESECUZIONE DELLE QUERY E STAMPA A TERMINALE
# ------------------------------------------------------------------------------

with driver.session(database="trasporti.persona5") as session:
    
    print("\n" + "="*80)
    print(" QUERY 1: PERCORSO TOPOLOGICO PIU' BREVE (Yongen-Jaya -> Akihabara)")
    print("="*80)
    risultati_1 = session.run(query_percorso_breve)
    for record in risultati_1:
        # Stampiamo i dati in formato dizionario per una lettura chiara
        for chiave, valore in record.items():
            print(f"{chiave}: {valore}")
            
    print("\n" + "="*80)
    print(" QUERY 2: PUNTI DI INTERESSE RAGGIUNGIBILI (Max 2 cambi da Yongen-Jaya)")
    print("="*80)
    risultati_2 = session.run(query_poi_vicini)
    for record in risultati_2:
        print(record.data())

# Chiusura pulita del tunnel di rete
driver.close()
print("\nConnessione a Neo4j chiusa correttamente.")    // Stessa logica: scorri i binari, chiamali 'b', estrai SOLO il nome della linea.
    [b IN binari | b.linea_nome] AS Elenco_Linee_Prese,
    
    // La funzione round() arrotonda il numero decimale a una cifra (es. 14.5).
    round(minuti_in_treno, 1) AS Tempo_Puro_Treno,
    
    // Stampa la penalità totale calcolata nello step 5.
    minuti_cambio_linea AS Tempo_Perso_Cambi,
    
    // Somma dinamicamente le due variabili al volo per darti il totale reale.
    round(minuti_in_treno + minuti_cambio_linea, 1) AS Tempo_Totale_Viaggio;


// =========================================================================
// QUERY 2: Trovare i POI raggiungibili con al massimo 2 cambi di linea
// =========================================================================

// 1. PASSO DI PARTENZA
// Identifica il nodo iniziale sulla mappa.
MATCH (partenza:Fermata {nome: 'Yongen-Jaya'})

// 2. ESPLORAZIONE DELLA RETE METROPOLITANA
// Cerca tutti i percorsi possibili verso qualsiasi altra fermata.
// Il limite '*0..5' indica al database di esplorare da un minimo di 0 fermate 
// (per trovare i POI situati nella stazione stessa) fino a un massimo di 5 fermate,
// agendo come blocco di sicurezza per evitare scansioni infinite o cicli ricorsivi.
MATCH percorso = (partenza)-[:COLLEGATA_A*0..5]-(arrivo:Fermata)

// 3. CONNESSIONE AL PUNTO DI INTERESSE (POI)
// Collega la fermata raggiunta ai luoghi d'interesse associati.
// La freccia è invertita (<-) perché nel database la relazione 'VICINO_A' 
// è direzionata dal PuntoInteresse verso la Fermata. Separare questo MATCH dal precedente
// evita che la camminata a piedi entri per errore nel calcolo dei treni.
MATCH (arrivo)<-[:VICINO_A]-(poi:PuntoInteresse)

// 4. PRIMO PASSAGGIO DI CONSEGNE (WITH)
// Il comando WITH funge da nastro trasportatore nella catena di montaggio di Cypher.
// Prende le variabili e le passa al reparto successivo. La funzione relationships()
// "taglia" il percorso in singoli segmenti e crea sotto il cofano una Lista ordinata 
// e numerata automaticamente a partire da zero (binari[0], binari[1], ecc.).
WITH poi, arrivo, relationships(percorso) AS binari

// 5. CONTEGGIO DEI CAMBI (REDUCE)
// L'omino del ciclo reduce azzera il contatore (cambi = 0) e usa un elenco di posizioni (range).
// Confronta ogni tratta (i) con la precedente (i-1). L'operatore '<>' significa "DIVERSO DA".
// Se le linee sono diverse (WHEN... THEN), aggiunge 1 al conteggio dei cambi, altrimenti (ELSE) lo lascia invariato.
WITH poi, arrivo,
     reduce(cambi = 0, i IN range(1, size(binari) - 1) |
        CASE 
            WHEN binari[i].linea <> binari[i-1].linea THEN cambi + 1 
            ELSE cambi 
        END
     ) AS numero_cambi

// 6. IL FILTRO BUTTAFUORI (WHERE)
// Il WHERE esamina i tracciati uno alla volta sul nastro trasportatore prima che arrivino alla fine.
// Se un percorso richiede più di 2 cambi, viene scartato immediatamente. 
// Il WHERE non può contenere funzioni come min() perché non ha una visione d'insieme del gruppo.
WHERE numero_cambi <= 2

// 7. IMPAGINAZIONE E AGGREGAZIONE FINALE (RETURN)
// RETURN definisce le colonne della tabella finale e genera automaticamente le righe.
// Quando si affiancano colonne normali a una funzione di aggregazione come min(),
// Cypher attiva il "Grouping Implicito": schiaccia insieme tutte le righe che hanno lo stesso
// 'poi.nome' e 'arrivo.nome' e isola esclusivamente il valore di 'numero_cambi' più basso trovato.
RETURN 
    poi.nome AS Punto_Di_Interesse, 
    arrivo.nome AS Stazione,
    min(numero_cambi) AS Cambi_Necessari

// 8. ORDINAMENTO A CASCATA (ORDER BY)
// Viene letto rigorosamente da sinistra verso destra.
// Criterio principale: 'Cambi_Necessari 'ASC' ordina la tabella dai luoghi più comodi (0 cambi) a quelli più lontani (2).
// Criterio di spareggio: 'Punto_Di_Interesse ASC' interviene solo in caso di parità di cambi, ordinando i POI alfabeticamente.
ORDER BY Cambi_Necessari ASC, Punto_Di_Interesse ASC;
