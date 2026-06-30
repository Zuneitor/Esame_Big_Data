# Database Relazionale (SQLite) - Agenzia Viaggi

Questo modulo del progetto modella il sistema informatico di un'agenzia viaggi tramite un database relazionale.

## Obiettivo

L'architettura del database è progettata per gestire in modo efficiente le entità del sistema turistico e le loro relazioni. Il modello comprende la gestione di clienti, pacchetti viaggio, destinazioni, hotel, mezzi di trasporto e prenotazioni.

## Struttura delle Tabelle

Il database è composto dalle seguenti tabelle principali, collegate tramite vincoli di integrità (Primary e Foreign Key):
- `CLIENTE`
- `DESTINAZIONE`
- `HOTEL`
- `MEZZO`
- `PACCHETTO`
- `PRENOTAZIONE`

## Contenuto del Repository

Per garantire la massima trasparenza e riproducibilità, la cartella è strutturata nei seguenti file:

* **`Agenzia_Viaggi.db`**: Il file binario del database SQLite. Contiene l'intero database operativo e già popolato (con i record importati esternamente tramite file CSV).
* **Cartella `records_agenzia_viaggi/`**: Contiene i dataset grezzi originali (in formato CSV) utilizzati per l'importazione massiva e il popolamento iniziale delle tabelle relazionali.
* **`TABELLE_AGENZIA_VIAGGI.sql`**: Lo script SQL contenente la definizione dello schema. Contiene esclusivamente le istruzioni di `CREATE TABLE` ed è allegato a scopo puramente documentativo per illustrare l'architettura logica, i tipi di dato e i vincoli relazionali scelti.

## Query Implementate e Script Python

Le interrogazioni al database sono eseguibili direttamente da terminale tramite appositi script Python (basati sulle librerie `sqlite3` e `pathlib`). Di ogni query è stata fornita anche una versione "avanzata" (`_con_proprieta.py`) che include la stampa delle intestazioni di colonna per una migliore leggibilità dell'output.

1. **`query_clienti_gold.py`** * *Obiettivo:* Identificare i top spender dell'agenzia calcolando l'importo totale speso e il numero di prenotazioni per ogni cliente.
2. **`query_prenotazioni_tokyo.py`** * *Obiettivo:* Estrarre il dettaglio completo delle prenotazioni relative a una singola destinazione in locale (Tokyo), incrociando i dati di pacchetti, hotel e destinazioni.

## Esecuzione

Per eseguire gli script e interrogare il database, posizionarsi con il terminale all'interno di questa specifica cartella e lanciare il comando:

```bash
py <nome_script>.py
