#!/usr/bin/env python3
"""
Fetch and transform 99 Names of Allah (Asma ul Husna) to SurQL
"""
import json
import urllib.request
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")

def escape_surql(text: str) -> str:
    if not text:
        return ""
    return text.replace("\\", "\\\\").replace("'", "\\'")

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Fetch from AlAdhan API
    url = "https://api.aladhan.com/v1/asmaAlHusna"
    print(f"📥 Fetching from {url}...")
    
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
    
    names = data.get('data', [])
    print(f"   Found {len(names)} divine names")
    
    # Generate SurQL
    statements = []
    for name in names:
        num = name.get('number', 0)
        arabic = escape_surql(name.get('name', ''))
        translit = escape_surql(name.get('transliteration', ''))
        meaning = escape_surql(name.get('en', {}).get('meaning', ''))
        
        stmt = f"CREATE divine_name:{num} CONTENT {{"
        stmt += f"arabic: '{arabic}', "
        stmt += f"transliteration: '{translit}', "
        stmt += f"meaning_en: '{meaning}'"
        stmt += "};"
        statements.append(stmt)
    
    # Write output
    output_path = os.path.join(OUTPUT_DIR, "divine_names.surql")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("-- 99 Names of Allah (Asma ul Husna)\n")
        f.write("-- Source: AlAdhan API\n\n")
        for stmt in statements:
            f.write(stmt + "\n")
    
    print(f"\n✅ Generated: {output_path}")
    print(f"   Total names: {len(statements)}")

if __name__ == "__main__":
    main()
