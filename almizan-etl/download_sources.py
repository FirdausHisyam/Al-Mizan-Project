#!/usr/bin/env python3
"""
download_sources.py
Downloads Juz 30 (Quran) + 40 Nawawi Hadith from public APIs.
"""
import requests
import json
import os
import sys

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")

def download_json(url: str, description: str) -> dict:
    """Fetch JSON from URL with error handling."""
    print(f"📥 Downloading {description}...")
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"❌ Failed to fetch {description}: {e}")
        sys.exit(1)

def save_json(data: dict, filename: str):
    """Save JSON to data directory."""
    filepath = os.path.join(DATA_DIR, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"   → Saved: {filepath}")

def main():
    # Create data folder
    os.makedirs(DATA_DIR, exist_ok=True)
    
    # --- QURAN: Juz 30 ---
    juz30_ar = download_json(
        "http://api.alquran.cloud/v1/juz/30/quran-uthmani",
        "Juz 30 (Arabic/Uthmani)"
    )
    save_json(juz30_ar, "juz30_arabic.json")
    
    juz30_en = download_json(
        "http://api.alquran.cloud/v1/juz/30/en.sahih",
        "Juz 30 (English/Sahih International)"
    )
    save_json(juz30_en, "juz30_english.json")
    
    verse_count = len(juz30_ar.get('data', {}).get('ayahs', []))
    print(f"✅ Juz 30: {verse_count} verses\n")
    
    # --- HADITH: 40 Nawawi ---
    hadith40 = download_json(
        "https://raw.githubusercontent.com/Kandil7/hadith_nawawi/master/assets/hadiths.json",
        "40 Nawawi Hadith"
    )
    save_json(hadith40, "hadith40.json")
    
    hadith_count = len(hadith40.get('hadiths', []))
    print(f"✅ Hadith 40: {hadith_count} hadiths\n")
    
    # --- SUMMARY ---
    print("🎉 DONE! Files saved:")
    print(f"   • {DATA_DIR}/juz30_arabic.json")
    print(f"   • {DATA_DIR}/juz30_english.json")
    print(f"   • {DATA_DIR}/hadith40.json")
    print("\nNext: Run `python transform_to_surql.py` to generate ingest script.")

if __name__ == "__main__":
    main()
