xquery version "3.1";

  (:declare boundary-space preserve;:)
(:  LIBRARIES  :)
  import module namespace dbfx="http://digitalhumanities.org/dhq/ns/biblio/lib" at "biblio-functions.xql";
  import module namespace mgmt="http://digitalhumanities.org/dhq/ns/biblio/maintenance" at "database-maintenance.xql";
(:  NAMESPACES  :)
  declare namespace db="http://basex.org/modules/db";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  (:declare option output:indent "no";:)

 (:~
  
  :)
 
(:  VARIABLES  :)
  declare variable $allIDs := 
    let $publicIDs := db:open($dbfx:db-public)//@ID
    let $workingIDs := db:open($dbfx:db-working,'records')//@ID
    return 
      ( $publicIDs, $workingIDs );
  declare variable $indexFilename := $mgmt:custom-indexes?('id')?('filename');


(:  FUNCTIONS  :)
  declare function local:make-id-entries($idAttrs as attribute()*) as node()* {
    for $ids in $idAttrs
    group by $id := $ids/data(.)
    return 
      <text string="{$id}">
      {
        for $match in $ids
        let $db := db:name($match)
        return
          <id db="{$db}">{ db:node-id($match/parent::*) }</id>
      }
      </text>
  };


(:  MAIN QUERY  :)

(: If the ID index doesn't exist yet, create a full index and create the document. :)
if ( not(db:exists($mgmt:db-custom-indexes, $indexFilename)) ) then
  let $index :=
    <index>{ local:make-id-entries($allIDs) }</index>
  return
    db:replace($mgmt:db-custom-indexes, $indexFilename, $index)
(: If the ID index exists, add any missing ID entries. :)
else
  let $indexDoc := 
    let $path := concat('/',$mgmt:db-custom-indexes,'/',$indexFilename)
    return doc($path)
  let $indexedIds := $indexDoc//text/@string/data(.)
  let $unindexed := $allIDs[not(data(.) = $indexedIds)]
  let $newEntries := local:make-id-entries($unindexed)
  return
    insert nodes $newEntries into $indexDoc/index
