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
    @{
        Name    = "immobiliare"
        ActorId = "azzouzana~immobiliare-it-listing-page-scraper-by-search-url"
        Input   = @{
            startUrl = "https://www.immobiliare.it/affitto-case/milano/?prezzoMassimo=1500&superficieMinima=75&numeroLocali=3"
            maxItems = 200
        }
    }

    @{
        Name    = "idealista"
        ActorId = "axlymxp~idealista-scraper"
        Input   = @{
            country      = "it"
            locationName = "Milano"
            propertyType = "homes"
            operation    = "rent"
            sort         = "asc"
            order        = "price"
            locale       = "it"
            maxItems     = 50
        }
    }

    # Subito: l'actor propscout-scraper in test ha restituito annunci di tecnocasa in vendita,
    # non affitti di subito. Disabilitato in attesa di trovare un actor migliore.
    # @{
    #     Name    = "subito"
    #     ActorId = "ayrtondavoli97~propscout-scraper"
    #     Input   = @{ searchUrl = "..."; maxItems = 100 }
    # }

    @{
        Name    = "casa-it"
        ActorId = "stealth_mode~casa-property-search-scraper"
        Input   = @{
            urls               = @("https://www.casa.it/affitto/residenziale/milano/")
            max_items_per_url  = 50
            ignore_url_failures = $true
            proxy              = @{ useApifyProxy = $false }
        }
    }
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

Compito: applica i 7 filtri gerarchici di CLAUDE.md a OGNI annuncio NUOVO (non gia' in analizzati.json) e aggiorna lo stato.

Passi:
1. Leggi CLAUDE.md per le regole.
2. Leggi analizzati.json (lista annunci gia' esaminati, hanno campo id univoco).
3. Per ogni file in cache/*-$DateStr.json, leggilo come lista di annunci. Per ciascun annuncio:
   - Costruisci un id stabile (es. "immobiliare-<id-annuncio>" usando l'id presente nel dataset Apify).
   - Se l'id e' gia' in analizzati.json, salta.
   - Applica i filtri 1->7 IN ORDINE. Appena uno fallisce: aggiungi entry a analizzati.json con esito="scartato" e motivo_scarto, e passa al prossimo annuncio (NON valutare i filtri successivi).
   - Se tutti i 7 filtri passano: aggiungi a analizzati.json esito="accettato" e aggiungi riga in risultati.md (tabella + scheda dettagliata).
4. Per i filtri 6 (metro <=7min) e 7 (<40min Bicocca+Bovisa) usa WebFetch su Google Maps. Se la WebFetch e' bloccata, prova con Bash + curl + dangerouslyDisableSandbox=true verso https://www.google.com/maps/dir/?api=1&... Se proprio non riesci, scarta per prudenza (motivo: "tempi non verificabili").
5. Ordina i risultati in risultati.md per score = prezzo_per_persona + minuti_universita_max * 8 (piu' basso = meglio).
6. Commit + push:
     git add analizzati.json risultati.md cache
     git commit -m "daily scan $DateStr"
     git push origin main
7. Stampa riassunto finale: N analizzati, N accettati, N scartati per filtro.

Niente conferme, vai dritto. Gerarchia rigida. Idempotenza (mai duplicati). Prudenza (se dato non verificabile, scarta).
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
