# Importazione Nodi (Data Ingestion)

A differenza delle relazioni, che sono state modellate e generate dinamicamente tramite script Cypher, la creazione massiva dei nodi logici (`Fermata`, `Linea`, `PuntoInteresse`) è stata gestita tramite il **Data Importer nativo di Neo4j**. 

I dataset grezzi originali utilizzati per il popolamento iniziale del grafo sono conservati nella directory `records_nodi/` di questo repository. Questa scelta architetturale è stata adottata per simulare uno scenario realistico di Big Data, ottimizzando i tempi di ingestione ed evitando la stesura di script di creazione manuale ridondanti.
