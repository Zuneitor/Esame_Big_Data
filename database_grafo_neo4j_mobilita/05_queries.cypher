// =========================================================================
// QUERY 1: Trovare il percorso topologico più breve e calcolarne i tempi
// =========================================================================

// 1. Troviamo i nodi di partenza e arrivo
MATCH (partenza:Fermata {nome: 'Yongen-Jaya'})
MATCH (arrivo:Fermata {nome: 'Akihabara'})

// 2. Calcolo del percorso topologico (minor numero di salti)
// NOTA: shortestPath trova la via con meno fermate (hops). 
// Non usa i minuti per prendere questa decisione, esplora la mappa a macchia d'olio.
MATCH percorso = shortestPath((partenza)-[:COLLEGATA_A*]-(arrivo))

// 3. Estrazione e indicizzazione automatica
// Sotto il cofano, la funzione relationships() prende l'intero 'percorso' trovato
// e lo "taglia", creando automaticamente una Lista (Array) delle tratte fisiche. 
// Questa lista viene indicizzata dal database partendo da zero (binari[0], binari[1]...).
WITH percorso, relationships(percorso) AS binari

// 4. Calcolo del tempo passato fisicamente in treno
// L'omino (reduce) accende la calcolatrice e parte da 0.0. 
// Per ogni tratta (b) pescata dalla lista (binari),
// aggiunge i minuti di durata (b.durata_minuti) al totale accumulato (tempo).
WITH percorso, binari,
     reduce(tempo = 0.0, b IN binari | tempo + b.durata_minuti) AS minuti_in_treno

// 5. Calcolo della penalità per i cambi di linea
// Usiamo un indice 'i' (range) per poter confrontare un elemento con il suo precedente.
WITH percorso, binari, minuti_in_treno,
     reduce(penalita = 0, i IN range(1, size(binari) - 1) |
        
        // Il blocco CASE valuta le condizioni passo passo (come un IF-THEN-ELSE).
        CASE 
            // Il simbolo '<>' significa "DIVERSO DA".
            // Chiediamo: "La linea della tratta attuale (binari[i].linea) è DIVERSA 
            // dalla linea della tratta che ho percorso prima (binari[i-1].linea)?"
            WHEN binari[i].linea <> binari[i-1].linea 
            
            // THEN (Vero): Le linee sono diverse, l'utente ha cambiato treno. 
            // Aggiungiamo 5 minuti al contatore della penalità.
            THEN penalita + 5 
            
            // ELSE (Falso): Le linee sono uguali, l'utente è rimasto seduto.
            // Lasciamo la penalità intatta.
            ELSE penalita 
        END
     ) AS minuti_cambio_linea

// 6. Preparazione dello "scontrino" finale con i risultati formattati
// RETURN dice al database di stampare a schermo i dati richiesti.
RETURN 
    // List Comprehension: Scorri tutti i nodi (stazioni) toccati, chiamali 'n',
    // estrai SOLO la proprietà 'nome' e crea una nuova lista pulita.
    [n IN nodes(percorso) | n.nome] AS Itinerario_Stazioni,
    
    // Stessa logica: scorri i binari, chiamali 'b', estrai SOLO il nome della linea.
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
