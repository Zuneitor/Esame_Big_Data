// Creazione massiva dei collegamenti tra le stazioni della rete di trasporti di Tokyo.
// Le relazioni sono bidirezionali e la durata in minuti viene calcolata dinamicamente 
// incrociando la distanza chilometrica con la velocità media della linea di appartenenza.

UNWIND [
    // --- L1: Yamanote Line (60 km/h) ---
    {da: "F13", a: "F12", linea: "L1", distanza_km: 1.2},
    {da: "F12", a: "F2",  linea: "L1", distanza_km: 1.4},
    {da: "F2",  a: "F10", linea: "L1", distanza_km: 1.5},
    {da: "F10", a: "F11", linea: "L1", distanza_km: 0.8},
    {da: "F11", a: "F3",  linea: "L1", distanza_km: 0.9},
    {da: "F3",  a: "F18", linea: "L1", distanza_km: 5.5},
    {da: "F18", a: "F24", linea: "L1", distanza_km: 5.0},
    {da: "F24", a: "F16", linea: "L1", distanza_km: 2.0},
    {da: "F16", a: "F15", linea: "L1", distanza_km: 3.5},
    {da: "F15", a: "F21", linea: "L1", distanza_km: 1.5},
    {da: "F21", a: "F14", linea: "L1", distanza_km: 3.5},
    {da: "F14", a: "F13", linea: "L1", distanza_km: 2.5},

    // --- L2: Chuo Line (75 km/h) ---
    {da: "F15", a: "F23", linea: "L2", distanza_km: 1.3},
    {da: "F23", a: "F22", linea: "L2", distanza_km: 0.7},
    {da: "F22", a: "F8",  linea: "L2", distanza_km: 1.8},
    {da: "F8",  a: "F3",  linea: "L2", distanza_km: 2.2},
    {da: "F3",  a: "F26", linea: "L2", distanza_km: 3.0},
    {da: "F26", a: "F27", linea: "L2", distanza_km: 1.5},
    {da: "F27", a: "F28", linea: "L2", distanza_km: 0.8},
    {da: "F28", a: "F29", linea: "L2", distanza_km: 1.5},
    {da: "F29", a: "F7",  linea: "L2", distanza_km: 2.0},
    {da: "F7",  a: "F30", linea: "L2", distanza_km: 2.0},

    // --- L3: Ginza Line (40 km/h) ---
    {da: "F2",  a: "F5",  linea: "L3", distanza_km: 1.6},
    {da: "F5",  a: "F21", linea: "L3", distanza_km: 3.0},
    {da: "F21", a: "F20", linea: "L3", distanza_km: 0.9},
    {da: "F20", a: "F23", linea: "L3", distanza_km: 2.5},
    {da: "F23", a: "F16", linea: "L3", distanza_km: 2.0},
    {da: "F16", a: "F17", linea: "L3", distanza_km: 1.8},

    // --- L4: Marunouchi Line (40 km/h) ---
    {da: "F18", a: "F6",  linea: "L4", distanza_km: 2.3},
    {da: "F6",  a: "F22", linea: "L4", distanza_km: 0.9},
    {da: "F22", a: "F15", linea: "L4", distanza_km: 2.8},
    {da: "F15", a: "F20", linea: "L4", distanza_km: 1.1},
    {da: "F20", a: "F8",  linea: "L4", distanza_km: 3.2}, // Errore corretto da Track_dist_km a distanza_km
    {da: "F8",  a: "F3",  linea: "L4", distanza_km: 2.4},

    // --- L5: Hanzomon Line (45 km/h) ---
    {da: "F2",  a: "F5",  linea: "L5", distanza_km: 1.6},
    {da: "F5",  a: "F31", linea: "L5", distanza_km: 3.5},
    {da: "F31", a: "F6",  linea: "L5", distanza_km: 0.7},

    // --- L6: Tozai Line (45 km/h) ---
    {da: "F26", a: "F9",  linea: "L6", distanza_km: 3.5},
    {da: "F9",  a: "F31", linea: "L6", distanza_km: 1.8},
    {da: "F31", a: "F22", linea: "L6", distanza_km: 1.5},
    {da: "F22", a: "F15", linea: "L6", distanza_km: 2.8},

    // --- L7: Oedo Line (35 km/h) ---
    {da: "F3",  a: "F19", linea: "L7", distanza_km: 3.8},
    {da: "F19", a: "F21", linea: "L7", distanza_km: 3.5},
    {da: "F21", a: "F20", linea: "L7", distanza_km: 1.1},
    {da: "F20", a: "F6",  linea: "L7", distanza_km: 2.5},
    {da: "F6",  a: "F25", linea: "L7", distanza_km: 3.5},

    // --- L8: Hibiya Line (40 km/h) ---
    {da: "F13", a: "F12", linea: "L8", distanza_km: 1.2},
    {da: "F12", a: "F19", linea: "L8", distanza_km: 2.3},
    {da: "F19", a: "F20", linea: "L8", distanza_km: 3.2},
    {da: "F20", a: "F16", linea: "L8", distanza,km: 4.5},
    {da: "F16", a: "F24", linea: "L8", distanza_km: 2.5},

    // --- L9: Shinjuku Line Toei (45 km/h) ---
    {da: "F3",  a: "F9",  linea: "L9", distanza_km: 2.5},
    {da: "F9",  a: "F31", linea: "L9", distanza_km: 1.8},
    {da: "F31", a: "F4",  linea: "L9", distanza_km: 2.0},
    {da: "F4",  a: "F17", linea: "L9", distanza_km: 3.5},

    // --- L10: Mita Line Toei (45 km/h) ---
    {da: "F13", a: "F21", linea: "L10", distanza_km: 4.5},
    {da: "F21", a: "F15", linea: "L10", distanza_km: 1.5},
    {da: "F15", a: "F31", linea: "L10", distanza_km: 2.0},
    {da: "F31", a: "F6",  linea: "L10", distanza_km: 0.7},
    {da: "F6",  a: "F25", linea: "L10", distanza_km: 3.2},
    {da: "F25", a: "F24", linea: "L10", distanza_km: 3.0},

    // --- L11: Keio Inokashira Line (50 km/h) ---
    {da: "F2",  a: "F1",  linea: "L11", distanza_km: 2.5},
    {da: "F1",  a: "F7",  linea: "L11", distanza_km: 7.0},

    // --- L12: Saikyo Line (70 km/h) ---
    {da: "F14", a: "F12", linea: "L12", distanza_km: 3.5},
    {da: "F12", a: "F2",  linea: "L12", distanza_km: 1.4},
    {da: "F2",  a: "F3",  linea: "L12", distanza_km: 3.5},
    {da: "F3",  a: "F18", linea: "L12", distanza_km: 5.5},
    {da: "F18", a: "F25", linea: "L12", distanza_km: 2.0},

    // --- L13: Den-en-toshi Line (55 km/h) ---
    {da: "F14", a: "F1",  linea: "L13", distanza_km: 4.0},
    {da: "F1",  a: "F2",  linea: "L13", distanza_km: 3.0},
    {da: "F2",  a: "F5",  linea: "L13", distanza_km: 1.6},

    // --- L14: Shibuya-Yongen Bus (25 km/h) ---
    {da: "F2",  a: "F1",  linea: "L14", distanza_km: 2.8},

    // --- L15: Akihabara Shuttle (30 km/h) ---
    {da: "F4",  a: "F6",  linea: "L15", distanza_km: 1.5},
    {da: "F6",  a: "F22", linea: "L15", distanza_km: 0.7},
    {da: "F22", a: "F23", linea: "L15", distanza_km: 0.5},
    {da: "F23", a: "F15", linea: "L15", distanza_km: 1.3}
] AS row

MATCH (a:Fermata {codice: row.da})
MATCH (b:Fermata {codice: row.a})
MATCH (l:Linea   {codice: row.linea})

MERGE (a)-[r1:COLLEGATA_A {linea: row.linea}]->(b)
SET r1.distanza_km   = row.distanza_km,
    r1.durata_minuti = round(row.distanza_km / l.velocita_media_kmh * 60, 1),
    r1.linea_nome    = l.nome,
    r1.nome_tratta   = l.nome + ": " + a.nome + " -> " + b.nome

MERGE (b)-[r2:COLLEGATA_A {linea: row.linea}]->(a)
SET r2.distanza_km   = row.distanza_km,
    r2.durata_minuti = round(row.distanza_km / l.velocita_media_kmh * 60, 1),
    r2.linea_nome    = l.nome,
    r2.nome_tratta   = l.nome + ": " + b.nome + " -> " + a.nome;
