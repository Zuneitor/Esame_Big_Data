import sqlite3
from pathlib import Path

# 1. Gestione dei percorsi dei file
BASE_DIR = Path(__file__).resolve().parent
DATABASE = BASE_DIR / "Agenzia_Viaggi.db"

# 2. Apertura della connessione e del cursore
connessione = sqlite3.connect(DATABASE)
cursore = connessione.cursor()

# 3. Definizione della stringa SQL (Clienti Gold)
query = """
SELECT 
    c.Nome,
    c.Cognome,
    c.ID_Cliente,
    SUM(p.Importo_Complessivo) AS Totale_Speso,
    COUNT(p.ID_Prenotazione) AS numero_di_prenotazioni_effettuate
FROM CLIENTE c 
JOIN PRENOTAZIONE p 
    ON c.ID_Cliente = p.ID_Cliente
GROUP BY c.ID_Cliente 
ORDER BY Totale_Speso DESC;
"""

# 4. Esecuzione della query e recupero dei dati
cursore.execute(query)
risultati = cursore.fetchall()

# Estrazione e stampa dei nomi delle proprietà (colonne)
nomi_colonne = [descrizione[0] for descrizione in cursore.description]
print(nomi_colonne)
print("-" * 90) # Linea di separazione visiva

# 5. Output dei dati nel terminale
for riga in risultati:
    print(riga)

# 6. Chiusura della connessione
connessione.close()
