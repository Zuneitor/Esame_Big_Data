// Creazione degli indici per velocizzare la ricerca testuale tramite nome.
// NOTA BENE: I vincoli di unicità (CONSTRAINT) sulle proprietà 'codice' 
// non sono inclusi in questo script poiché vengono generati automaticamente 
// dal Data Importer nativo di Neo4j durante l'ingestione massiva dei file CSV.

CREATE INDEX fermata_nome_index IF NOT EXISTS FOR (f:Fermata) ON (f.nome);
CREATE INDEX linea_nome_index IF NOT EXISTS FOR (l:Linea) ON (l.nome);
CREATE INDEX poi_nome_index IF NOT EXISTS FOR (p:PuntoInteresse) ON (p.nome);
