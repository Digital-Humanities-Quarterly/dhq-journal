xquery version "3.1";

  (:declare boundary-space preserve;:)
(:  LIBRARIES  :)
  import module namespace dbfx="http://digitalhumanities.org/dhq/ns/biblio/lib"
    at "../apps/lib/biblio-functions.xql";
  import module namespace dbqx="http://digitalhumanities.org/dhq/ns/biblio-qa/rest"
    at "../apps/biblio-workbench.xq";
  import module namespace provxq="http://digitalhumanities.org/dhq/ns/prov" 
    at "../apps/lib/prov.xql";
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace bprov="http://digitalhumanities.org/dhq/biblio-qa/prov/";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace prov="http://www.w3.org/ns/prov#";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
(:  OPTIONS  :)
  declare option output:indent "yes";

(:~
  Create a PROV entries for the current DHQ Biblio working environment.
  
  Note that this script assumes that there is no DHQ Biblio provenance data. Instead, it mints new PROV
  entries and infers relationships.
  
  @author Ashley M. Clark
  2019
 :)
 
(:  VARIABLES  :)
  declare variable $v2-biblio-entries := 
    db:open('biblio-all')/dbib:BiblioSet/dbib:*/@ID;

(:  FUNCTIONS  :)
  (: For a given index entry and database name, return any matching Biblio records. (Bad index entries 
    are ignored.) :)
  declare function local:get-entity-subject($index-entry as node(), $database-name as xs:string) {
    for $id in $index-entry/node[@db eq $database-name]
    return
      try { 
        db:open-id($database-name, xs:integer($id))
      } catch * { () }
  };


(:  MAIN QUERY  :)

(: Use the ID custom index to determine the status of the record across the Biblio databases. :)
let $indexedIds := doc("/biblio-custom-index/biblio-id-index.xml")/index/text[@string]
(: Create an activity statement for the import of Biblio v.2 data from Subversion into BaseX. :)
let $v2Import := 
  let $id := xs:QName("bprov:import-bibliov2")
  let $label :=
    <prov:label xml:lang="en">Import of Biblio data from Biblio version 2 XML.</prov:label>
  let $when :=
    db:list-details('biblio-all')[1]/@modified-data/xs:dateTime(.)
  let $activity := dbqx:make-data-import-prov-activity($label)
  return
    provxq:activity($id, $when, (), $label)
(: Build a collection of statements for each index entry. :)
let $provExpressions :=
  for $entry in $indexedIds
  let $baseId := $entry/@string/data(.)
  (: The "generic entity" is the platonic ideal of the bibliography entry referred to by the current 
    identifier. :)
  let $genericEntity := dbqx:make-generic-prov-entity($baseId)
  let $dbs := sort($entry/node/@db/data(.))
  (: Create specific entity statements for the identified entry as embodied in each Biblio database. :)
  let $publicSubjects := local:get-entity-subject($entry, 'biblio-public')
  let $workingSubjects := local:get-entity-subject($entry, 'biblio-working')
  let $dbEntityObjs := ($publicSubjects, $workingSubjects)
  (: Each specific entity is considered a specialization of the generic one. :)
  let $dbSpecificEntities :=
    for $i in 1 to count($dbEntityObjs)
    let $dbName := $dbs[$i]
    let $obj := $dbEntityObjs[$i]
    let $useId := 
      let $disambiguator := substring('abcdefghijklmnopqrstuvwxyz',$i,1)
      return dbqx:mint-prov-identifier($baseId, $disambiguator)
    return
      dbqx:make-specialized-prov-entity($obj, $dbName, $genericEntity, $useId)
  let $v2Statements :=
    (: If there is a "biblio-public" entry, and a version in the Biblio v.2 entries, we know that the 
      "public" entry was derived from the v2 entry—meaning we need an entity for the v2 entry. :)
    if ( count($publicSubjects) eq 1 and $baseId = $v2-biblio-entries/data(.) ) then
      let $v2Record := $v2-biblio-entries[data(.) eq $baseId]/parent::*
      let $v2Entity := 
        dbqx:make-specialized-prov-entity($v2Record, 'biblio-all', $genericEntity)
      return (
          $v2Entity,
          provxq:was-derived-from((), $dbSpecificEntities[1], $v2Entity[1], $v2Import)
        )
    else ()
  let $moreRelationships := (
    (: If both "biblio-working" and "biblio-public" have a version of the entry, we can assume that the 
      "working" entity is a revision of the "public" entity. :)
    if ( count($workingSubjects) eq 1 and count($publicSubjects) eq 1 ) then
      provxq:was-derived-from((), $dbSpecificEntities[3], $dbSpecificEntities[1], (), (), (), 
        <prov:type>prov:Revision</prov:type>)
    else ()
  )
  order by lower-case($baseId)
  return
    ( $genericEntity, $v2Statements, $dbSpecificEntities, $moreRelationships )
(: Create a wrapper document for these PROV statements. :)
let $docComponents := (
    namespace bprov { "http://digitalhumanities.org/dhq/biblio-qa/prov/" },
    namespace dbib { "http://digitalhumanities.org/dhq/ns/biblio" },
    namespace xsd { "http://www.w3.org/2001/XMLSchema" },
    $v2Import,
    $provExpressions
  )
return provxq:document($docComponents)
