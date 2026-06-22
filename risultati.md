# Appartamenti che rispettano tutti i criteri

Ultimo aggiornamento: 2026-06-22 (full batch processing)

## Riepilogo criteri attivi

- Località: Milano
- Posti letto: ≥ 3 (3 singole oppure 1 matrimoniale + 1 singola)
- Metratura: ≥ 25 m²/persona (75 m² totali)
- Disponibilità: entro 14 settembre 2026
- Prezzo: ≤ 1500 €/mese tutto incluso (3 persone)
- Dotazioni: divano, wifi, riscaldamento, lavatrice
- Trasporti: metro entro 7 min a piedi
- Università: < 40 min da Bicocca **e** da Bovisa

---

## Nota run 2026-06-22 (batch completo cache — script PowerShell deterministico)

**Elaborazione completa dei 125 annunci in cache** (casa-it: 20, immobiliare: 5, subito: 100)
tramite `process_listings.ps1` (filtri 1→7 deterministici, dedup su `analizzati.json`):

- **cache totale**: 125 · **già analizzati** (run precedenti): 33 · **nuovi processati**: 92
- **accettati: 0** · **scartati: 92**

Riassunto scarto per filtro:

| Filtro | Conteggio |
|--------|-----------|
| F1 (posti letto/locali < 3) | 69 |
| F2 (metratura < 75 m²) | 7 |
| F3 (disponibilità oltre 14/09/2026) | 1 |
| F4 (prezzo > 1500 € o non dichiarato) | 8 |
| F5 (dotazioni obbligatorie wifi/lavatrice non menzionate nel dataset) | 6 |
| F6/7 (passa 1–5; tempi metro/università da verificare a mano) | 1 |
| **TOTALE** | **92** |

**Analisi**: il **filtro 1 (posti letto)** resta il più selettivo (75% degli scarti) —
il dataset odierno è dominato da bilocali/monolocali. **Un solo annuncio** (subito-650215305,
trilocale 80 m² a 1.400 € in zona Bicocca) ha superato i filtri 1–5 fermandosi a F6/7 (tempi
metro e distanza università non calcolabili dal dataset Apify): è il candidato prioritario da
verificare a mano. I 6 annunci fermati al **filtro 5** sono trilocali/quadrilocali ≥75 m²
entro budget la cui unica lacuna è la **mancata menzione di wifi/lavatrice** nei dati Apify.
Gli 8 scarti per F4 sono per lo più appartamenti centrali (Brera, Porta Romana, Solari) ben
oltre 1.500 €.

---

## Nota run 2026-06-20 (batch completo cache — script PowerShell deterministico)

**Elaborazione completa dei 255 annunci in cache** (casa-it: 150, immobiliare: 5, subito: 100)
tramite `process_listings.ps1` (filtri 1→7 deterministici, dedup su `analizzati.json`):

- **cache totale**: 255 · **già analizzati** (run precedenti): 74 · **nuovi processati**: 181
- **accettati: 0** · **scartati: 181**

Riassunto scarto per filtro:

| Filtro | Conteggio |
|--------|-----------|
| F1 (posti letto/locali < 3) | 83 |
| F2 (metratura < 75 m²) | 17 |
| F4 (prezzo > 1500 € o non dichiarato) | 46 |
| F5 (dotazioni obbligatorie wifi/lavatrice non menzionate nel dataset) | 35 |
| **TOTALE** | **181** |

**Analisi**: nessun annuncio ha passato i filtri 1–5, quindi i filtri 6–7 (metro ≤7 min,
università <40 min — non calcolabili dal dataset Apify) non sono stati raggiunti.
Il filtro 1 (posti letto) resta il più selettivo (46% degli scarti). I 35 annunci
fermati al **filtro 5** sono trilocali ≥75 m² entro budget la cui unica lacuna è la
**mancata menzione di wifi/lavatrice nei dati Apify**: sono i candidati alternativi
prioritari (verifica manuale delle dotazioni → vedi sezione in fondo). Diversi tra
questi sono però in **comuni esterni** (Rho, Legnano, Cerro Maggiore, Opera, Cologno
Monzese) che andranno comunque verificati anche sul **filtro 7** (tempi università).

---

## Nota run 2026-05-17 (23:50 - full reprocessing con filtri binari)

**Reprocessing completo dei 355 annunci in cache** con script deterministico PowerShell:

- **Casa.it** (150): 0 nuovi (150 già analizzati da run precedente) → tutti scartati al filtro 1
- **Idealista** (100): 1 nuovo → scartato al filtro 1 (bilocale)
- **Immobiliare** (5): 5 nuovi → tutti scartati al filtro 1 (bilocali/monolocali)
- **Subito** (100): 1 nuovo → scartato al filtro 1

**Totale run**: 7 annunci nuovi elaborati, **0 accettati, 7 scartati al filtro 1** (posti letto < 3).

**Conclusione**: I filtri 1 e 2 (posti letto e metratura) rimangono i più selettivi. Nessun trilocale/quadrilocale nei nuovi annunci odierni. La dataset oggi contiene prevalentemente bilocali (2 camere).

---

## Nota run 2026-05-17 (batch completo cache)

**Elaborazione completa dei 350 annunci in cache** (casa-it: 150, idealista: 100, subito: 100):

- **Casa.it** (150): 150 già analizzati da run precedente → 150 scartati al filtro 1 (posti letto < 3)
- **Idealista** (100): 100 nuovi → **0 accettati, 100 scartati**
  - Filtro 1 (posti letto < 3): 97 bilocali/monolocali
  - Filtro 2 (metratura < 75 m²): 3 annunci
- **Subito** (100): 100 nuovi → **0 accettati, 100 scartati**
  - Filtro 1 (posti letto < 3): 26 annunci
  - Filtro 2 (metratura < 75 m²): 62 annunci
  - Filtro 4 (prezzo > 1500€): 12 annunci

**Totale run**: 362 annunci analizzati, **0 accettati, 200 nuovi scartati**. Riassunto scarto per portale:

| Filtro | Casa.it | Idealista | Subito | Totale |
|--------|---------|-----------|--------|--------|
| F1 (posti letto) | 150 | 97 | 26 | 273 |
| F2 (metratura) | — | 3 | 62 | 65 |
| F4 (prezzo) | — | — | 12 | 12 |
| **TOTALE** | **150** | **100** | **100** | **350** |

**Analisi**: Il filtro più selettivo è il **filtro 1 (posti letto)** che esclude il 78% degli annunci (273/350). Idealista contiene prevalentemente bilocali; Subito contiene prevalentemente monolocali + bilocali con metratura insufficiente. Nessun portale ha fornito annunci trilocali/quadrilocali entro il budget nella data odierna.

## Log run

| Data | Annunci nuovi analizzati | Accettati | Scartati |
|------|--------------------------|-----------|---------|
| 2026-06-22 (batch completo cache) | 92 | 0 | 92 |
| 2026-06-20 (batch completo cache) | 181 | 0 | 181 |
| 2026-05-25 (batch completo cache) | 121 | 0 | 121 |
| 2026-05-17 (23:50 reprocessing) | 7 | 0 | 7 |
| 2026-05-17 (batch completo cache) | 200 | 0 | 200 |
| 2026-05-17 (21:21) Idealista/Subito | 2 | 0 | 2 |
| 2026-05-17 (21:16) Casa.it + Subito reprocessing | 0 | 0 | 0 |
| 2026-05-17 (22:30) Idealista.it | 50 | 0 | 50 |
| 2026-05-17 (21:15) Apify batch reprocessed | 105 | 0 | 105 |
| 2026-05-17 (14:30) Apify batch | 105 | 0 | 105 |
| 2026-05-17 (09:00) Apify | 105 | 0 | 105 |
| 2026-05-17 (23:45) | 3 | 0 | 3 |
| 2026-05-17 (14:00) | 0 | 0 | 0 |
| 2026-05-17 (10:30) | 3 | 0 | 3 |
| 2026-05-16 | 12 | 0 | 12 |

**Nota run 2026-05-17 (21:21) — Elaborazione Idealista + Subito nuovi**: Dataset Idealista e Subito sono stati rielaborati. Risultato: **2 annunci nuovi analizzati, 0 accettati, 2 scartati**:
  - idealista: 1 annuncio da Via dei Missaglia (bilocale 2 camere) — scartato al **filtro 1** (posti letto insufficienti, solo 2 camere invece di 3)
  - subito: 1 annuncio senza URL valido — scartato al **filtro 2** (metratura non dichiarata, non verificabile)

**Analisi**: L'annuncio Idealista è un bilocale con prezzo potenzialmente buono che merita verifica manuale per accertare se il matrimoniale + singola configuration lo renda compatibile (non disponibile nei dati Apify). Il Subito non ha informazioni sufficienti.

**Nota run 2026-05-17 (21:16) — Casa.it + Subito reprocessing**: I dataset del giorno (casa-it-2026-05-17.json + subito-2026-05-17.json) sono stati riprocessati. Risultato: **0 annunci nuovi analizzati** (tutti i 250 annunci nei cache erano già presenti in analizzati.json da run precedenti). I 250 annunci rimangono **tutti scartati**: 175 al filtro 1 (posti letto < 3), 75 a filtri successivi. Nessun annuncio supera i 7 criteri.

**Nota run 2026-05-17 (22:30) — Idealista.it dataset**: Dataset Idealista contiene 50 annunci, suddivisi come:
  - 26 bilocali (2 camere)
  - 23 monolocali (1 camera)
  - 1 senza dati (0 camere)
  
  Risultato: **0 accettati, 50 scartati al filtro 1** (posti letto insufficienti). Nessun trilocale/quadrilocale nel dataset. **Candidati alternativi**: 3 bilocali con prezzo ≤1.500€ e metratura ≥64 mq (vedi tabella alternative sotto).

**Nota run 2026-05-17 (21:15) — Reprocessing Apify con salvataggio in analizzati.json**: I 105 annunci precedentemente analizzati sono stati riprocessati e salvati in analizzati.json. Risultato: **0 accettati, 105 scartati**:
  - Filtro 1 (posti letto meno di 3): 2 annunci (casa.it)
  - Filtro 2 (metratura meno di 75 mq): 20 annunci  
  - Filtro 4 (prezzo > 1500 euro): 57 annunci
  - Filtro 5 (dotazioni obbligatorie wifi/lavatrice mancanti): 24 annunci
  - Filtri 6-7 (distanze metro/università non verificabili in dataset Apify): 2 annunci
  - **Conclusione**: Il prezzo è il filtro più selettivo (54% degli annunci). Casa.it ha dati dotazioni insufficienti e è stato scartato a filtro 5. Immobiliare.it ha dati più completi ma ancora 0 annunci superano tutti i 7 criteri.

**Nota run 2026-05-17 (14:30) — Batch Processing Apify**: Applicati 7 filtri gerarchici ai 105 annunci Apify (100 casa.it + 5 immobiliare.it) dai file cache. Risultato: **0 accettati, 105 scartati**:
  - Filtro 1 (posti letto meno di 3): 5 annunci
  - Filtro 2 (metratura meno di 75 mq): 20 annunci  
  - Filtro 3 (disponibilità non specificata o oltre 14/09/2026): 80 annunci
  - **Conclusione**: La disponibilità è il filtro più selettivo (76% degli annunci eliminati per non aver data verificabile entro 14/09/2026). Metratura e configurazione letto sono secondari. Nessun annuncio ha passato i primi 3 filtri conservando i dati richiesti per valutare prezzo e dotazioni.

**Nota run 2026-05-17 (09:00) — Apify**: Scraping completo da casa.it (100 annunci) e immobiliare.it (5 annunci). Totale 105 annunci nuovi analizzati, **0 accettati, 105 scartati**:
  - Filtro 4 (prezzo > 1500 €): 44 annunci
  - Filtro 5 (dotazioni mancanti): 43 annunci
  - Filtro 2 (metratura < 75 m²): 21 annunci
  - Filtro 1 (posti letto < 3): 2 annunci
  - Filtro 3 (disponibilità > 14/09/2026): 2 annunci
  - Filtro 6 (metro > 7 min a piedi): 1 annuncio
  - Dati insufficienti: 10 annunci

**Conclusione**: La fascia di prezzo target (≤1500 €/mese tutto incluso) esclude il 42% degli annunci; le dotazioni obbligatorie (divano, wifi, riscaldamento, lavatrice) ne escludono il 41%. Nessun appartamento su 105 nelle cache odierne ha superato tutti i 7 criteri.

**Nota run 2026-05-17 (23:45)**: WebSearch ha trovato 3 annunci nuovi (Via Simone d'Orsenigo, Piazza Aspromonte 51/43). Risultato: 3 annunci analizzati, 3 scartati:
  - immobiliare-115657565 (Via Simone d'Orsenigo, 90 mq, 01/09/2026) — scartato per **dati insufficienti** (prezzo non reperibile)
  - casa-49534568 (Piazza Aspromonte 51, 80 mq, €1.300) — scartato per **dati insufficienti** (disponibilità non specificata; candidato interessante se disponibile ≤14/09/2026)
  - immobiliare-112663923 (Piazza Aspromonte 43, 90 mq, €1.600) — scartato per **filtro 4** (prezzo €1.600 > €1.500)

**Nota run 2026-05-17 (10:30)**: Accesso bloccato dalla sandbox. Apify richiede approvazione di permessi dell'account; i siti immobiliari restituiscono HTTP 403. WebSearch ha trovato 3 URL nuovi (Via Rezia, Via Garegnano, Piazza Filangieri) ma senza dati concreti nei snippet. Risultato: 3 annunci analizzati, 3 scartati (1 per disponibilità ottobre, 2 per dati insufficienti). 

**Nota run 2026-05-17 (14:00)**: Tentato accesso via Apify (bloccato da permessi account), curl diretto (HTTP 403), WebFetch (HTTP 403), WebSearch per snippet. Indagati indirizzi: Via Farini (15 maggio), Famagosta (1 luglio, 1380 €), Piazza Aspromonte (1 agosto). Nessun annuncio con dettagli sufficienti per applicare i 7 filtri. 

**Status**: **Workflow parzialmente bloccato** — la sandbox impedisce l'accesso automatico ai dati dettagliati degli annunci. **Azione richiesta per sbloccare**: 
- Configurare Apify con permessi approvati (approvePermissions=true), oppure
- Usare VPN/proxy per accesso diretto ai portali, oppure
- Fornire dati manualmente / feed API autorizzate.

**Nota run 2026-05-16**: Lo scraping via Apify non è stato possibile per restrizioni di rete della sandbox (api.apify.com e tutti i portali restituiscono HTTP 403). I dati sono stati raccolti tramite WebSearch (snippet Google). Per 12 annunci trovati, nessuno ha superato tutti i 7 filtri. Il candidato più interessante (ZappyRent Piazza dei Daini, Bicocca, 87 mq, 1.400 €, M5 Bignami 2 min, Bicocca 4 min a piedi) è stato scartato al filtro 3 per disponibilità incerta (occupato, nessuna data futura nota). **Da ricontrollare alla prossima run** quando il sito sarà accessibile o l'appartamento risulterà nuovamente disponibile.

## Tabella riassuntiva

| # | Zona | Prezzo (tutto incluso) | m² | Posti letto | Metro a … min | Bicocca | Bovisa | Disponibile dal | Link |
|---|------|------------------------|----|-------------|---------------|---------|--------|------------------|------|
| _(nessun risultato ancora — vedi note run)_ | | | | | | | | | |

## Schede dettagliate

_(le schede compariranno qui quando almeno un appartamento supererà tutti i 7 filtri)_

---

## Candidati alternativi (run 2026-06-22)

Run 2026-06-22: **92 annunci nuovi analizzati, 0 accettati, 92 scartati**
(F1: 69 · F2: 7 · F3: 1 · F4: 8 · F5: 6 · F6/7: 1).

**Profilo filtri**: il dataset odierno è dominato da bilocali/monolocali (F1 = 75% degli
scarti). **Un solo annuncio** ha superato i filtri 1–5 (fermo a F6/7 — tempi non calcolabili
dal dataset). I candidati prioritari qui sotto sono il quasi-accettato (F6/7) e i trilocali/
quadrilocali ≥75 m² entro budget fermati al **filtro 5** solo perché il dataset Apify non
menziona esplicitamente **wifi/lavatrice** — vanno verificati a mano. Seguono gli scarti F4
(sopra budget) con buona metratura, utili solo se il prezzo è negoziabile. Per gli annunci
in **comuni esterni** (Cologno Monzese, Assago) va verificato anche il **filtro 7** (tempi
verso Bicocca e Bovisa).

### Candidati — priorità per verifica manuale

| # | Portale | Zona | Prezzo | m² | Locali | Motivo scarto | Link |
|---|---------|------|--------|----|----|---------------|------|
| 1 | Subito | Milano (Bicocca) | 1.400 € | 80 | 3 | **F6/7: passa 1–5** — verificare tempi metro/università | [link](https://www.subito.it/appartamenti/appartamento-bicocca-milano-650215305.htm) |
| 2 | Subito | Milano | 700 € | 129 | 4 | F5: verificare wifi | [link](https://www.subito.it/appartamenti/4-locali-a-milano-milano-651521193.htm) |
| 3 | Subito | Milano | 1.350 € | 95 | 4 | F5: verificare wifi+lavatrice | [link](https://www.subito.it/appartamenti/4locali-95mq-con-cantina-e-due-camere-da-letto-milano-651643073.htm) |
| 4 | Subito | Cologno Monzese (fuori Milano) | 1.100 € | 90 | 3 | F5: verificare wifi+lavatrice · F7 da verificare | [link](https://www.subito.it/appartamenti/appartamento-di-90-m²-con-3-locali-a-cologno-monze-milano-651533658.htm) |
| 5 | Subito | Milano | 1.420 € | 85 | 3 | F5: verificare wifi+lavatrice | [link](https://www.subito.it/appartamenti/ampio-trilocale-con-due-bagni-milano-651689250.htm) |
| 6 | Immobiliare | Città Studi, Susa | 950 € | 78 | 3 | F5: verificare wifi+lavatrice | [link](https://www.immobiliare.it/annunci/126371749) |
| 7 | Immobiliare | Napoli, Soderini | 1.150 € | 78 | 3 | F5: verificare lavatrice | [link](https://www.immobiliare.it/annunci/126705663) |
| 8 | Casa.it | Porta Romana, Risorgimento | 1.600 € | 85 | 3 | F4: prezzo +100 € sopra limite | [link](https://www.casa.it/immobili/53577181/) |
| 9 | Subito | Assago (fuori Milano) | 1.600 € | 80 | 3 | F4: prezzo +100 € · F7 da verificare | [link](https://www.subito.it/appartamenti/panoramico-trilocale-di-80-mq-al-10-piano-milano-651628029.htm) |
| 10 | Casa.it | Solari-Tortona, Washington | 1.900 € | 85 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54197396/) |
| 11 | Casa.it | Porta Romana, Risorgimento | 2.300 € | 81 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54241405/) |
| 12 | Casa.it | Porta Romana, Risorgimento | 2.300 € | 75 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54209047/) |
| 13 | Casa.it | Solari-Tortona, Washington | 2.250 € | 105 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54258109/) |
| 14 | Casa.it | Città Studi, Corsica, Susa | 2.800 € | 150 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54258935/) |
| 15 | Casa.it | Centro, Duomo, Brera | 3.100 € | 121 | 3 | F4: prezzo ben sopra limite | [link](https://www.casa.it/immobili/54259791/) |

**Azione prioritaria**: il candidato **#1** (trilocale 80 m², 1.400 €, zona Bicocca) ha superato
i filtri 1–5: aprirlo subito sul portale per verificare i tempi metro (≤7 min) e le distanze
verso Bicocca e Bovisa (<40 min) — se confermati supera tutti i 7 filtri. I candidati **#2, #3,
#5, #6, #7** sono trilocali/quadrilocali ≥75 m² **in Milano città** entro 1.500 € fermati solo
dalla mancata menzione di wifi/lavatrice nel dataset: vanno aperti per confermare dotazioni e
trasporti. I candidati **#4** e **#9** (comuni esterni) e gli scarti **#8–#15** (sopra budget,
F4) restano marginali — utili solo se il prezzo è negoziabile o se le bollette non sono già
incluse nel canone dichiarato.

---

## Candidati da ricontrollare

Appartamenti che hanno fallito per dati insufficienti o per problemi tecnici temporanei (accesso sandbox bloccato):

### A — ZappyRent Piazza dei Daini, Bicocca (id-32304) ⭐ Priorità alta

- **URL**: https://www.zappyrent.com/it/affitto/piazza-dei-daini-milano-id-32304
- **Zona**: Bicocca (Milano)
- **Configurazione**: 87 m², 2 camere (matrimoniale + singola), 2 bagni, 6° piano con ascensore
- **Prezzo noto**: 1.200 € affitto + 200 € condominio = **1.400 €/mese** (bollette incluse nel totale dichiarato) ✅
- **Dotazioni confermate**: lavatrice ✅ · WiFi ✅ · AC (4 split, probabilmente riscaldamento integrato) · forno · microonde · lavastoviglie · balcone · garage privato · cantina
- **Dotazioni da verificare**: divano ❓ · riscaldamento invernale (tipo/autonomo/cond.) ❓
- **Metro**: M5 Bignami **2 min a piedi** ✅
- **Bicocca**: **4 min a piedi** (295 m) ✅ (straordinario!)
- **Bovisa**: stimata ~35 min via M5 Bignami→Garibaldi + S-treno ✅
- **Motivo scarto filtro 3**: occupato dal 25/10/2024, data di liberazione futura sconosciuta
- **Azione**: verificare disponibilità alla prossima run; se confermata ≤14/09/2026 rivalutare

### B — Via Farini 33, zona Maciachini (89 mq)

- **URL**: https://www.immobiliare.it/affitto-case/milano/in-via-carlo-farini/ (nessun ID specifico trovato)
- **Zona**: Farini, Milano
- **Configurazione**: 89 m², trilocale elegante completamente ristrutturato
- **Prezzo**: sconosciuto
- **Disponibile**: da maggio 2026
- **Metro**: MM3 Maciachini ~4 min a piedi (stimato per la via)
- **Motivo scarto**: dati insufficienti (prezzo + dotazioni non verificabili)
- **Azione**: recuperare URL specifico su immobiliare.it o idealista.it; verificare prezzo e dotazioni

### C — Via Carlo Farini 57/a, Garibaldi-Isola (87 mq) — Idealista 24370460

- **URL**: https://www.idealista.it/immobile/24370460/
- **Zona**: Garibaldi-Isola, Milano
- **Configurazione**: 87 m², 2 camere, patio 20 mq, 2 bagni
- **Prezzo**: sconosciuto (finiture premium suggeriscono >1.500 €)
- **Disponibile**: da maggio 2026
- **Metro**: M2/M5 Garibaldi stimata ~5-8 min a piedi ❓
- **Dotazioni da verificare**: lavatrice ❓ · divano ❓ · WiFi ❓
- **Motivo scarto**: dati insufficienti (prezzo + dotazioni incomplete)
