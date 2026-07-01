// ========================================================================================
// 1. CREAZIONE COLLEGAMENTI RETE METROPOLITANA
// ========================================================================================
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
    {da: "F20", a: "F8",  linea: "L4", distanza_km: 3.2}, 
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
    {da: "F20", a: "F16", linea: "L8", distanza_km: 4.5},
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


// ========================================================================================
// 2. CREAZIONE COLLEGAMENTI TRA PUNTI DI INTERESSE E FERMATE (VICINO_A)
// ========================================================================================

UNWIND [
  // Zona: Yongen-Jaya (F1)
  {poi: "P1", fermata: "F1", spazio_m: 120, tempo_min: 2},  // Café Leblanc
  {poi: "P2", fermata: "F1", spazio_m: 180, tempo_min: 3},  // Clinica Medica Takemi
  {poi: "P3", fermata: "F1", spazio_m: 210, tempo_min: 3},  // Lavanderia a gettoni
  {poi: "P4", fermata: "F1", spazio_m: 250, tempo_min: 4},  // Bagni Pubblici
  {poi: "P5", fermata: "F1", spazio_m: 290, tempo_min: 4},  // Negozio dell'usato Yumenoshima
  
  // Zona: Aoyama-Itchome (F5)
  {poi: "P6", fermata: "F5", spazio_m: 400, tempo_min: 6},  // Shujin Academy
  {poi: "P7", fermata: "F5", spazio_m: 450, tempo_min: 7},  // Palazzo di Kamoshida
  
  // Zona: Shibuya (F2)
  {poi: "P8", fermata: "F2", spazio_m: 50,  tempo_min: 1},  // Central Street
  {poi: "P9", fermata: "F2", spazio_m: 160, tempo_min: 2},  // Untouchable (Airsoft Shop)
  {poi: "P10", fermata: "F2", spazio_m: 220, tempo_min: 3}, // Diner (Shibuya)
  {poi: "P11", fermata: "F2", spazio_m: 190, tempo_min: 3}, // Big Bang Burger
  {poi: "P12", fermata: "F2", spazio_m: 310, tempo_min: 5}, // Arcade Gigolo
  {poi: "P13", fermata: "F2", spazio_m: 400, tempo_min: 6}, // Palestra
  {poi: "P14", fermata: "F2", spazio_m: 140, tempo_min: 2}, // Libreria Taiheido
  {poi: "P15", fermata: "F2", spazio_m: 0,   tempo_min: 0}, // Teikyu Building (Sopra la stazione)
  
  // Collegamenti Speciali / Sovrannaturali
  {poi: "P16", fermata: "F1", spazio_m: 10,  tempo_min: 1},  // Stanza di Velluto
  {poi: "P17", fermata: "F2", spazio_m: 20,  tempo_min: 1},  // Mementos
  
  // Zona: Shinjuku (F3)
  {poi: "P18", fermata: "F3", spazio_m: 600, tempo_min: 9},  // Palazzo di Kaneshiro
  {poi: "P19", fermata: "F3", spazio_m: 300, tempo_min: 4},  // Quartiere a Luci Rosse
  {poi: "P20", fermata: "F3", spazio_m: 350, tempo_min: 5},  // Bar Crossroads
  {poi: "P21", fermata: "F3", spazio_m: 280, tempo_min: 4},  // Tavolo di Chihaya
  {poi: "P22", fermata: "F3", spazio_m: 150, tempo_min: 2},  // Fioraio di Shinjuku
  {poi: "P23", fermata: "F3", spazio_m: 450, tempo_min: 6},  // Cinema di Shinjuku
  
  // Zona: Akihabara (F4)
  {poi: "P24", fermata: "F4", spazio_m: 200, tempo_min: 3},  // Maid Cafe
  {poi: "P25", fermata: "F4", spazio_m: 180, tempo_min: 3},  // Retro Game Shop
  {poi: "P26", fermata: "F4", spazio_m: 120, tempo_min: 2},  // Negozio di componenti elettronici
  {poi: "P27", fermata: "F4", spazio_m: 250, tempo_min: 4},  // Sala Giochi Akihabara
  
  // Zona: Kichijoji (F7)
  {poi: "P28", fermata: "F7", spazio_m: 350, tempo_min: 5},  // Penguin Sniper
  {poi: "P29", fermata: "F7", spazio_m: 400, tempo_min: 6},  // Jazz Jin
  {poi: "P30", fermata: "F7", spazio_m: 150, tempo_min: 2},  // Tempio di Kichijoji
  {poi: "P31", fermata: "F7", spazio_m: 220, tempo_min: 3},  // Negozio di vestiti usati
  {poi: "P32", fermata: "F7", spazio_m: 100, tempo_min: 1},  // Bottega della Carne
  
  // Altri Palazzi e Istituzioni 
  {poi: "P33", fermata: "F20", spazio_m: 500, tempo_min: 7}, // Museo d'Arte -> Ginza
  {poi: "P34", fermata: "F20", spazio_m: 550, tempo_min: 8}, // Palazzo di Madarame -> Ginza
  {poi: "P35", fermata: "F30", spazio_m: 900, tempo_min: 12},// Palazzo di Futaba -> Mitaka
  {poi: "P36", fermata: "F15", spazio_m: 700, tempo_min: 10},// Palazzo di Okumura -> Tokyo
  {poi: "P37", fermata: "F8",  spazio_m: 200, tempo_min: 3}, // Tribunale di Tokyo -> Yotsuya
  {poi: "P38", fermata: "F8",  spazio_m: 250, tempo_min: 4}, // Palazzo di Niijima -> Yotsuya
  {poi: "P39", fermata: "F21", spazio_m: 300, tempo_min: 4}, // Dieta Nazionale -> Shimbashi
  {poi: "P40", fermata: "F21", spazio_m: 350, tempo_min: 5}, // Palazzo di Shido -> Shimbashi
  {poi: "P41", fermata: "F6",  spazio_m: 150, tempo_min: 2}, // Cupola di Tokyo -> Suidobashi
  {poi: "P42", fermata: "F7",  spazio_m: 500, tempo_min: 7}  // Parco Inokashira -> Kichijoji
] AS riga

MATCH (p:PuntoInteresse {codice: riga.poi})
MATCH (f:Fermata {codice: riga.fermata})

MERGE (p)-[r:VICINO_A]->(f)
SET r.distanza_metri = toFloat(riga.spazio_m),
    r.tempo_piedi_min = toInteger(riga.tempo_min);
