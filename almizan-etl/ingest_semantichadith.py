import json
import re
import uuid

INPUT_FILE = "/home/a/code/Islamic-Digital-Citadel/almizan-etl/data/semantichadith/SemanticHadith-V2/SemanticHadithKGV2.ttl"
OUTPUT_FILE = "/home/a/code/Islamic-Digital-Citadel/almizan-etl/hadith_nodes.jsonl"

def parse_ttl_value(line):
    # Extract value from quotes or URI
    # content "..."^^xsd:string or <uri>
    if '"' in line:
        # Extract content inside quotes
        match = re.search(r'"(.*?)"', line)
        if match:
            return match.group(1)
    elif "<" in line:
         match = re.search(r'<(.*?)>', line)
         if match:
             return match.group(1).split('/')[-1] # Extract ID from URI
    return None

def extract_property(line):
    # Returns (predicate, object)
    parts = line.split(maxsplit=2)
    if len(parts) >= 2:
        pred = parts[0]
        # Object might be complex
        obj_raw = " ".join(parts[1:])
        # Remove trailing ; or .
        obj_raw = obj_raw.rstrip(' ;.')
        return pred, obj_raw
    return None, None

def process_file():
    print(f"Reading {INPUT_FILE}...")
    hadith_count = 0
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f_in, open(OUTPUT_FILE, 'w', encoding='utf-8') as f_out:
        buffer = []
        
        for line in f_in:
            line = line.strip()
            
            # Skip empty lines or comments if buffer empty
            if not line or line.startswith('#'):
                if not buffer: 
                    continue
            
            # Start of block usually indicated by separate line or just accumulation
            # We accumulate until line ends with '.'
            buffer.append(line)
            
            if line.endswith('.'):
                full_block = " ".join(buffer)
                
                # Check directly if this block defines a Hadith instance
                # Look for ":Hadith" and "rdf:type"
                if ":Hadith" in full_block and ("rdf:type" in full_block or " a " in full_block) and "owl:Class" not in full_block:
                    
                    # Parse properties from the BUFFER lines, which verify structure better
                    hadith_obj = {
                        "id": f"hadith:{uuid.uuid4()}",
                        "type": "hadith",
                        "source": "semantichadith_v2"
                    }
                    
                    for buf_line in buffer:
                        pred, val_raw = extract_property(buf_line)
                        if not pred: continue
                        
                        val = parse_ttl_value(val_raw)
                        if not val: continue

                        if ":fullHadithText" in pred:
                            hadith_obj["body"] = val
                        elif ":hadithReferenceNo" in pred:
                            try:
                                hadith_obj["ref_no"] = int(val)
                            except:
                                hadith_obj["ref_no"] = val
                        elif ":hasRootNarrator" in pred:
                            # val is likely an ID/URI fragment
                            hadith_obj["narrator_id"] = val
                        elif ":isPartOfChapter" in pred:
                            hadith_obj["chapter_id"] = val
                    
                    # Only write if we have minimal data
                    if "body" in hadith_obj:
                        f_out.write(json.dumps(hadith_obj) + "\n")
                        hadith_count += 1
                        if hadith_count % 1000 == 0:
                            print(f"Processed {hadith_count} hadiths...")
                
                buffer = []

    print(f"Done. Generated {hadith_count} hadiths in {OUTPUT_FILE}")

if __name__ == "__main__":
    process_file()
