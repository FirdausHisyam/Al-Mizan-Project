#!/usr/bin/env python3
"""
transform_morphology.py

Stage 3 of the Al-Mizan ETL Pipeline.

Responsibility:
1. Parse Quranic Corpus Morphology (v0.4) text file.
2. Extract Root Words (e.g. ROOT:ktb).
3. Generate 'root_word' nodes (using Hex IDs for collision safety).
4. Generate 'quran_verse -> has_root -> root_word' edges.

Inputs:
- database/quranic-corpus-morphology-0.4.txt

Outputs:
- output/morphology.surql
"""
import os
import re

BASE_DIR = os.path.dirname(__file__)
DATA_PATH = os.path.join(BASE_DIR, "../database/quranic-corpus-morphology-0.4.txt")
OUTPUT_DIR = os.path.join(BASE_DIR, "output")

def escape_surql(text: str) -> str:
    return text.replace("\\", "\\\\").replace("'", "\\'")

def parse_morphology():
    print(f"📖 Parsing {DATA_PATH}...")
    
    if not os.path.exists(DATA_PATH):
        print(f"❌ File not found: {DATA_PATH}")
        return
        
    unique_roots = set()
    verse_roots = {}  # "surah:ayah" -> set(roots)
    
    # Regex to find ROOT:xyz
    # Matches: ROOT:abc or ROOT:>mn etc.
    # Roots can contain special chars like > & < { } in this transliteration scheme
    root_pattern = re.compile(r"ROOT:([^|]+)")
    loc_pattern = re.compile(r"\((\d+):(\d+):(\d+):(\d+)\)")
    
    count = 0
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
                
            parts = line.split("\t")
            if len(parts) < 4:
                continue
                
            loc_str = parts[0]
            features = parts[3]
            
            # Extract Location (Surah:Ayah)
            m_loc = loc_pattern.match(loc_str)
            if not m_loc:
                continue
                
            surah, ayah, word, part = m_loc.groups()
            verse_key = f"{surah}_{ayah}"
            
            # Extract Root
            m_root = root_pattern.search(features)
            if m_root:
                root = m_root.group(1)
                unique_roots.add(root)
                
                if verse_key not in verse_roots:
                    verse_roots[verse_key] = set()
                verse_roots[verse_key].add(root)
                count += 1
                
    print(f"   → Found {len(unique_roots)} unique roots")
    print(f"   → Found roots in {len(verse_roots)} verses")
    
    return unique_roots, verse_roots

def generate_surql(unique_roots, verse_roots):
    print("📜 Generating Morphology SurQL...")
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    statements = []
    statements.append("-- MORPHOLOGY (Roots & Edges)")
    statements.append("-- Source: Quranic Arabic Corpus 0.4")
    
    # 1. Create Root Nodes (Chunked)
    statements.append("BEGIN TRANSACTION;")
    root_batch = 0
    root_batch_size = 500
    
    statements.append("-- ROOTS")
    for root in sorted(unique_roots):
        # Use deterministic hex encoding for ALL roots to avoid collisions/invalid chars
        # Old logic: clean_id = "".join(c for c in root if c.isalnum())
        root_hex = root.encode('utf-8').hex()
        root_id = f"root_word:hex_{root_hex}"
        stmt = f"CREATE {root_id} SET root_ar = '{escape_surql(root)}';"
        statements.append(stmt)
        
        root_batch += 1
        if root_batch >= root_batch_size:
            statements.append("COMMIT TRANSACTION;")
            statements.append("BEGIN TRANSACTION;")
            root_batch = 0
            
    statements.append("COMMIT TRANSACTION;")
    statements.append("")
    
    # 2. Create Edges (Chunked)
    statements.append("-- EDGES (has_root)")
    
    batch_size = 500
    current_batch = 0
    statements.append("BEGIN TRANSACTION;")
    
    for verse_key, roots in verse_roots.items():
        verse_id = f"quran_verse:{verse_key}"
        
        for root in roots:
            # clean_id = "".join(c for c in root if c.isalnum())
            # if not clean_id:
            #     clean_id = f"hex_{root.encode('utf-8').hex()}"
            # Use deterministic hex encoding for ALL roots to avoid collisions/invalid chars
            root_hex = root.encode('utf-8').hex()
            root_id = f"root_word:hex_{root_hex}"
            
            stmt = f"RELATE {verse_id} -> has_root -> {root_id};"
            statements.append(stmt)
            
        current_batch += 1
        if current_batch >= batch_size:
            statements.append("COMMIT TRANSACTION;")
            statements.append("BEGIN TRANSACTION;")
            current_batch = 0
            
    statements.append("COMMIT TRANSACTION;")
    
    output_path = os.path.join(OUTPUT_DIR, "morphology.surql")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(statements))
        
    print(f"   → Generated: {output_path}")

def main():
    data = parse_morphology()
    if data:
        unique_roots, verse_roots = data
        generate_surql(unique_roots, verse_roots)
        
        # Append to ingest
        ingest_path = os.path.join(OUTPUT_DIR, "ingest.surql")
        if os.path.exists(ingest_path):
            with open(ingest_path, 'a', encoding='utf-8') as f:
                f.write(f"\n\n-- === morphology.surql ===\n")
                with open(os.path.join(OUTPUT_DIR, "morphology.surql"), 'r') as mf:
                    f.write(mf.read())
            print(f"   → Appended to: {ingest_path}")

if __name__ == "__main__":
    main()
