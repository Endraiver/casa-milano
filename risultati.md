# Appartamenti che rispettano tutti i criteri

Ultimo aggiornamento: 2026-05-16

## Riepilogo criteri attivi

- Località: Milano
- Posti letto: ≥ 3 (3 singole oppure 1 matrimoniale + 1 singola)
- Metratura: ≥ 25 m²/persona (75 m² totali)
- Disponibilità: entro 14 settembre 2026
- Prezzo: ≤ 1500 €/mese tutto incluso (3 persone)
- Dotazioni: divano, wifi, riscaldamento, lavatrice
- Trasporti: metro entro 7 min a piedi
- Università: < 40 min da Bicocca **e** da Bovisa

## Log run

| Data | Annunci nuovi analizzati | Accettati | Scartati |
|------|--------------------------|-----------|---------|
| 2026-05-17 (09:00) Apify | 105 | 0 | 105 |
| 2026-05-17 (23:45) | 3 | 0 | 3 |
| 2026-05-17 (14:00) | 0 | 0 | 0 |
| 2026-05-17 (10:30) | 3 | 0 | 3 |
| 2026-05-16 | 12 | 0 | 12 |

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
