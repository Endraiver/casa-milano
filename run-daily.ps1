# run-daily.ps1
# Esegue il workflow di ricerca appartamenti definito in CLAUDE.md
# usando Claude Code in modalità non-interattiva (claude -p).
#
# Invocato da Windows Task Scheduler ogni mattina alle 09:00,
# ma puoi anche lanciarlo a mano per testare: pwsh .\run-daily.ps1
#
# Log: ogni run scrive in ./logs/run-YYYY-MM-DD_HHmm.log

$ErrorActionPreference = "Continue"

$ProjectDir = "C:\Users\Antonio\casa-milano"
$LogDir     = Join-Path $ProjectDir "logs"
$ClaudeBin  = "C:\Users\Antonio\.local\bin\claude.cmd"

# Fallback se il binario è invece "claude" senza estensione
if (-not (Test-Path $ClaudeBin)) {
    $ClaudeBin = "C:\Users\Antonio\.local\bin\claude"
}

# --- Setup ---
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
}
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$LogFile   = Join-Path $LogDir "run-$Timestamp.log"

function Write-Log($msg) {
    $line = "[{0:HH:mm:ss}] {1}" -f (Get-Date), $msg
    Write-Output $line
    Add-Content -Path $LogFile -Value $line -Encoding utf8
}

Set-Location $ProjectDir
Write-Log "=== Avvio run casa-milano-daily ==="
Write-Log "Working dir: $ProjectDir"

# --- Verifica env var ---
if (-not $env:APIFY_API_TOKEN) {
    $env:APIFY_API_TOKEN = [System.Environment]::GetEnvironmentVariable('APIFY_API_TOKEN', 'User')
}
if (-not $env:APIFY_API_TOKEN) {
    Write-Log "ERRORE: APIFY_API_TOKEN non trovato. Setta con: setx APIFY_API_TOKEN <token>"
    exit 1
}
Write-Log ("APIFY_API_TOKEN: presente (lunghezza {0})" -f $env:APIFY_API_TOKEN.Length)

# --- Pull ultime modifiche da remote (idempotenza) ---
Write-Log "git pull origin main..."
git pull origin main 2>&1 | ForEach-Object { Add-Content -Path $LogFile -Value $_ -Encoding utf8 }

# --- Prompt per Claude ---
$Prompt = @"
Sei nella cartella casa-milano. Leggi CLAUDE.md ed esegui il workflow di ricerca appartamenti seguendo TUTTE le istruzioni che trovi lì.

In sintesi:
1. Carica analizzati.json (lista degli annunci già esaminati — NON rianalizzarli)
2. Esegui scraping via Apify (token in `$env:APIFY_API_TOKEN`) sui portali elencati in CLAUDE.md
3. Per ogni NUOVO annuncio applica i 7 filtri gerarchici IN ORDINE: appena uno fallisce → scarta, motiva, e passa al prossimo
4. Aggiorna analizzati.json con OGNI annuncio esaminato (esito + motivo scarto)
5. Aggiungi gli accettati a risultati.md (tabella + scheda dettagliata)
6. Commit e push:
     git add analizzati.json risultati.md
     git commit -m "daily scan $(Get-Date -Format yyyy-MM-dd): N nuovi, M accettati"
     git push origin main
7. Stampa riassunto finale: N analizzati, N accettati, N scartati (per filtro)

Niente conferme, vai dritto. Rispetta la gerarchia rigida dei filtri.
"@

Write-Log "Invoco Claude Code (modalità non-interattiva)..."

# --- Invoca claude -p ---
try {
    $output = & $ClaudeBin -p $Prompt --dangerously-skip-permissions 2>&1
    foreach ($line in $output) {
        Add-Content -Path $LogFile -Value $line -Encoding utf8
    }
    Write-Log "=== Run completata con exit code $LASTEXITCODE ==="
}
catch {
    Write-Log ("ERRORE durante l'invocazione di claude: " + $_.Exception.Message)
    exit 2
}

# --- Pulizia: tieni solo gli ultimi 30 log ---
Get-ChildItem -Path $LogDir -Filter "run-*.log" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 30 |
    Remove-Item -Force -ErrorAction SilentlyContinue

Write-Log "Done."
