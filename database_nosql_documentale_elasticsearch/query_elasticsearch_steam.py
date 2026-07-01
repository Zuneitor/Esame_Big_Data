from elasticsearch import Elasticsearch, helpers

# ==============================================================================
# 1. CONNESSIONE AL CLUSTER ELASTICSEARCH (DOCKER)
# ==============================================================================
# Istanziamo il client in Python per comunicare con il container Docker.
# xpack.security.enabled=false nel file YAML ci permette di usare HTTP standard.
es = Elasticsearch("http://localhost:9200")

indice = "expedition33-reviews"

# ==============================================================================
# 2. DEFINIZIONE DEL MAPPING
# ==============================================================================
# Se l'indice esiste già (es. test ripetuti), lo eliminiamo per ripartire da un ambiente pulito.
if es.indices.exists(index=indice):
    es.indices.delete(index=indice)

# Creiamo un dizionario Python con le impostazioni del database.
# Traduce in codice le istruzioni che su Kibana si passano tramite JSON.
configurazione_indice = {
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
    },
    "mappings": {
        "properties": {
            "review_id":        { "type": "keyword" },
            "username":         { "type": "keyword" },
            "games_owned":      { "type": "integer" },
            "reviews_written":  { "type": "integer" },
            "recommended":      { "type": "boolean" },
            "playtime_hours":   { "type": "float" },
            "review_text":      { "type": "text", "analyzer": "italian" },
            "helpful_votes":    { "type": "integer" },
            "funny_votes":      { "type": "integer" },
            "created_at":       { "type": "date", "format": "yyyy-MM-dd" }
        }
    }
}

# Inviamo fisicamente la richiesta PUT al server Elasticsearch per creare la struttura.
es.indices.create(index=indice, body=configurazione_indice)
print(f"[*] Indice '{indice}' creato con successo.")

# ==============================================================================
# 3. INGESTIONE MASSIVA DEI DATI (BULK INSERT)
# ==============================================================================
recensioni = [
    {"review_id": "REV-001", "username": "Gen X Hero", "games_owned": 196, "reviews_written": 16, "recommended": False, "playtime_hours": 198.3, "review_text": "ATTENZIONE IL GIOCO NON HA MAPPA INGAME\nGirare a ♥♥♥♥♥ in mappe enormi senza vederne i limiti, dove puoi o non puoi andare è frustrantissimo. Gia acquistai a ♥♥♥♥♥ e disinstallato dopo poco per lo stesso motivo Lies of P(uttanata galattica). Stavolta mi sono fatto prendere dall'hype di 2 amici Über esaltati dal gioco, e l'ho comprato alla cieca senza fare la domanda \"ma c'è la mappa ingame?\" ed eccomi qua, dopo un oretta di bestemmie vado a cena con il gioco in pausa, quando torno stabilito che non è per me chiedo il rimborso, ma sono passate 4 ore che steam considera \"di gioco\" e oltre le 2, niente rimborso, 50 euro buttati letteralmente nel cesso... oggi ho riprovato a proseguire il gioco, ma niente per quanto bello a livello grafico, e meccanica di combattimento l'assenza di mappa/minimappa e l'estenuante francofonicità lo rendono un gioco da cui stare alla larga. Grazie per avermi risolto i dubbi se dedicarmi a questo o a Oblivion Remaster... un po meno per i 50 euro..", "helpful_votes": 5, "funny_votes": 11, "created_at": "2025-05-02"},
    {"review_id": "REV-002", "username": "Pruld", "games_owned": 667, "reviews_written": 22, "recommended": True, "playtime_hours": 59.2, "review_text": "Lune è scalsa 10/10 ✌", "helpful_votes": 4, "funny_votes": 9, "created_at": "2025-04-29"},
    {"review_id": "REV-003", "username": "MasterBaku", "games_owned": 120, "reviews_written": 16, "recommended": False, "playtime_hours": 19.8, "review_text": "Non riesco davvero a spiegarmi da dove provengano le lodi a reti unificate che vengono fatte a questo gioco. Sarà pur sì un JRPG dalle meccaniche reattive e originali, ma è più frustrante man mano che si va avanti con il gioco. Se non vi piace il genere e lo comprate solamente perché ne avete sentito parlare bene, diffidate e risparmiate i vostri soldi fino a che non scenderà di prezzo. D'altro canto, se voi siete amanti di giochi come Elden Ring, Dark Souls, Wukong ecc. penso che potreste apprezzare un titolo così.\nLe due meccaniche fondamentali, ossia i parry e le schivate, sono assolutamente fatte a caso. Devi avere del tempismo sovrumano per parare i colpi che a volte senza alcun preavviso sono one-shot. E non solo! Magari riesci pure a capire quali sono gli schemi dell'avversario e quindi a capire quando effettuare le parate, ma spesso cambiano pure quelli! A volte devi parare un millisecondo prima, a volte dopo ma tutto nella stessa combo di attacco. Alcuni nemici hanno un sound-cue ma sono veramente pochi.\nNon mi dilungo neanche sulle ambientazioni, che sono sì ben fatte ma ci si perde in un attimo visto che non c'è alcun tipo di minimappa, ed è molto facile girare in tondo pensando di star esplorando una nuova zona.", "helpful_votes": 6, "funny_votes": 8, "created_at": "2025-05-16"},
    {"review_id": "REV-004", "username": "PhilNox", "games_owned": 567, "reviews_written": 2, "recommended": True, "playtime_hours": 59.5, "review_text": "Il Final Fantasy che tutti noi ci meritavamo da almeno 20 anni, l’han dovuto fare 30 francesi ex Ubizozz ... brava Squex", "helpful_votes": 57, "funny_votes": 8, "created_at": "2025-04-28"},
    {"review_id": "REV-005", "username": "Lollo", "games_owned": 110, "reviews_written": 10, "recommended": True, "playtime_hours": 46.2, "review_text": "Questo gioco è così bello che non solo l'ho comprato due volte (la prima su PS5), è andato oltre l'impossibile, mi ha fatto piacere la Fr*ncia", "helpful_votes": 11, "funny_votes": 7, "created_at": "2025-05-20"},
    {"review_id": "REV-006", "username": "Salem", "games_owned": 45, "reviews_written": 8, "recommended": False, "playtime_hours": 0.9, "review_text": "Anche se ho giocato per solo 1 ora, skippando ogni cutscene, e cercando di fare quanti più combattimenti possibili, personalmente non ho gradito questo titolo. Sono un grandissimo amante degli RPG a turni sin da quando ero piccolo, ma questo titolo l'ho trovato veramente deludente. Il gioco ruota quasi totalmente intorno alle meccaniche di schivata e parata. Tutto questo è l'antitesi di un RPG a turni, dove la componente strategica passa totalmente in secondo piano.", "helpful_votes": 4, "funny_votes": 7, "created_at": "2025-05-19"},
    {"review_id": "REV-007", "username": "NikoNK", "games_owned": 1407, "reviews_written": 82, "recommended": True, "playtime_hours": 121.9, "review_text": "Un gioco incredibile e un must have per tutti gli amanti dei classici RPG, si può regolare la difficoltà se non siete amanti di parate e schivate ma imparare il pattern di un nemico e evitare tutto quello che lancia da enorme soddisfazione. Musica MAGISTRALE e storia eccezionale.", "helpful_votes": 6, "funny_votes": 6, "created_at": "2025-11-25"},
    {"review_id": "REV-008", "username": "mcdradi", "games_owned": 19, "reviews_written": 7, "recommended": True, "playtime_hours": 77.8, "review_text": "Degno della trilogia: Paint, Paint 3D, Clair Obscur: Expedition 33.\nHo iniziato questo gioco senza aver provato prima gli altri 32 capitoli, forse prima o poi li recupererò.", "helpful_votes": 3, "funny_votes": 5, "created_at": "2025-06-12"},
    {"review_id": "REV-009", "username": "Gala", "games_owned": 65, "reviews_written": 2, "recommended": False, "playtime_hours": 37.9, "review_text": "Non ho voluto guardare gameplay o recensioni per godermi l'esperienza di cui ho sentito molto parlare, acquistato poco dopo il lancio, ma risulta ingiocabile per via di crash continui. su 3 ore il tempo effettivo di gioco sarà si o no 1 ora.", "helpful_votes": 5, "funny_votes": 5, "created_at": "2025-05-07"},
    {"review_id": "REV-010", "username": "xTanjiro97", "games_owned": 87, "reviews_written": 29, "recommended": True, "playtime_hours": 30.9, "review_text": "La storia è intensa, malinconica e riesce a creare un’atmosfera unica dall’inizio alla fine. I temi del tempo, della perdita e della paura di sparire sono trattati in modo impeccabile e maturo.", "helpful_votes": 1, "funny_votes": 0, "created_at": "2025-05-29"},
    {"review_id": "REV-011", "username": "ona88", "games_owned": 50, "reviews_written": 5, "recommended": True, "playtime_hours": 150.8, "review_text": "Questo gioco è PERFETTO.\nStoria.\nMusica.\nAmbientazione.\nSistema di combattimento.\nHo amato TUTTO.", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-28"},
    {"review_id": "REV-012", "username": "omegaskin04100", "games_owned": 30, "reviews_written": 1, "recommended": True, "playtime_hours": 66.8, "review_text": "E una esperienza unica consigliato a tutti", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-24"},
    {"review_id": "REV-013", "username": "Seypher", "games_owned": 105, "reviews_written": 10, "recommended": True, "playtime_hours": 103.3, "review_text": "Veramente un bel gioco. Pesantuccio per il mio PC ma le tecnologie inserite si gioca bene. Combat system veramente ben studiato e davvero bello.", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-15"},
    {"review_id": "REV-014", "username": "Ygnis", "games_owned": 40, "reviews_written": 3, "recommended": True, "playtime_hours": 80.5, "review_text": "Ho dovuto ricomprarlo dopo averlo giocato in game pass semplicemente per supportare il lavoro incredibile degli sviluppatori, questo dice tutto sulla bellezza del videogioco", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-12"},
    {"review_id": "REV-015", "username": "MarcoT_T", "games_owned": 92, "reviews_written": 40, "recommended": True, "playtime_hours": 39.9, "review_text": "Un capolavoro! Storia pazzesca, world building accattivante e combattimento soddisfacente.\nPeccato per l'UE5 che si conferma un mattone da far girare, ma tant'è.", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-10"},
    {"review_id": "REV-016", "username": "manuel82palmas", "games_owned": 25, "reviews_written": 1, "recommended": True, "playtime_hours": 168.3, "review_text": "Bellissimo sotto ogni aspetto, le meccaniche di gioco sono perfette! Non serve per forza il controller per giocare, è consigliato ma chi è abituato o si trova meglio con mouse e tastiera può stare tranquillo.", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-07"},
    {"review_id": "REV-017", "username": "Breezen", "games_owned": 60, "reviews_written": 1, "recommended": True, "playtime_hours": 100.0, "review_text": "Uno dei migliori RPG a cui ho giocato di recente. Ha rivitalizzato il sistema a turni, rendendo ogni incontro dinamico attraverso l'aggiunta di schivate e parate, trasformando quella che di solito è una fase passiva negli RPG in qualcosa di profondamente attivo.", "helpful_votes": 0, "funny_votes": 0, "created_at": "2025-06-06"},
    {"review_id": "REV-018", "username": "Hyp3r_Prestige", "games_owned": 80, "reviews_written": 12, "recommended": True, "playtime_hours": 52.6, "review_text": "Tutti ex dipendenti di Ubisoft... Quando il talento delle singole persone viene castrato dalle multinazionali.\nBRAVIIIII!!! Miglior gioco di ruolo 2025💪🏼", "helpful_votes": 20, "funny_votes": 0, "created_at": "2025-04-27"},
    {"review_id": "REV-019", "username": "Raziel", "games_owned": 150, "reviews_written": 18, "recommended": True, "playtime_hours": 34.3, "review_text": "Su questo gioco c'è poco da dire...nel senso che è difficile esprimere concetti chiave senza far trasparire anche alla lontana piccoli spoiler sull'esperienza. Quello che però sorprende maggiormente dell'opera di Sandfall Interactive è la qualità della scrittura.", "helpful_votes": 29, "funny_votes": 0, "created_at": "2025-05-19"},
    {"review_id": "REV-020", "username": "Francyz", "games_owned": 343, "reviews_written": 24, "recommended": True, "playtime_hours": 58.6, "review_text": "Claire Obscure: expedition 33, è ciò che spero ogni azienda vede come prossima vetta da raggiungere, se nier era un 9.5 questo è un palese 10. Trama? Unica, stupenda emozionante.", "helpful_votes": 15, "funny_votes": 0, "created_at": "2025-12-02"},
    {"review_id": "REV-021", "username": "Centos", "games_owned": 99, "reviews_written": 14, "recommended": True, "playtime_hours": 61.3, "review_text": "Questo gioco è qualcosa di assurdo, l'ho amato in ogni minimo dettaglio portandomi addirittura al mio primo platino. Ost, personaggi, ambientazioni, tutto fantastico. Il fatto che nei dungeon non ci sia la minimappa non è un errore anzi, sei un esploratore e visiti per la prima volta quei posti. Per me, un gioco cosi non ci sarà mai più. Amatelo come ho fatto io.\nVoto finale 10/10", "helpful_votes": 41, "funny_votes": 0, "created_at": "2025-05-06"},
    {"review_id": "REV-022", "username": "illy4691", "games_owned": 210, "reviews_written": 31, "recommended": True, "playtime_hours": 80.5, "review_text": "Non un gioco, ma una storia profonda.\nNon un gioco, ma un'avventura coinvolgente.\nNon un gioco, ma un'esperienza unica.\nNon un gioco, ma una riflessione sulla vita, sulla morte e su ciò che essa lascia dietro di sé. Ciò che lascia alle persone che ci amano, il tremendo peso del lutto e tutto ciò che ne comporta.\nClair Obscur: Expedition 33 racconta questo e tanto altro, accompagnato da una colonna sonora che ti resta nella testa e che spesso ti fa interrompere un combattimento solo per goderti quelle note, e resti lì fermo (a volte ballando sulla sedia) invece di colpire i nemici a suon di fioretto.\nFatevi un favore e giocate questa perla videoludica, anche se non siete amanti dei combattimenti a turni (io non lo sono). Non guardate streaming di Clair Obscur e non leggete la storia su internet, ma prendetelo e giocatelo. VIVETELO. Che, fidatevi, giochi così non ne escono più così spesso. Pochi giochi son capaci di lasciare un vuoto dopo averli terminati. Con Clair Obscur mi è successo.\nNon un gioco,\nma arte.", "helpful_votes": 44, "funny_votes": 4, "created_at": "2025-11-26"},
    {"review_id": "REV-023", "username": "SkyCaptainITA", "games_owned": 846, "reviews_written": 50, "recommended": True, "playtime_hours": 36.2, "review_text": "Non sono proprio il tipo da JRPG, ma questo Clair Obscure: Expedition 33 è praticamente una poesia fatta videogioco.\nEtichettato da molti come gioco Indie, ma a mio avviso uno dei più grandi titoli degli ultimi anni.\nNon è solamente il reparto grafico a stupire (a giudicare dalle immagini in anteprima su Steam), ma proprio con tutto quello che un videogioco ha da offrire: musiche, gameplay, reparto artistico, storia, ecc...\nStupendo letteralmente sotto tutti i punti di vista, soprattutto il gameplay che finalmente non è il solito gioco a turni \"passivo\" che alla lunga, almeno personalmente, può annoiare. Qui è necessario essere attivi, in quanto occorre schivare o parare i colpi in arrivo e azzeccare i QTE per gli attacchi.\nVeramente geniale.", "helpful_votes": 40, "funny_votes": 1, "created_at": "2025-04-28"},
    {"review_id": "REV-024", "username": "TurnBasedLover99", "games_owned": 142, "reviews_written": 12, "recommended": True, "playtime_hours": 45.5, "review_text": "Un JRPG che rivoluziona il combattimento a turni. La meccanica reattiva tiene sempre sulle spine e la direzione artistica è letteralmente da togliere il fiato. La storia affronta tematiche mature sull'esistenza e la perdita in modo eccellente. Ottimo, ma ci si passa sopra.", "helpful_votes": 87, "funny_votes": 2, "created_at": "2025-06-15"},
    {"review_id": "REV-025", "username": "GitGud_OrDie", "games_owned": 315, "reviews_written": 41, "recommended": False, "playtime_hours": 14.2, "review_text": "Troppo frustrante e bilanciato malissimo. I parry hanno finestre di tempo illeggibili e la mancanza di una minimappa rende l'esplorazione nei dungeon un vero incubo. Peccato perché l'Unreal Engine 5 fa la sua figura, ma ho chiesto il rimborso dopo aver perso ore a girare in tondo.", "helpful_votes": 45, "funny_votes": 12, "created_at": "2025-05-22"},
    {"review_id": "REV-026", "username": "StoryTeller_ITA", "games_owned": 89, "reviews_written": 5, "recommended": True, "playtime_hours": 68.0, "review_text": "Trama indimenticabile e personaggi scritti divinamente. Il sistema di combattimento ibrido è la ciliegina sulla torta, anche se richiede un po' di abitudine se si viene dai classici giochi a turni statici. La colonna sonora è un 10/10 assoluto. Giocatelo, è pura arte.", "helpful_votes": 120, "funny_votes": 0, "created_at": "2025-08-03"},
    {"review_id": "REV-027", "username": "CrashTestDummy", "games_owned": 56, "reviews_written": 2, "recommended": False, "playtime_hours": 4.1, "review_text": "Il gioco sarebbe anche bello se non fosse letteralmente ingiocabile. Crash continui ogni 20 minuti con un 'fatal error'. Ho un PC di fascia alta e non riesco a proseguire. Aggiornerò la recensione se si degneranno di far uscire una patch che risolva il problema.", "helpful_votes": 34, "funny_votes": 1, "created_at": "2025-05-10"},
    {"review_id": "REV-028", "username": "PixelHunter", "games_owned": 512, "reviews_written": 134, "recommended": True, "playtime_hours": 110.5, "review_text": "Platinato! L'esplorazione cieca senza indicatori giganti a schermo ti fa sentire un vero pioniere. Bisogna imparare bene i pattern dei nemici, altrimenti le boss fight opzionali sono impossibili. Un'esperienza che ogni amante dei giochi di ruolo dovrebbe provare almeno una volta.", "helpful_votes": 210, "funny_votes": 5, "created_at": "2025-11-20"},
    {"review_id": "REV-029", "username": "RPG_Master88", "games_owned": 204, "reviews_written": 45, "recommended": True, "playtime_hours": 55.2, "review_text": "Design dei mostri da urlo. Mi ha ricordato tantissimo le atmosfere di alcuni classici per PS1 ma con una veste grafica moderna. La progressione del party è appagante e non richiede grinding eccessivo.", "helpful_votes": 12, "funny_votes": 0, "created_at": "2025-07-11"},
    {"review_id": "REV-030", "username": "ZeroFPS", "games_owned": 12, "reviews_written": 3, "recommended": False, "playtime_hours": 6.5, "review_text": "Pessima ottimizzazione. Su Steam Deck gira malissimo, non riesce a mantenere i 30 fps stabili neanche abbassando tutto al minimo. Sconsiglio l'acquisto a chi gioca in portabilità.", "helpful_votes": 88, "funny_votes": 2, "created_at": "2025-05-15"},
    {"review_id": "REV-031", "username": "LoreSeeker", "games_owned": 95, "reviews_written": 10, "recommended": True, "playtime_hours": 89.0, "review_text": "Ogni documento trovato nel gioco espande un mondo di gioco incredibilmente vasto e affascinante. La direzione artistica in stile belle époque mescolata al fantasy oscuro è un connubio che funziona alla perfezione.", "helpful_votes": 34, "funny_votes": 0, "created_at": "2025-09-02"},
    {"review_id": "REV-032", "username": "CasualGamer92", "games_owned": 40, "reviews_written": 1, "recommended": True, "playtime_hours": 32.1, "review_text": "Ho provato questo gioco quasi per caso grazie ai consigli di un amico e ne sono rimasto stregato. Mai giocato un JRPG prima d'ora, ma questo mi ha fatto innamorare del genere.", "helpful_votes": 5, "funny_votes": 0, "created_at": "2025-08-14"},
    {"review_id": "REV-033", "username": "HardcoreFan", "games_owned": 410, "reviews_written": 230, "recommended": False, "playtime_hours": 15.0, "review_text": "Piatto, noioso e ripetitivo. Il sistema di parata sembra una forzatura inserita solo per cavalcare l'onda dei souls-like. Preferivo un sistema a turni puro e strategico.", "helpful_votes": 14, "funny_votes": 6, "created_at": "2025-06-01"},
    {"review_id": "REV-034", "username": "Art_of_Game", "games_owned": 77, "reviews_written": 8, "recommended": True, "playtime_hours": 62.4, "review_text": "I paesaggi sono quadri in movimento. Ho passato più tempo nella modalità foto che a combattere. Sandfall Interactive ha creato un vero e proprio capolavoro visivo.", "helpful_votes": 102, "funny_votes": 1, "created_at": "2025-07-22"},
    {"review_id": "REV-035", "username": "NoMapNoParty", "games_owned": 133, "reviews_written": 15, "recommended": False, "playtime_hours": 8.5, "review_text": "Mi sono perso per tre ore di fila nello stesso dungeon perché ogni corridoio sembra identico all'altro e non c'è una mappa. Level design da rivedere completamente.", "helpful_votes": 56, "funny_votes": 8, "created_at": "2025-05-18"},
    {"review_id": "REV-036", "username": "SoundTrackLover", "games_owned": 25, "reviews_written": 2, "recommended": True, "playtime_hours": 41.0, "review_text": "La musica dei combattimenti contro i boss mi ha fatto venire i brividi. Il mix di cori epici e strumenti classici accompagna l'azione in modo perfetto. Solo per la colonna sonora merita il prezzo intero.", "helpful_votes": 21, "funny_votes": 0, "created_at": "2025-10-05"},
    {"review_id": "REV-037", "username": "SpeedRunnerITA", "games_owned": 560, "reviews_written": 88, "recommended": True, "playtime_hours": 21.5, "review_text": "Molto divertente da speedrunnare. Le meccaniche di schivata, se padroneggiate, permettono di battere boss di livello molto più alto aggirando le statistiche. Ottimo combat system.", "helpful_votes": 42, "funny_votes": 3, "created_at": "2025-08-30"},
    {"review_id": "REV-038", "username": "Disappointed_99", "games_owned": 190, "reviews_written": 4, "recommended": False, "playtime_hours": 11.2, "review_text": "I nemici diventano delle vere e proprie spugne per i danni nella seconda metà del gioco. Il combat system divertente all'inizio diventa una fatica immane dopo la ventesima ora.", "helpful_votes": 29, "funny_votes": 0, "created_at": "2025-07-09"},
    {"review_id": "REV-039", "username": "EmotionalDamage", "games_owned": 67, "reviews_written": 12, "recommended": True, "playtime_hours": 75.3, "review_text": "Ho pianto come un bambino durante il finale. Non mi succedeva dai tempi del primo The Last of Us. Preparate i fazzoletti.", "helpful_votes": 150, "funny_votes": 2, "created_at": "2025-12-15"},
    {"review_id": "REV-040", "username": "TechGeek", "games_owned": 310, "reviews_written": 55, "recommended": True, "playtime_hours": 48.9, "review_text": "Unreal Engine 5 sfruttato al massimo, illuminazione globale Lumen impressionante. Certo, serve una 4080 per farlo girare bene in 4K, ma lo spettacolo visivo è garantito.", "helpful_votes": 65, "funny_votes": 0, "created_at": "2025-06-20"},
    {"review_id": "REV-041", "username": "GamerDad", "games_owned": 45, "reviews_written": 6, "recommended": True, "playtime_hours": 92.0, "review_text": "Gioco perfetto per chi ha poco tempo la sera. Si può salvare ovunque, le missioni sono ben cadenzate e la storia ti tiene incollato. Complimenti agli sviluppatori.", "helpful_votes": 81, "funny_votes": 0, "created_at": "2025-11-01"},
    {"review_id": "REV-042", "username": "TurnHater", "games_owned": 80, "reviews_written": 10, "recommended": False, "playtime_hours": 5.4, "review_text": "L'ho comprato sperando che la meccanica action compensasse i turni. Purtroppo resta un gioco lento in cui si aspetta troppo il proprio turno. Restituito subito.", "helpful_votes": 12, "funny_votes": 18, "created_at": "2025-05-25"},
    {"review_id": "REV-043", "username": "FrenchTouch", "games_owned": 112, "reviews_written": 20, "recommended": True, "playtime_hours": 50.0, "review_text": "Si vede il tocco europeo nello stile artistico. Un'opera magnifica che si distacca dai classici canoni giapponesi portando una ventata d'aria fresca nel genere.", "helpful_votes": 44, "funny_votes": 0, "created_at": "2025-07-28"},
    {"review_id": "REV-044", "username": "BugHunter", "games_owned": 240, "reviews_written": 90, "recommended": False, "playtime_hours": 22.1, "review_text": "Troppi bug rovinano l'immersione. Personaggi che si compenetrano, texture che caricano in ritardo e un crash al desktop durante il boss del terzo capitolo mi hanno fatto desistere.", "helpful_votes": 37, "funny_votes": 0, "created_at": "2025-06-11"},
    {"review_id": "REV-045", "username": "NarrativeFirst", "games_owned": 95, "reviews_written": 14, "recommended": True, "playtime_hours": 60.5, "review_text": "Scrittura brillante, doppiaggio eccellente (anche se manca l'italiano per le voci, i sottotitoli sono ottimi). I compagni di squadra non sono semplici marionette, hanno una vera anima.", "helpful_votes": 76, "funny_votes": 0, "created_at": "2025-09-18"},
    {"review_id": "REV-046", "username": "RetroGamer80s", "games_owned": 700, "reviews_written": 150, "recommended": True, "playtime_hours": 105.0, "review_text": "Mi ha fatto ritrovare le sensazioni di quando giocavo a Final Fantasy VIII sulla mia prima PlayStation. Magico, nostalgico ma estremamente moderno nelle meccaniche.", "helpful_votes": 200, "funny_votes": 4, "created_at": "2025-10-30"},
    {"review_id": "REV-047", "username": "SkillIssue_99", "games_owned": 23, "reviews_written": 2, "recommended": False, "playtime_hours": 18.0, "review_text": "Eccessivamente punitivo. Capisco voler aggiungere sfida ai combattimenti a turni, ma i boss secondari shottano senza appello. Frustrazione pura.", "helpful_votes": 22, "funny_votes": 15, "created_at": "2025-08-11"},
    {"review_id": "REV-048", "username": "MaxLevel_Cap", "games_owned": 160, "reviews_written": 34, "recommended": True, "playtime_hours": 85.5, "review_text": "Ottimo sistema di progressione e build variegate. Puoi davvero personalizzare l'approccio ai combattimenti, puntando tutto sulla difesa passiva o sui riflessi del giocatore.", "helpful_votes": 55, "funny_votes": 0, "created_at": "2025-11-05"},
    {"review_id": "REV-049", "username": "CinematicFan", "games_owned": 54, "reviews_written": 7, "recommended": True, "playtime_hours": 44.4, "review_text": "Le cutscene sono dirette meglio di molti film usciti al cinema quest'anno. La regia virtuale di Sandfall è da manuale.", "helpful_votes": 90, "funny_votes": 1, "created_at": "2025-12-08"},
    {"review_id": "REV-050", "username": "FinalVerdict", "games_owned": 188, "reviews_written": 27, "recommended": True, "playtime_hours": 70.2, "review_text": "Nonostante qualche incertezza tecnica iniziale legata all'Unreal Engine 5, le patch hanno sistemato gran parte dei problemi. Rimane uno dei titoli più solidi e artistici di questo 2025.", "helpful_votes": 130, "funny_votes": 0, "created_at": "2025-12-20"}
]

# Per evitare di fare 50 chiamate HTTP singole, usiamo la libreria 'helpers' di ES 
# per inviare tutto in un unico grande blocco (Bulk Insert). Molto più performante.
azioni = [
    {
        "_index": indice,
        "_id": recensione["review_id"], # Forziamo l'ID del documento a coincidere con il nostro ID personalizzato
        "_source": recensione           # Il corpo del documento JSON
    }
    for recensione in recensioni
]
helpers.bulk(es, azioni)

# Forziamo il refresh dell'indice. ES è "Near Real Time", di default ci mette 1 secondo a rendere ricercabili i dati.
# Noi lo costringiamo a indicizzare istantaneamente prima di passare alle query.
es.indices.refresh(index=indice)
print(f"[*] Inseriti con successo {len(recensioni)} documenti nell'indice '{indice}'.\n")


# ==============================================================================
# 4. ESECUZIONE DELLE QUERY E STAMPA DEI RISULTATI
# ==============================================================================

print("=" * 80)
print(" QUERY 1: AGGREGAZIONE - Sentiment (% Consigliato vs Non Consigliato)")
print("=" * 80)
query_1 = {
    "size": 0, 
    "aggs": {
        "divisione_sentiment": {
            "terms": { "field": "recommended" }
        }
    }
}
risultato_1 = es.search(index=indice, body=query_1)

# Estraiamo i "secchielli" (buckets) in cui ES ha raggruppato i dati
buckets = risultato_1["aggregations"]["divisione_sentiment"]["buckets"]

# La matematica la fa Python (Separation of Concerns)
totale_recensioni_analizzate = sum(b['doc_count'] for b in buckets)

for b in buckets:
    stato = "CONSIGLIATO" if b["key"] == 1 else "NON CONSIGLIATO"
    valore_assoluto = b["doc_count"]
    percentuale = (valore_assoluto / totale_recensioni_analizzate) * 100
    print(f"-> Voti {stato}: {valore_assoluto} (Pari al {percentuale:.1f}%)")


print("\n" + "=" * 80)
print(" QUERY 2: RICERCA FULL-TEXT - Recensioni che citano la 'mappa'")
print("=" * 80)
query_2 = {
    "query": {
        "match": { "review_text": "mappa" }
    }
}
risultato_2 = es.search(index=indice, body=query_2)

# Estraiamo l'array dei documenti che matchano la ricerca navigando il JSON di risposta: hits -> hits
for doc in risultato_2["hits"]["hits"]:
    # Stampo l'username e il testo integrale senza limitazioni
    print(f"[{doc['_source']['username']}] -> {doc['_source']['review_text']}\n")


print("\n" + "=" * 80)
print(" QUERY 3: FILTRO RANGE E ORDINAMENTO - Recensioni più influenti (Voti Utili >= 100)")
print("=" * 80)
query_3 = {
    "query": {
        "range": { "helpful_votes": { "gte": 100 } }
    },
    "sort": [ { "helpful_votes": { "order": "desc" } } ]
}
risultato_3 = es.search(index=indice, body=query_3)
for doc in risultato_3["hits"]["hits"]:
    print(f"[{doc['_source']['helpful_votes']} Voti] {doc['_source']['username']} (Consigliato: {doc['_source']['recommended']})")


print("\n" + "=" * 80)
print(" QUERY 4: QUERY BOOLEANA COMPLESSA - Ricerca 'JRPG' filtrata SOLO per recensioni POSITIVE")
print("=" * 80)
query_4 = {
    "query": {
        "bool": {
            "must": [ { "match": { "review_text": "jrpg" } } ],
            "filter": [ { "term": { "recommended": True } } ]
        }
    }
}
risultato_4 = es.search(index=indice, body=query_4)
for doc in risultato_4["hits"]["hits"]:
    # Stampo l'username e il testo integrale senza limitazioni
    print(f"- {doc['_source']['username']}: {doc['_source']['review_text']}\n")

print("\n[*] Esecuzione terminata.")
