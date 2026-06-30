// ATTENZIONE: questo script cancella tutti i nodi, le relazioni, gli indici e i vincoli.
// Utilizzare per ripulire totalmente l'ambiente Neo4j.

// 1. Cancellazione fisica di nodi e relazioni
MATCH (n)
DETACH DELETE n;

// 2. Eliminazione degli indici (creati per ottimizzare le query)
DROP INDEX fermata_nome_index IF EXISTS;
DROP INDEX linea_nome_index IF EXISTS;
DROP INDEX poi_nome_index IF EXISTS;

// 3. Eliminazione dei vincoli di unicità (creati dal Data Importer)
DROP CONSTRAINT fermata_codice IF EXISTS;
DROP CONSTRAINT linea_codice IF EXISTS;
DROP CONSTRAINT poi_codice IF EXISTS;
