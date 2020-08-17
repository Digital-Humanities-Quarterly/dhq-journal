xquery version "3.0";

  (:declare boundary-space preserve;:)
  declare copy-namespaces preserve, inherit;
(:  NAMESPACES  :)
  declare default element namespace "http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare option output:indent "no";

(:~
  Given a Biblio v2 index, create v3 files for each individual Biblio item.
  
  @author Ashley M. Clark
  2018-12-10
:)
 
  declare context item external := doc('../../../DHQ-Biblio-v2/data/current/Biblio-Z.xml');

(:  VARIABLES  :)
  declare variable $data-directory := "file:///Users/ashleyclark/DHQ/dhq/biblio/DHQ-Biblio-v3/data";
  declare variable $newline := "
";


(:  MAIN QUERY  :)

for $bibItem in /BiblioSet/*
let $bibID := $bibItem/@ID/data(.)
let $filepath := $data-directory || '/' || $bibID || '.xml'
let $v3Item :=
  document {
    $newline,
    processing-instruction xml-model 
      { 'href="../schema/dhqBiblio.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"' },
    $newline,
    $bibItem
  }
return put($v3Item, $filepath)

