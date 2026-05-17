#!/usr/bin/env python3
import json
import datetime
import sys
from pathlib import Path

# === CONFIGURAZIONE ===
ANALIZZATI_FILE = Path("analizzati.json")
RISULTATI_FILE = Path("risultati.md")
CACHE_FILES = [
    Path("cache/casa-it-2026-05-17.json"),
    Path("cache/subito-2026-05-17.json"),
]

DEADLINE = datetime.date(2026, 9, 14)
BUDGET = 1500  # €/mese tutto incluso
METRO_MIN = 7  # minuti a piedi
UNIVERSITY_MIN = 40  # minuti con mezzi pubblici

# Destinazioni università
BICOCCA = "Università degli Studi di Milano-Bicocca, Piazza dell'Ateneo Nuovo 1, Milano"
BOVISA = "Politecnico di Milano - Campus Bovisa, Via Lambruschini 4, Milano"

# === CARICA STATO PRECEDENTE ===
def load_analizzati():
    if ANALIZZATI_FILE.exists():
        with open(ANALIZZATI_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"last_run": None, "annunci": []}

def save_analizzati(data):
    with open(ANALIZZATI_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

# === ESTRAI ID ANNUNCI GIA' ANALIZZATI ===
def get_existing_ids(state):
    return {ann["id"] for ann in state["annunci"]}

# === CARICA CACHE ===
def load_cache_files():
    all_annunci = []
    for cache_file in CACHE_FILES:
        if cache_file.exists():
            with open(cache_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    all_annunci.extend(data)
    return all_annunci

# === FUNZIONI FILTRI ===
def filter_1_posti_letto(annuncio):
    """Filtro 1: almeno 3 posti letto"""
    # Casa.it
    if "features" in annuncio and "rooms" in annuncio["features"]:
        rooms = annuncio["features"]["rooms"]
        if isinstance(rooms, dict) and "value" in rooms:
            rooms = rooms["value"]
        if rooms and rooms >= 3:
            return True, f"rooms={rooms}"
        else:
            return False, f"rooms={rooms} < 3"

    # Subito
    if "features" in annuncio and "rooms" in annuncio["features"]:
        rooms = annuncio["features"]["rooms"]
        if isinstance(rooms, dict) and "value" in rooms:
            rooms = rooms["value"]
        if rooms and rooms >= 3:
            return True, f"rooms={rooms}"
        else:
            return False, f"rooms={rooms} < 3"

    return False, "rooms non disponibile"

def filter_2_metratura(annuncio):
    """Filtro 2: almeno 75 m²"""
    if "features" in annuncio and "mq" in annuncio["features"]:
        mq = annuncio["features"]["mq"]
        if isinstance(mq, dict) and "value" in mq:
            mq = mq["value"]
        if mq and mq >= 75:
            return True, f"mq={mq}"
        else:
            return False, f"mq={mq} < 75"

    return False, "mq non disponibile"

def filter_3_disponibilita(annuncio):
    """Filtro 3: disponibile entro 14 settembre 2026"""
    # Se il dato non specifica nulla sulla disponibilità, assumi immediata
    # Se dichiara data esplicita futura > deadline, scarta
    # Se dichiara "occupato" senza data futura, scarta

    # Cercame il campo availability in Casa.it o subito
    # Per ora, se non c'è il dato, ACCETTA (assumi immediata)
    return True, "disponibilita non dichiarata (assunta immediata)"

def filter_4_prezzo(annuncio):
    """Filtro 4: prezzo ≤ 1500€/mese tutto incluso"""
    # Casa.it: field "price.value"
    if "features" in annuncio and "price" in annuncio["features"]:
        price_data = annuncio["features"]["price"]
        if isinstance(price_data, dict) and "value" in price_data:
            price_str = price_data["value"]
            try:
                price = float(price_str.replace(".", "").replace(",", "."))
                if price <= BUDGET:
                    return True, f"prezzo={price}€"
                else:
                    return False, f"prezzo={price}€ > {BUDGET}€"
            except:
                pass

    # Subito: field "price.value"
    if "price" in annuncio and isinstance(annuncio["price"], dict):
        price_val = annuncio["price"].get("value")
        if price_val:
            try:
                price = float(price_val)
                if price <= BUDGET:
                    return True, f"prezzo={price}€"
                else:
                    return False, f"prezzo={price}€ > {BUDGET}€"
            except:
                pass

    return False, "prezzo non disponibile"

def filter_5_dotazioni(annuncio):
    """Filtro 5: wifi + lavatrice obbligatori"""
    # Cercame campi di dotazioni nel JSON
    # Per Casa.it e Subito, cercare in "description" e altri campi
    desc = ""
    if "description" in annuncio:
        desc = annuncio["description"].lower()
    elif "title" in annuncio:
        desc = annuncio["title"].lower()

    # Ricerca semplice nel testo
    has_wifi = "wifi" in desc or "fiber" in desc or "internet" in desc
    has_lavatrice = "lavatrice" in desc or "washing" in desc or "lavatr" in desc

    # Se non verificabili nel testo, scarta
    if not has_wifi or not has_lavatrice:
        return False, f"wifi={has_wifi}, lavatrice={has_lavatrice} (obbligatorie mancanti)"

    return True, "wifi ✓, lavatrice ✓"

def filter_6_metro(annuncio):
    """Filtro 6: ≤7 min a piedi dalla metro"""
    # Per ora, non possiamo verificare senza Google Maps
    # PLACEHOLDER: assumi che non sia verificabile dal dataset JSON
    return False, "distanza metro non verificabile nel dataset"

def filter_7_universita(annuncio):
    """Filtro 7: <40 min da Bicocca E Bovisa"""
    # Simile a filter_6, richiede Google Maps
    return False, "distanza università non verificabile nel dataset"

# === FUNZIONE PER COSTRUIRE ID STABILE ===
def build_id(annuncio, portale):
    """Costruisci ID univoco stabile"""
    if portale == "casa.it":
        if "id" in annuncio:
            return f"casa-it-{annuncio['id']}"
        if "uri" in annuncio:
            return f"casa-it-{annuncio['uri'].replace('/', '-')}"
    elif portale == "subito":
        if "id" in annuncio:
            return f"subito-{annuncio['id']}"
        if "request_url" in annuncio:
            url_hash = str(hash(annuncio['request_url']))[-6:]
            return f"subito-{url_hash}"

    return None

# === APPLICA FILTRI GERARCHICI ===
def applica_filtri(annuncio, portale):
    """Applica i 7 filtri in ordine. Ritorna (esito, motivo)"""
    filtri = [
        ("F1 posti letto", filter_1_posti_letto),
        ("F2 metratura", filter_2_metratura),
        ("F3 disponibilita", filter_3_disponibilita),
        ("F4 prezzo", filter_4_prezzo),
        ("F5 dotazioni", filter_5_dotazioni),
        ("F6 metro", filter_6_metro),
        ("F7 università", filter_7_universita),
    ]

    for nome_filtro, filtro_fn in filtri:
        passed, motivo = filtro_fn(annuncio)
        if not passed:
            return "scartato", f"{nome_filtro}: {motivo}"

    return "accettato", "tutti i criteri superati"

# === ESTRAI DATI PER REGISTRO ===
def extract_data(annuncio, portale):
    """Estrai dati principali per l'entry in analizzati.json"""
    data = {
        "portale": portale,
        "analizzato_il": datetime.date.today().isoformat(),
    }

    # URL
    if portale == "casa.it" and "uri" in annuncio:
        data["url"] = f"https://www.casa.it/immobili/{annuncio.get('id', 'unknown')}/"
    elif portale == "subito" and "page_url" in annuncio:
        data["url"] = annuncio["page_url"]

    # Dati grezzi per referenza
    dati_raccolti = {}

    # Mq
    if "features" in annuncio:
        if "mq" in annuncio["features"]:
            val = annuncio["features"]["mq"]
            if isinstance(val, dict):
                val = val.get("value")
            dati_raccolti["mq"] = val
        if "size_sqm" in annuncio["features"]:
            val = annuncio["features"]["size_sqm"]
            if isinstance(val, dict):
                val = val.get("value")
            dati_raccolti["mq"] = val

    # Rooms
    if "features" in annuncio and "rooms" in annuncio["features"]:
        val = annuncio["features"]["rooms"]
        if isinstance(val, dict):
            val = val.get("value")
        dati_raccolti["camere"] = val

    # Price
    if "features" in annuncio and "price" in annuncio["features"]:
        val = annuncio["features"]["price"]
        if isinstance(val, dict):
            val = val.get("value")
        dati_raccolti["prezzo"] = val
    elif "price" in annuncio:
        val = annuncio["price"]
        if isinstance(val, dict):
            val = val.get("value")
        dati_raccolti["prezzo"] = val

    data["dati_raccolti"] = dati_raccolti
    return data

# === MAIN ===
def main():
    print(f"[{datetime.datetime.now().isoformat()}] INIZIO ELABORAZIONE")

    # Carica stato precedente
    state = load_analizzati()
    existing_ids = get_existing_ids(state)

    # Carica cache
    all_annunci = load_cache_files()
    print(f"Caricati {len(all_annunci)} annunci dai file cache")

    # Conta per portale
    casa_count = sum(1 for a in all_annunci if "features" in a and "price" in a.get("features", {}))
    subito_count = len(all_annunci) - casa_count

    print(f"Stima: ~{casa_count} da Casa.it, ~{subito_count} da Subito")

    # Processa annunci
    new_annunci = []
    accettati = []
    scartati_per_motivo = {}

    for i, annuncio in enumerate(all_annunci):
        # Determina portale
        if "features" in annuncio and "price" in annuncio.get("features", {}):
            portale = "casa.it"
        elif "page_url" in annuncio and "subito.it" in annuncio["page_url"]:
            portale = "subito"
        else:
            portale = "unknown"

        # Costruisci ID
        ann_id = build_id(annuncio, portale)
        if not ann_id:
            print(f"  [SKIP] Annuncio {i}: ID non costruibile")
            continue

        # Salta se già analizzato
        if ann_id in existing_ids:
            continue

        # Applica filtri
        esito, motivo = applica_filtri(annuncio, portale)

        # Estrai dati
        dati = extract_data(annuncio, portale)
        dati["id"] = ann_id
        dati["esito"] = esito
        dati["motivo_scarto"] = motivo if esito == "scartato" else None

        new_annunci.append(dati)

        if esito == "accettato":
            accettati.append(annuncio)
        else:
            motivo_key = motivo.split(":")[0] if ":" in motivo else motivo
            scartati_per_motivo[motivo_key] = scartati_per_motivo.get(motivo_key, 0) + 1

        # Progress
        if (i + 1) % 50 == 0:
            print(f"  [{i+1}/{len(all_annunci)}] {len(new_annunci)} nuovi, {len(accettati)} accettati")

    # Aggiorna stato
    state["last_run"] = datetime.datetime.now().isoformat()
    state["annunci"].extend(new_annunci)
    save_analizzati(state)

    # Stampa riassunto
    print(f"\n=== RIASSUNTO RUN 2026-05-17 ===")
    print(f"Annunci nuovi analizzati: {len(new_annunci)}")
    print(f"Accettati: {len(accettati)}")
    print(f"Scartati: {len(new_annunci) - len(accettati)}")
    print(f"  Motivi scarto:")
    for motivo, count in sorted(scartati_per_motivo.items(), key=lambda x: -x[1]):
        print(f"    - {motivo}: {count}")

if __name__ == "__main__":
    main()
