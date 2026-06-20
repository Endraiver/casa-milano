# Appartamenti che rispettano tutti i criteri

Ultimo aggiornamento: 2026-06-20 (full batch processing)

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

## Candidati alternativi (run 2026-06-20)

Run 2026-06-20: **181 annunci nuovi analizzati, 0 accettati, 181 scartati**
(F1: 83 · F2: 17 · F4: 46 · F5: 35).

**Profilo filtri**: nessun annuncio supera i filtri 1–5, quindi i tempi metro/università
(filtri 6–7) non sono stati raggiunti. I candidati prioritari qui sotto sono tutti
**trilocali ≥75 m² entro budget** fermati al **filtro 5** solo perché il dataset Apify
non menziona esplicitamente **wifi/lavatrice** — vanno verificati a mano. Per gli annunci
in **comuni esterni** (Rho, Legnano, Cerro Maggiore, Opera, Cologno Monzese) va verificato
anche il **filtro 7** (tempi verso Bicocca e Bovisa).

### Top 15 candidati — priorità per verifica manuale

| # | Portale | Zona | Prezzo | m² | Locali | Motivo scarto | Link |
|---|---------|------|--------|----|----|---------------|------|
| 1 | Subito | Rho (fuori Milano) | 1.000 € | 110 | 3 | F5: verificare wifi+lavatrice · F7 da verificare | [link](https://www.subito.it/appartamenti/appartamento-rho-cod-rif-3324954arg-milano-651411242.htm) |
| 2 | Subito | Milano | 1.500 € | 110 | 3 | F5: verificare wifi | [link](https://www.subito.it/appartamenti/trilocale-arredato-e-corredato-con-doppi-servizi-milano-647284771.htm) |
| 3 | Subito | Milano | 1.200 € | 105 | 3 | F5: verificare wifi+lavatrice | [link](https://www.subito.it/appartamenti/3-locali-a-milano-milano-651424491.htm) |
| 4 | Casa.it | Arco della Pace, Sempione | 1.400 € | 101 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/53643902/) |
| 5 | Subito | Legnano (fuori Milano) | 750 € | 100 | 3 | F5: verificare wifi+lavatrice · F7 da verificare | [link](https://www.subito.it/appartamenti/ampio-trilocale-legnano-centro-con-spese-comprese-milano-651351957.htm) |
| 6 | Casa.it | Arco della Pace, Sempione | 1.500 € | 100 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/54133180/) |
| 7 | Subito | Cerro Maggiore (fuori Milano) | 970 € | 95 | 3 | F5: verificare wifi+lavatrice · F7 da verificare | [link](https://www.subito.it/appartamenti/trilocale-in-zona-cerro-maggiore-con-box-auto-milano-651030457.htm) |
| 8 | Casa.it | Porta Romana, Risorgimento | 1.500 € | 95 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/54218279/) |
| 9 | Subito | Opera (fuori Milano) | 1.000 € | 90 | 3 | F5: verificare wifi+lavatrice · F7 da verificare | [link](https://www.subito.it/appartamenti/trilocale-90mq-adatto-anche-a-famiglie-opera-milano-651373424.htm) |
| 10 | Casa.it | Gallaratese, QT8, Trenno | 1.100 € | 90 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/54148739/) |
| 11 | Casa.it | Ripamonti, Vigentino | 1.500 € | 90 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/53166309/) |
| 12 | Casa.it | Lambrate | 1.200 € | 87 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/54222727/) |
| 13 | Subito | Cologno Monzese (fuori Milano) | 1.050 € | 85 | 3 | F5: verificare wifi · F7 da verificare | [link](https://www.subito.it/appartamenti/trilocale-a-cologno-monzese-milano-651073961.htm) |
| 14 | Casa.it | Porta Romana, Risorgimento | 1.150 € | 85 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/54228210/) |
| 15 | Casa.it | Gallaratese, QT8, Trenno | 1.150 € | 85 | 3 | F5: verificare wifi+lavatrice | [link](https://www.casa.it/immobili/53493926/) |

**Azione prioritaria**: i candidati **in Milano città** (#2, #3, #4, #6, #8, #10, #11, #12,
#14, #15) sono trilocali ≥85 m² entro 1.500 € fermati solo dalla mancata menzione di
wifi/lavatrice nel dataset: vanno aperti direttamente sul portale per confermare le
dotazioni e i tempi metro/università. Se confermati, possono superare tutti i 7 filtri.
I candidati in comuni esterni (#1, #5, #7, #9, #13) hanno ottimo prezzo/metratura ma
richiedono anche la verifica del filtro 7 (≤40 min da Bicocca **e** Bovisa).

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
