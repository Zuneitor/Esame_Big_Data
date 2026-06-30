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
print("\nConnessione a Neo4j chiusa correttamente.")
