import xml.etree.ElementTree as ET
from collections import defaultdict
import os
import re
import shutil

file_year = {}
parsed_files = []
files_by_year = defaultdict(list)
file_year_txt = {}
txt_paths_by_year = defaultdict(list)

def extract_year_from_xml(path):
    tree = ET.parse(path)
    root = tree.getroot()
    year_node = root.find(".//publication_year") or root.find(".//date")
    if year_node is None:
        return None
    return int(year_node.text.strip()[:4])

def extract_year_from_text(path):
    with open(path, encoding="utf-8", errors="ignore") as f:
        head = f.read(8192)

    date_match = re.search(r'^(?:Date|date|Publication Date|publication date)\s*:\s*(.+)$', head, flags=re.MULTILINE)
    if date_match:
        year_match = re.search(r"\b(19|20)\d{2}\b", date_match.group(1))
        if year_match:
            return int(year_match.group(0))

    fallback_match = re.search(r"\b(19|20)\d{2}\b", head)
    if fallback_match:
        return int(fallback_match.group(0))

    return None

base_dir = "/Users/smwhitver/Desktop/dhq-journal-Sara"
articles_dir = os.path.join(base_dir, "articles")
file_names = []

for root, dirs, files in os.walk(articles_dir):
    rel = os.path.relpath(root, articles_dir)
    if rel != ".":
        first_component = rel.split(os.sep)[0]
        if re.fullmatch(r"\d{4}", first_component):
            continue

    for fname in files:
        if fname.endswith(".txt"):
            path = os.path.join(root, fname)
            numeric_name = os.path.basename(root) if os.path.basename(root).isdigit() else None
            if numeric_name is None:
                match = re.search(r"(\d{6})", fname)
                numeric_name = match.group(1) if match else fname

            if numeric_name not in file_names:
                file_names.append(numeric_name)

            year = extract_year_from_text(path)
            if year:
                if numeric_name not in file_year_txt:
                    file_year_txt[numeric_name] = year
                txt_paths_by_year[year].append(path)

# Create year directories inside articles for each extracted publication year
year_dirs = {}
for year in sorted(txt_paths_by_year.keys()):
    year_dir = os.path.join(articles_dir, str(year))
    os.makedirs(year_dir, exist_ok=True)
    year_dirs[year] = year_dir
    for txt_path in txt_paths_by_year[year]:
        dest = os.path.join(year_dir, os.path.basename(txt_path))
        shutil.copy2(txt_path, dest)

for root, dirs, files in os.walk(base_dir):
    for fname in files:
        if fname.endswith(".xml"):
            path = os.path.join(root, fname)
            try:
                year = extract_year_from_xml(path)
            except Exception:
                continue
            if year:
                file_year[path] = year
                files_by_year[year].append(path)

print(f"Found {len(file_names)} numeric .txt file names in {articles_dir}")
print("file_names:")
for numeric_name in sorted(file_names):
    print(numeric_name)

print(f"\nCreated {len(year_dirs)} year directories in {articles_dir}")
for year, year_dir in sorted(year_dirs.items()):
    print(f"{year}: {year_dir}")

print(f"\nExtracted years for {len(file_year_txt)} numeric .txt names")
for numeric_name, year in sorted(file_year_txt.items(), key=lambda x: x[0]):
    print(f"{numeric_name}: {year}")