import sqlite3
from pathlib import Path

# 1. Gestione dei percorsi dei file
BASE_DIR = Path(__file__).resolve().parent
DATABASE = BASE_DIR / "Agenzia_Viaggi.db"

# 2. Apertura della connessione e del cursore
connessione = sqlite3.connect(DATABASE)
cursore = connessione.cursor()

# 3. Definizione della stringa SQL (Prenotazioni su Tokyo)
query = """
SELECT 
    p.*,
    d.Citta,
    h.Nome_Hotel,
    pa.Descrizione,
    d.ID_Destinazione 
FROM PRENOTAZIONE p
JOIN PACCHETTO pa 
    ON p.ID_Pacchetto = pa.ID_Pacchetto
JOIN DESTINAZIONE d 
    ON pa.ID_Destinazione = d.ID_Destinazione
JOIN HOTEL h 
    ON pa.ID_Hotel = h.ID_Hotel  
WHERE d.Citta = 'Tokyo';
"""

# 4. Esecuzione della query e recupero dei dati
cursore.execute(query)
risultati = cursore.fetchall()

# 5. Output dei dati nel terminale
for riga in risultati:
    print(riga)

# 6. Chiusura della connessione
connessione.close()
