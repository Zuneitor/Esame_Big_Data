# Prerequisiti: Installazione Driver Neo4j per Python

Prima di poter eseguire le interrogazioni finali e far comunicare lo script Python con il server locale di Neo4j, è strettamente necessario installare il driver ufficiale.

Questa separazione tra l'ambiente di esecuzione e lo script di analisi è una *best practice* adottata per evitare installazioni forzate e non consensuali all'interno dei codici sorgente.

### Come installare il driver
Aprire il terminale (o la PowerShell) sul proprio computer e lanciare il seguente comando:

```bash
pip install neo4j
