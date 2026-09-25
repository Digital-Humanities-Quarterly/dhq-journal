# XML Extraction in Python
import xml.etree.ElementTree as ET
import os


def xmlExtraction(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()

    # namespace
    tei_ns = {"tei": "http://www.tei-c.org/ns/1.0"}
    dhq_ns = {"dhq": "http://www.digitalhumanities.org/ns/dhq"}


    xml_directory = os.path.dirname(file_path)
    article_name = os.path.splitext(os.path.basename(file_path))[0]
    output_path = os.path.join(xml_directory, f"{article_name}_fulltext.csv")

    with open(output_path, "a", encoding="utf-8") as f:
       
        title = root.find(".//tei:titleStmt/tei:title", namespaces=tei_ns)
        print("Title: ", title.text, file=f)

        volume = root.find(".//tei:publicationStmt/tei:idno[@type='volume']", namespaces=tei_ns)
        print("Volume: ", volume.text, file=f)

        issue = root.find(".//tei:publicationStmt/tei:idno[@type='issue']", namespaces=tei_ns)
        print("Issue: ", issue.text, file=f)

        date = root.find(".//tei:publicationStmt/tei:date", namespaces=tei_ns)
        print("Date: ", date.text, file=f)

        for abstract in root.findall(".//tei:text/tei:front/dhq:abstract", namespaces={**tei_ns, **dhq_ns}):
            full_abstract = "".join(abstract.itertext())
            print("Abstract: ", full_abstract, file=f)

        print("Full Body Text: ", file=f)
        for body in root.findall(".//tei:text/tei:body/", namespaces={**tei_ns, **dhq_ns}):
            full_body = "".join(body.itertext())
            print(full_body, file=f)  
    
#------------------------------------------------------------------------------------------------------------------------

# Calling on the function "xmlExtraction"
xmlDir = "/Users/smwhitver/Desktop/dhq-journal-Sara/articles" # <- the directory to the full folder where all of the files are located

for root_dir, dirs, files in os.walk(xmlDir):
    for file in files:
        if file.endswith(".xml"):
            xmlExtraction(os.path.join(root_dir, file))







