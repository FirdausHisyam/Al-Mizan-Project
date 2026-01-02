#!/usr/bin/env python3
"""
download_sources.py
Downloads Quran from Tanzil.net (XML) + 40 Nawawi Hadith.
"""
import requests
import os
import sys

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")

# Tanzil.net direct download URLs (official sources)
TANZIL_URLS = {
    "uthmani": "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=xml-uthmani&agree=true",
    "simple": "https://tanzil.net/pub/download/index.php?quranType=simple&outType=xml&agree=true",
    "metadata": "https://tanzil.net/res/text/metadata/quran-data.xml"
}

TRANSLATION_URLS = {
    "en_sahih": "https://tanzil.net/trans/?transID=en.sahih&type=xml"
}

HADITH_URL = "https://raw.githubusercontent.com/Kandil7/hadith_nawawi/master/assets/hadiths.json"

def download_file(url: str, filename: str, description: str) -> bool:
    """Download a file with error handling."""
    filepath = os.path.join(DATA_DIR, filename)
    print(f"📥 Downloading {description}...")
    
    try:
        response = requests.get(url, timeout=60, allow_redirects=True)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            f.write(response.content)
        
        size_kb = len(response.content) / 1024
        print(f"   → Saved: {filepath} ({size_kb:.1f} KB)")
        return True
    except requests.RequestException as e:
        print(f"❌ Failed: {e}")
        return False

def main():
    os.makedirs(DATA_DIR, exist_ok=True)
    
    print("🕌 TANZIL.NET QURAN DOWNLOAD")
    print("=" * 40)
    
    # Download Uthmani XML
    download_file(
        TANZIL_URLS["uthmani"],
        "quran-uthmani.xml",
        "Quran (Uthmani Script)"
    )
    
    # Download metadata
    download_file(
        TANZIL_URLS["metadata"],
        "quran-data.xml",
        "Quran Metadata"
    )
    
    # Try to download English translation
    # Note: Tanzil translations require acceptance, may need manual download
    print("\n⚠️  For translations, manually download from:")
    print("   https://tanzil.net/trans/")
    print("   Select 'Sahih International' → XML format")
    print("   Save as: data/en.sahih.xml")
    
    # Download Hadith
    print("\n📥 Downloading 40 Nawawi Hadith...")
    try:
        response = requests.get(HADITH_URL, timeout=30)
        response.raise_for_status()
        
        filepath = os.path.join(DATA_DIR, "hadith40.json")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(response.text)
        
        import json
        hadith_data = json.loads(response.text)
        hadith_count = len(hadith_data.get('hadiths', []))
        print(f"   → Saved: {filepath} ({hadith_count} hadiths)")
    except Exception as e:
        print(f"❌ Hadith download failed: {e}")
    
    print("\n🎉 DONE!")
    print("\nNext: Run `python transform_tanzil.py` to generate ingest script.")

if __name__ == "__main__":
    main()
