# run-daily.ps1
# Ricerca giornaliera appartamenti Milano.
#
# Architettura ibrida:
#   1. PowerShell chiama direttamente gli actor Apify (no sandbox di rete).
#   2. I dataset grezzi vengono salvati in ./cache/<portale>-YYYY-MM-DD.json.
#   3. Claude Code (--print) legge i cache files, applica i 7 filtri di CLAUDE.md,
#      aggiorna analizzati.json + risultati.md e fa commit/push.
#
# Lancio manuale:
#   powershell -ExecutionPolicy Bypass -File C:\Users\Antonio\casa-milano\run-daily.ps1

$ErrorActionPreference = "Continue"

$ProjectDir = "C:\Users\Antonio\casa-milano"
$CacheDir   = Join-Path $ProjectDir "cache"
$LogDir     = Join-Path $ProjectDir "logs"
$ClaudeBin  = "C:\Users\Antonio\.local\bin\claude.exe"
if (-not (Test-Path $ClaudeBin)) {
    foreach ($c in @("C:\Users\Antonio\.local\bin\claude.cmd","C:\Users\Antonio\.local\bin\claude")) {
        if (Test-Path $c) { $ClaudeBin = $c; break }
    }
}

# --- Setup directory + log file ---
foreach ($d in @($CacheDir, $LogDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
}
$DateStr   = Get-Date -Format "yyyy-MM-dd"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$LogFile   = Join-Path $LogDir "run-$Timestamp.log"

function Write-Log($msg) {
    $line = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $msg
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -Encoding utf8
}

Set-Location $ProjectDir
Write-Log "=== Avvio run casa-milano-daily ==="

# --- Carica APIFY_API_TOKEN ---
if (-not $env:APIFY_API_TOKEN) {
    $env:APIFY_API_TOKEN = [System.Environment]::GetEnvironmentVariable('APIFY_API_TOKEN', 'User')
}
if (-not $env:APIFY_API_TOKEN) {
    Write-Log "ERRORE: APIFY_API_TOKEN non trovato (setta con setx APIFY_API_TOKEN <token>)"
    exit 1
}
Write-Log ("APIFY_API_TOKEN: presente (len={0})" -f $env:APIFY_API_TOKEN.Length)

# --- git pull per allinearsi alle modifiche manuali ---
Write-Log "git pull origin main..."
git pull origin main 2>&1 | ForEach-Object { Add-Content -Path $LogFile -Value $_ -Encoding utf8 }

# ===========================================================================
#  CONFIG: lista degli attori Apify da chiamare.
#  Per aggiungere un portale:
#   1. Approva l'actor sul tuo account Apify (Try for free / Run actor)
#   2. Decommenta o aggiungi un blocco qui sotto.
#   3. Verifica che lo schema 'Input' corrisponda a quello richiesto dall'actor.
# ===========================================================================
$ApifyJobs = @(
    # Immobiliare: una sola call con maxItems alto (il free tier ha rate-limit
    # per-attore di 30 min, quindi 2 call back-to-back sullo stesso actor falliscono).
    # URL semplice: tutto Milano sotto 1500 EUR, Claude filtra a valle per metratura/locali.
    # Costo: $1 per 1.000 risultati.
    @{
        Name    = "immobiliare"
        ActorId = "azzouzana~immobiliare-it-listing-page-scraper-by-search-url"
        Input   = @{
            startUrl = "https://www.immobiliare.it/affitto-case/milano/?prezzoMassimo=1500&numeroLocali=3"
            maxItems = 250
        }
    }

    # Idealista (igolaizola). Schema strutturato: country+location+operation+bedrooms.
    # bedrooms=2,3,4 (in Italia un trilocale=2 camere, quadrilocale=3 camere).
    # minSize 70 mq per scartare a monte microalloggi.
    @{
        Name    = "idealista"
        ActorId = "igolaizola~idealista-scraper"
        Input   = @{
            operation     = "rent"
            propertyType  = "homes"
            country       = "it"
            location      = "Milano"
            maxItems      = 100
            maxPrice      = "1700"
            bedrooms      = @("2","3","4")
            sortBy        = "mostRecent"
            fetchDetails  = $false
            fetchStats    = $false
        }
    }

    # Subito (emastra/subito-it-immobili). URL search Lombardia/affitto/appartamenti
    # con filtri prezzo. Schema: startUrls array di STRINGHE, maxResultItems.
    @{
        Name    = "subito"
        ActorId = "emastra~subito-it-immobili"
        Input   = @{
            startUrls       = @("https://www.subito.it/annunci-lombardia/affitto/appartamenti/milano/?ps=&pe=1700")
            maxResultItems  = 100
            onlyPrivate     = $false
        }
    }

    # Casa.it riabilitato (modalita' spendi crediti). Costo $4/1.000 = ~$0.60/giorno.
    @{
        Name    = "casa-it"
        ActorId = "stealth_mode~casa-property-search-scraper"
        Input   = @{
            urls                = @("https://www.casa.it/affitto/residenziale/trilocali/milano/")
            max_items_per_url   = 150
            ignore_url_failures = $true
            proxy               = @{ useApifyProxy = $false }
        }
    }

    # Blocco commentato di backup (placeholder per riferimento):
    # @{
    #     Name    = "casa-it"
    #     ActorId = "stealth_mode~casa-property-search-scraper"
    #     Input   = @{
    #         urls                = @("https://www.casa.it/affitto/residenziale/trilocali/milano/")
    #         max_items_per_url   = 100
    #         ignore_url_failures = $true
    #         proxy               = @{ useApifyProxy = $false }
    #     }
    # }
)

# --- Esecuzione attori ---
$JobReport = @()
foreach ($job in $ApifyJobs) {
    $cacheFile = Join-Path $CacheDir "$($job.Name)-$DateStr.json"

    if (Test-Path $cacheFile) {
        $sz = (Get-Item $cacheFile).Length
        Write-Log ("[{0}] cache esistente ({1} byte), skip chiamata Apify." -f $job.Name, $sz)
        $JobReport += [pscustomobject]@{ Job = $job.Name; Status = "cached"; File = $cacheFile }
        continue
    }

    $body = $job.Input | ConvertTo-Json -Depth 10 -Compress
    $url  = "https://api.apify.com/v2/acts/$($job.ActorId)/run-sync-get-dataset-items?token=$env:APIFY_API_TOKEN"
    Write-Log ("[{0}] chiamo Apify actor {1}..." -f $job.Name, $job.ActorId)

    try {
        $resp = Invoke-RestMethod -Uri $url -Method POST -ContentType "application/json" -Body $body -TimeoutSec 600 -ErrorAction Stop
        $items = @($resp)

        # Apify puo' restituire un array di items oppure un singolo oggetto di errore.
        # Cerchiamo casi di errore (rate limit / permessi).
        $firstObj = $items | Select-Object -First 1
        if ($firstObj -and $firstObj.PSObject.Properties['message'] -and $items.Count -le 1) {
            $msgText = "$($firstObj.message)"
            if ($msgText -match "Rate limit|permission|denied|not approved") {
                Write-Log ("[{0}] errore Apify: {1}" -f $job.Name, $msgText)
                $JobReport += [pscustomobject]@{ Job = $job.Name; Status = "error"; Detail = $msgText }
                continue
            }
        }

        # Salva il dataset
        $items | ConvertTo-Json -Depth 30 | Set-Content -Path $cacheFile -Encoding utf8
        Write-Log ("[{0}] OK - {1} annunci salvati in {2}" -f $job.Name, $items.Count, $cacheFile)
        $JobReport += [pscustomobject]@{ Job = $job.Name; Status = "ok"; Count = $items.Count; File = $cacheFile }
    }
    catch {
        $em = $_.Exception.Message
        $body = $null
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $body = $reader.ReadToEnd()
            } catch {}
        }
        Write-Log ("[{0}] ECCEZIONE: {1}" -f $job.Name, $em)
        if ($body) { Write-Log ("[{0}] body: {1}" -f $job.Name, ($body.Substring(0,[Math]::Min(300,$body.Length)))) }
        $JobReport += [pscustomobject]@{ Job = $job.Name; Status = "exception"; Detail = $em }
    }
}

Write-Log "=== Report Apify ==="
$JobReport | ForEach-Object { Write-Log ("  {0,-15} {1}" -f $_.Job, ($_ | ConvertTo-Json -Compress)) }

# --- Se nessun dato e' stato raccolto in questa esecuzione, fermiamoci qui ---
$okJobs = $JobReport | Where-Object { $_.Status -in @("ok","cached") }
if (-not $okJobs) {
    Write-Log "Nessun dataset raccolto. Stop senza invocare Claude."
    exit 0
}

# --- Invoca Claude solo per il filtraggio ---
$cacheFilesToday = (Get-ChildItem $CacheDir -Filter "*-$DateStr.json" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }) -join ", "

$Prompt = @"
Sei nella cartella casa-milano. Hai a disposizione dataset Apify GIA' SCARICATI per oggi $DateStr in: $cacheFilesToday

**REGOLA #1 NON NEGOZIABILE**: DEVI processare OGNI SINGOLO annuncio in OGNI file cache. Non saltare, non fermarti prima della fine. Se un cache file contiene 100 annunci, alla fine devi avere processato esattamente 100 annunci (o tutti quelli non gia' presenti in analizzati.json).

**APPROCCIO CONSIGLIATO PER GRANDI VOLUMI**: scrivi uno script PowerShell ausiliario (es. process_listings.ps1) che:
  a) Carica analizzati.json e crea hashset degli id gia' presenti
  b) Per ogni file cache di oggi, itera TUTTI gli annunci
  c) Per ciascuno, applica i filtri 1->7 in modo DETERMINISTICO usando i campi del dataset
  d) Accumula entry e scrive analizzati.json + risultati.md alla fine
  e) Stampa conteggi precisi: cache=N1, gia_analizzati=N2, nuovi_processati=N3, accettati=N4, scartati=N5
Esegui lo script, poi commit & push.

Compito completo:

1. Leggi CLAUDE.md per le regole esatte (i 7 filtri + la sezione "Candidati alternativi").
2. Leggi analizzati.json. Estrai TUTTI gli id gia' presenti in un hashset/dictionary.
3. Per ogni file cache/*-$DateStr.json (Casa.it, Subito, Idealista, Immobiliare a seconda di cosa esiste):
   - Carica con ConvertFrom-Json.
   - Itera OGNI elemento. Per ciascuno:
     - Costruisci id stabile: "<portale>-<id-annuncio>" usando un identificatore univoco nel dataset (es. campo "id", "url", o slug dal URL).
     - Se id gia' in hashset: skip.
     - Altrimenti applica i 7 filtri IN ORDINE:
       F1 - posti letto >=3 (3 singole o 1 matr + 1 singola). Stima da campi rooms, bedrooms, descrizione.
       F2 - mq >= 75
       F3 - disponibilita' entro 14/09/2026 (regola: se data esplicita futura > 14/09 scarta; se occupato senza data scarta; se nessuna info, accetta con nota "data non dichiarata")
       F4 - prezzo + spese + bollette <= 1500 (se bollette non dichiarate, stima 100-150 EUR/mese)
       F5 - obbligatori wifi+lavatrice (assenza esplicita = scarta; assenza dato = scarta per prudenza). Desiderabili divano+riscaldamento (assenza dato = non scartare).
       F6 - metro <= 7 min a piedi (usa indirizzo se disponibile per stima di buon senso; se zona ignota scarta)
       F7 - <40 min mezzi pubblici sia da Bicocca (P.zza Ateneo Nuovo 1) sia da Bovisa (V. Lambruschini 4)
     - Appena un filtro fallisce: aggiungi entry a analizzati.json con esito="scartato", motivo_scarto="F<n> - <dettaglio>". STOP per quell'annuncio, passa al prossimo.
     - Se tutti i 7 passano: esito="accettato", aggiungi a risultati.md tabella + scheda.
4. Aggiorna la sezione "Candidati alternativi" in risultati.md (10-15 migliori scartati). Sostituisci la sezione precedente (non accumulare).
5. Ordina la tabella accettati per score = prezzo_per_persona + max(minuti_bicocca, minuti_bovisa)*8.
6. Commit + push:
     git add analizzati.json risultati.md
     git commit -m "scan ${DateStr}: N nuovi analizzati, M accettati"
     git push origin main
7. RIASSUNTO FINALE OBBLIGATORIO con NUMERI PRECISI:
   - "Cache totale: X items (Casa.it: A, Subito: B, Idealista: C, Immobiliare: D)"
   - "Gia' in analizzati.json: Y"
   - "Nuovi analizzati questo run: Z"
   - "Accettati: W"
   - "Scartati: V per filtro {F1: n1, F2: n2, ...}"
   - Se Z != X - Y, c'e' un BUG e devi ri-processare quello che manca.

VINCOLI:
- Niente conferme intermedie, vai dritto.
- Idempotenza: stessi id non vengono duplicati (controllo hashset).
- Prudenza sui dati incerti, ma non per i campi marcati "desiderabili" in F5.
- Devi processare TUTTI gli annunci nuovi, NON solo i primi. Se necessario itera in batch di 50 salvando in mezzo.
"@

Write-Log "Invoco Claude per il filtraggio..."
try {
    $out = & $ClaudeBin -p $Prompt --dangerously-skip-permissions 2>&1
    foreach ($line in $out) { Add-Content -Path $LogFile -Value $line -Encoding utf8 }
    Write-Log "Claude exit code: $LASTEXITCODE"
} catch {
    Write-Log ("Eccezione invocando Claude: " + $_.Exception.Message)
}

# --- Cleanup log vecchi (tieni ultimi 30 + cache > 7gg vecchi) ---
Get-ChildItem $LogDir   -Filter "run-*.log"  | Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem $CacheDir -Filter "*.json"     | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Log "=== Run completata ==="
