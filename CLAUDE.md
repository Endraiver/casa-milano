# Ricerca appartamento Milano — istruzioni operative

Questo progetto serve a cercare un appartamento per studenti universitari a Milano
per **3 inquilini**, usando scraping via **Apify** sui principali portali e filtrando
i risultati secondo criteri gerarchici rigidi.

L'utente vivrà l'appartamento durante l'università (Bicocca + Politecnico Bovisa).

---

## Compito quando vieni invocato

Ogni volta che vieni invocato in questa cartella (o tramite il task schedulato),
esegui il workflow descritto sotto. Non chiedere conferma all'utente: parti subito
con la ricerca e mostra i progressi a schermo.

### Workflow

1. **Carica lo stato precedente** leggendo `analizzati.json`. Contiene la lista
   degli URL/ID di appartamenti già esaminati (sia accettati sia scartati).
   **Non rianalizzare** mai un appartamento già presente in questo file.
2. **Esegui scraping** sui portali elencati sotto, usando Apify (la API key è già
   configurata nell'ambiente — vedi sezione *Apify* in fondo).
3. Per ogni nuovo annuncio trovato applica i **filtri gerarchici** descritti sotto,
   **in ordine**. Appena un criterio non è rispettato, **scarta l'annuncio** e
   passa al successivo. Non sprecare tempo verificando gli altri criteri.
4. Per ogni appartamento esaminato (accettato o scartato) **aggiorna `analizzati.json`**
   con: URL, data analisi, esito (accettato/scartato), motivo dello scarto.
5. Per ogni appartamento **accettato** (tutti i 7 criteri rispettati) **aggiungi
   una riga in `risultati.md`** con i dettagli e il link, ordinandolo in base al
   bilanciamento prezzo/centralità (vedi sezione *Ordinamento*).
6. A fine ricerca stampa un breve riassunto: quanti annunci nuovi analizzati,
   quanti accettati, quanti scartati per ciascun motivo.

---

## Criteri gerarchici (ordine rigido)

Vanno verificati **in quest'ordine**. Appena uno fallisce → scarta e passa avanti.

> **Filtro 0 (implicito)**: l'appartamento deve trovarsi a **Milano** (città o
> comuni limitrofi raggiungibili in tempo dalle università — vedi filtro 7).

1. **Posti letto** — almeno **3 posti letto** disponibili.
   Configurazioni valide:
   - 3 camere singole, oppure
   - 1 matrimoniale (per 2 persone) + 1 singola.
2. **Metratura** — almeno **25 m² per persona** → minimo **75 m² totali** per 3
   persone. Se la metratura non è dichiarata, prova a stimarla dalle foto/planimetria;
   se resta incerta, **scarta** (meglio prudenti).
3. **Disponibilità** — l'appartamento deve essere disponibile **entro la 2ª
   settimana di settembre 2026** (ovvero entro il **14 settembre 2026**).
4. **Prezzo** — affitto mensile complessivo per tutti e tre **≤ 1500 €**,
   **bollette e spese condominiali incluse**. Se le bollette sono indicate
   "escluse", stima 100–150 €/mese e ricalcola; se il totale supera 1500 € → scarta.
5. **Dotazioni** — distinzione tra obbligatorie e desiderabili:
   - **Obbligatorie (scarta se assenti)**: **wifi**, **lavatrice**. Se il dato
     dice esplicitamente "no wifi" / "no lavatrice", scarta. Se il dato non
     menziona affatto wifi o lavatrice, **scarta per prudenza** (non possiamo
     dare per scontato che ci siano).
   - **Desiderabili (NON scartare se assenti dal dato)**: **divano**,
     **riscaldamento**. Se il dato non li menziona, dai loro il beneficio del
     dubbio e segna `divano_confermato=false` / `riscaldamento_confermato=false`
     nelle note, ma NON scartare. Se invece il dato dice esplicitamente
     "no divano" o "no riscaldamento", scarta.
6. **Mezzi pubblici** — **≤ 7 minuti a piedi** dalla fermata della metro più
   vicina. (Bus/tram da soli non bastano: serve la metro entro 7 minuti.)
7. **Distanza dalle università** — **< 40 minuti** con mezzi pubblici
   (metro/tram/bicicletta) **sia da Università Bicocca sia da Campus Bovisa
   Politecnico Milano**. Verifica entrambe le tratte; se anche solo una supera i
   40 min → scarta.

---

## Portali da fare scraping (Apify)

Usa actor Apify appropriati per ognuno. Se per un portale non c'è un actor pronto,
usa l'actor generico **`apify/web-scraper`** o **`apify/cheerio-scraper`** con
selettori CSS adatti.

- **Spotahome** — `https://www.spotahome.com/it/affitto/milano`
- **Uniplaces** — `https://www.uniplaces.com/it/affitto/milano`
- **Erasmusu** — `https://erasmusu.com/it/erasmus-milano/alloggi-erasmus`
- **HousingAnywhere** — `https://housinganywhere.com/it/s/Milano--Italia`
- **Immobiliare.it** — `https://www.immobiliare.it/affitto-case/milano/` (filtra
  per ≥ 3 locali, ≥ 75 m², ≤ 1500 €/mese)
- **Idealista.it** — `https://www.idealista.it/affitto-case/milano-milano/`
- **Casa.it** — `https://www.casa.it/affitto/residenziale/milano`
- **Subito.it** — `https://www.subito.it/annunci-lombardia/affitto/appartamenti/milano/`
- **DoveVivo** — `https://www.dovevivo.com/it/milano` (camere in appartamento condiviso)
- **Roomless** — `https://www.roomless.it/it/affitto/milano`

> **Apartostudent** menzionato dall'utente è probabilmente *Aparto Student*
> (https://apartostudent.com/it/citta/milano) — student housing. Includi anche
> questo se trovi annunci compatibili con 3 posti letto.

Limita i parametri di ricerca a Milano e — quando il portale lo permette — già a
≤ 1500 €/mese e ≥ 75 m², per ridurre il rumore.

---

## Stato — `analizzati.json`

Struttura:

```json
{
  "last_run": "2026-05-16T14:30:00",
  "annunci": [
    {
      "id": "spotahome-12345",
      "url": "https://www.spotahome.com/...",
      "portale": "spotahome",
      "analizzato_il": "2026-05-16",
      "esito": "scartato",
      "motivo_scarto": "filtro 4 — prezzo 1750 € con bollette"
    },
    {
      "id": "immobiliare-98765",
      "url": "https://www.immobiliare.it/...",
      "portale": "immobiliare",
      "analizzato_il": "2026-05-16",
      "esito": "accettato"
    }
  ]
}
```

L'**ID** dev'essere stabile e univoco per portale (di solito è nell'URL). Prima di
analizzare un annuncio, controlla che il suo ID non sia già presente.

---

## Output — `risultati.md`

Mantieni il file con questa struttura:

```markdown
# Appartamenti che rispettano tutti i criteri

Ultimo aggiornamento: AAAA-MM-GG

## Tabella riassuntiva

| # | Zona | Prezzo (tutto incluso) | m² | Posti letto | Metro a … min | Bicocca | Bovisa | Disponibile dal | Link |
|---|------|-----------------------|----|--|-|-|--|--|------|
| 1 | NoLo | 1380 € | 85 | 3 singole | 4 min (M1 Pasteur) | 28 min | 35 min | 01/09/2026 | [link](...) |

## Schede dettagliate

### 1 — NoLo, Via … (1380 €/mese)
- **Portale**: Immobiliare.it · [link annuncio](...)
- **Configurazione**: 3 camere singole, 85 m²
- **Prezzo**: 1300 € affitto + 80 € condominio + ~100 € bollette = **1380 €/mese**
- **Disponibilità**: dal 01/09/2026
- **Dotazioni**: divano ✅ · wifi ✅ · riscaldamento autonomo ✅ · lavatrice ✅
- **Trasporti**: M1 Pasteur a 4 min a piedi
- **Università**: Bicocca 28 min · Bovisa 35 min
- **Note**: appartamento in palazzo storico, 2° piano con ascensore
```

Per ogni nuovo accettato **aggiungi una riga in tabella** e una **scheda dettagliata**.
Mai rimuovere annunci passati (servono da storico) — al massimo segnali "non più
disponibile" se rilevi che il link è andato offline.

### Sezione obbligatoria: "Candidati alternativi" (quando 0 accettati)

Anche quando NESSUN annuncio supera tutti i 7 filtri, l'utente vuole comunque
vedere **i 10-15 annunci più promettenti tra gli scartati** — quelli che vale
la pena guardare a mano. Mantieni in `risultati.md` una sezione dedicata:

```markdown
## Candidati alternativi (run AAAA-MM-GG)

Top N annunci scartati ma più vicini ai criteri — vale la pena considerarli a
mano.

| # | Zona | Prezzo | m² | Filtro fallito | Vicino al limite? | Link |
|---|------|--------|----|----|-------------------|------|
| 1 | NoLo | 1650 €  | 80 | F4 prezzo | sì (+150 €) | [link](...) |
```

Come scegliere i 10-15 alternativi (in ordine di priorità):

1. **Quasi-accettati**: annunci che hanno fallito solo all'**ultimo** filtro
   verificato (7, 6, 5, 4) → priorità massima
2. **Vicini al limite**: prezzo entro +20% (≤1800€), metratura entro -15% (≥64 m²),
   tempo università ≤45 min → priorità alta
3. **Disponibilità incerta**: annunci scartati per filtro 3 (data non
   specificata) ma con buoni altri parametri → segnala "verificare disponibilità"
4. **Dotazioni non confermate**: scartati per filtro 5 ma con prezzo e metratura
   ottimi → segnala cosa va verificato

Mostra sempre la motivazione di scarto e quanto è "vicino" al passaggio.
Aggiorna questa sezione ogni run (rimpiazzando i precedenti — non accumulare).

### Ordinamento

L'utente ha scelto profilo **bilanciato**: mostra sia opzioni economiche periferiche
sia opzioni più centrali nel budget. Ordina i risultati per **rapporto qualità/prezzo**:

Score (più basso = meglio) = `prezzo_per_persona + (minuti_università × 8)`

dove `minuti_università = max(min_bicocca, min_bovisa)`. Mostra lo score in una
colonna nascosta a fine tabella o nelle note se ti è utile, ma l'ordinamento visivo
deve seguirlo.

---

## Calcolo distanze e tempi

Per i filtri 6 e 7 hai bisogno di tempi di percorrenza affidabili:

- **Metro più vicina + tempo a piedi**: usa Google Maps Directions tramite la
  WebFetch sull'URL `https://www.google.com/maps/dir/?api=1&origin=<indirizzo>&destination=<metro>&travelmode=walking`,
  oppure cerca la stazione metro più vicina su OpenStreetMap.
- **Tempo verso Bicocca**: destinazione **"Università degli Studi di Milano-Bicocca,
  Piazza dell'Ateneo Nuovo 1, Milano"**.
- **Tempo verso Bovisa**: destinazione **"Politecnico di Milano - Campus Bovisa,
  Via Lambruschini 4, Milano"**.
- Usa `travelmode=transit` per i tempi con mezzi pubblici.

Se per qualche motivo non riesci a calcolare il tempo (es. indirizzo non geocodabile),
**scarta l'annuncio per prudenza** e annota `motivo_scarto: "indirizzo non verificabile"`.

---

## Apify — uso pratico

L'API key è disponibile come variabile d'ambiente `APIFY_API_TOKEN`
(o `APIFY_TOKEN`). Verifica con `echo %APIFY_API_TOKEN%` (Windows) prima di partire;
se non c'è, chiedi all'utente di impostarla prima di procedere.

Esempio di chiamata sync a un actor:

```
POST https://api.apify.com/v2/acts/<ACTOR_ID>/run-sync-get-dataset-items
?token=<APIFY_API_TOKEN>
Body JSON: { "startUrls": [{ "url": "..." }], "maxItems": 50, ... }
```

Usa la Bash tool con `curl` per fare le chiamate. Salva i dataset raw in
`./cache/<portale>-<data>.json` così se ricarichi non rifai chiamate inutili
(occhio ai costi Apify).

Per dataset grossi puoi avviare l'actor in async con `/runs` e poi `pollare`
`/runs/<id>` finché lo stato è `SUCCEEDED`. **Non sleepare**: usa Monitor o
ScheduleWakeup invece di loop con sleep.

---

## Regole comportamentali

- **Non chiedere conferma** durante la ricerca: vai dritto, scarta in fretta,
  motiva sempre lo scarto in `analizzati.json`.
- **Gerarchia rigida**: non valutare il criterio N+1 se l'N è fallito.
- **Idempotenza**: rilanciare lo script non deve mai rianalizzare annunci già
  presenti in `analizzati.json`, né duplicare righe in `risultati.md`.
- **Niente allucinazioni**: se un dato non è nell'annuncio (es. metratura,
  bollette), o lo stimi con criterio dichiarando l'assunzione nelle note, o
  scarti.
- **Costi Apify**: usa filtri server-side e `maxItems` ragionevoli per non
  sprecare crediti.
- **Riassunto finale obbligatorio** ogni run: "Analizzati X nuovi annunci, Y
  accettati, Z scartati (W per prezzo, V per metratura, …)".
