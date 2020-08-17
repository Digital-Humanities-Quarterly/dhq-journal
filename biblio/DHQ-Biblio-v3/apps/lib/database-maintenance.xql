xquery version "3.1";

  module namespace mgmt="http://digitalhumanities.org/dhq/ns/biblio/maintenance";
(:  LIBRARIES  :)
  import module namespace provxq="http://digitalhumanities.org/dhq/ns/prov" at "prov.xql";
(:  NAMESPACES  :)
  declare namespace bprov="http://digitalhumanities.org/dhq/biblio-qa/prov/";
  declare namespace db="http://basex.org/modules/db";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace file="http://expath.org/ns/file";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace jobs="http://basex.org/modules/jobs";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace prov="http://www.w3.org/ns/prov#";
  declare namespace rerr="http://exquery.org/ns/restxq/error";
  declare namespace rest="http://exquery.org/ns/restxq";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace update="http://basex.org/modules/update";
  declare namespace xhtml="http://www.w3.org/1999/xhtml";

(:~
  A library of functions for keeping DHQ Biblio databases.
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  Created 2019
 :)


(:  VARIABLES  :)
  declare variable $mgmt:custom-indexes     := map {
      'id'          : map { 'filename': 'biblio-id-index.xml',
                            'generate-entry': mgmt:create-node-entry-for(?),
                            'type': 'node'  },
      'location'    : map { 'filename': 'locations.xml',
                            'generate-entry': function ($node) {()},
                            'type': 'value' },
      'publisher'   : map { 'filename': 'publishers.xml',
                            'generate-entry': function ($node) {()},
                            'type': 'value' }
    };
  declare variable $mgmt:db-articles        := 'dhq-articles';
  declare variable $mgmt:db-custom-indexes  := 'biblio-custom-index';
  declare variable $mgmt:db-public          := 'biblio-public';
  declare variable $mgmt:db-working         := 'biblio-working';
  declare variable $mgmt:dhq-article-regex  := "[0-8]\d{5,5}(/[0-8]\d{5,5}\.xml)?$";


(:  FUNCTIONS  :)
  
  
  (:~ Given an identifier, determine if it has an entry in the custom `@ID` index. :)
  declare function mgmt:biblio-id-entry-exists($id as xs:string) as xs:boolean {
    exists(mgmt:get-index-entry('id', $id))
  };
  
  (:~ Given an identifier, determine if it has an entry in the custom `@ID` index 
    that matches the requested $db-name. :)
  declare function mgmt:biblio-id-entry-exists($id as xs:string, $db-name as xs:string) as xs:boolean {
    exists(mgmt:get-index-entry('id', $id)/node[@db eq $db-name])
  };
  
  (:~ Given an identifier, determine if it already exists in Biblio by checking the 
    custom `@ID` index and making sure the entry refers to a Biblio entry. :)
  declare function mgmt:biblio-id-exists($id as xs:string) as xs:boolean {
    mgmt:biblio-id-entry-exists($id)
    and exists(mgmt:get-canonical-record($id))
  };
  
  (:~ Given an identifier, determine if it already exists in Biblio by checking the 
    custom `@ID` index and making sure the entry refers to a Biblio entry in the 
    requested database. :)
  declare function mgmt:biblio-id-exists($id as xs:string, $db-name as xs:string) as xs:boolean {
    mgmt:biblio-id-entry-exists($id, $db-name) 
    and mgmt:biblio-record-exists($id, $db-name)
  };
  
  declare function mgmt:biblio-record-exists($id as xs:string, $db-name as xs:string) {
    exists(mgmt:get-biblio-record($id, $db-name))
  };
  
  (:~ Create an index entry for a given value. Any instance entries (markers of 
    usage, by Biblio id or BaseX node id) are included. :)
  declare function mgmt:create-index-entry-for($value as xs:string, $instance-entries as item()*) {
    <text string="{ $value }">
      { $instance-entries }
    </text>
  };
  
  declare function mgmt:get-biblio-record($id, $db-name as xs:string) as node()? {
    let $entry := mgmt:get-index-entry('id', $id)/node[@db eq $db-name]
    return 
      mgmt:get-indexed-record($entry)
  };
  
  (:~ Get the node entry for the most up-to-date Biblio record with the given 
    identifier. The "biblio-working" database is preferred over the public one. :)
  declare %private function mgmt:get-canonical-id-entry($id as xs:string) {
    let $node-ids := mgmt:get-index-entry('id', $id)/node
    return
      if ( $node-ids[@db eq $mgmt:db-working] ) then
        $node-ids[@db/data(.) eq $mgmt:db-working][1]
      else $node-ids[1]    
  };
  
  (:~ Get the most up-to-date version of a Biblio record. The "biblio-working" 
    database is preferred over the public one. :)
  declare function mgmt:get-canonical-record($id as xs:string) as node()? {
    let $canonicalIndexEntry := mgmt:get-canonical-id-entry($id)
    return
      mgmt:get-indexed-record($canonicalIndexEntry)
  };
  
  (:~ Retrieve a custom index. :)
  declare function mgmt:get-custom-index($type as xs:string) {
    if ( $type = map:keys($mgmt:custom-indexes) ) then
      let $filename := $mgmt:custom-indexes?($type)?('filename')
      return db:open($mgmt:db-custom-indexes, $filename)
    else error()
  };
  
  (:~ Retrieve the base system filepath for files of a given database, if one exists. :)
  declare function mgmt:get-db-base-path($db-name as xs:string) as xs:string? {
    db:property($db-name, 'inputpath')
  };
  
  (:~ Identify and return the custom index entry for a Biblio identifier. :)
  declare function mgmt:get-index-entry($index-shortname as xs:string, $value as xs:string) as node()* {
    mgmt:get-custom-index($index-shortname)//text[@string eq $value]
  };
  
  (:~ Given an index entry for a Biblio item in a given database, retrieve the node 
    at the indexed address. :)
  declare function mgmt:get-indexed-record($id-entry as element()?) as node()? {
    if ( exists($id-entry) ) then
      let $db := $id-entry/@db/data(.)
      let $nodeId := $id-entry/text()
      return
        try {
          db:open-id($db, xs:integer($nodeId))
        } catch * { () }
    else ()
  };
  
  (:~:)
  declare function mgmt:get-provenance-record($id as xs:string) {
    let $dbName := mgmt:get-canonical-id-entry($id)/@db cast as xs:string
    return
      mgmt:get-provenance-record($id, $dbName)
  };
  
  (:~:)
  declare function mgmt:get-provenance-record($id as xs:string, $db-name as xs:string) {
    let $path := concat('/',$db-name, 
      if ( $db-name eq 'biblio-working' ) then '/records' else '',
      '/',$id,'/',$id,'.provx')
    return
      if ( doc-available($path) ) then
        doc($path)
      else ()
  };
  
  (:~ Check the filesystem for DHQ articles that haven't been ingested yet. :)
  declare function mgmt:identify-ingestible-articles() {
    let $allFiles := db:list-details($mgmt:db-articles)
    let $articlesPath := mgmt:get-db-base-path($mgmt:db-articles)
    let $allArticles := 
      file:list($articlesPath, true(), '*.xml')[matches(., $mgmt:dhq-article-regex)]
    return
      $allArticles[not(. = db:list($mgmt:db-articles))]
  };
  
  
  declare function mgmt:identify-outdated-files-in-db($db-name as xs:string) {
    (: Get a sequence of XML entries containing metadata for the documents stored in 
      a specified database, as well as the directory path to the original files. :)
    let $allFiles := db:list-details($db-name)
    let $basePath := mgmt:get-db-base-path($db-name)
    let $lastModifiedDate := $allFiles[1]/@modified-date/data(.)
    return
      (: For each document in the database, obtain its modification timestamps for 
        both the version indexed by the database, and the original version stored in 
        the file system. :)
      for $file in $allFiles
      let $filename := $file/text()
      let $fileSysPath := concat($basePath, $filename)
      let $fileMod := file:last-modified($fileSysPath)
      return
        (: If the document's file system modification date is greater than the 
          database modification date, return it as part of the sequence. :)
        if ( $fileMod > $lastModifiedDate ) then
          $file
        else ()
  };
  
  
  declare %updating function mgmt:index($index-shortname as xs:string, $value, $instances) {
    let $prevEntry := mgmt:get-index-entry($index-shortname, $value)
    let $indexOpts := $mgmt:custom-indexes?($index-shortname)
    let $instanceEntries :=
      for $instance in $instances
      return $indexOpts?('generate-entry')($instance)
    return
      if ( exists($prevEntry) ) then ()
        (:for $change in $instanceEntries[data(.) != $prevEntry/data(.)]:)
      else if ( exists(mgmt:get-custom-index($index-shortname)) ) then
        let $indexEntry := mgmt:create-index-entry-for($value, $instanceEntries)
        return
          insert node $indexEntry into mgmt:get-custom-index($index-shortname)/index
      else
        let $newIndex := mgmt:create-custom-index($indexOpts, $instances)
        return
          db:replace($mgmt:db-custom-indexes, $indexOpts?('filename'), document {$newIndex})
  };
  
  
  declare %updating function mgmt:index-all($index-shortname as xs:string, $entries as node()*) {
    let $indexOpts := $mgmt:custom-indexes?($index-shortname)
    let $indexDoc := mgmt:get-custom-index($index-shortname)
    return
      if ( not(exists($indexDoc)) ) then 
        let $newIndex := <index>{ $entries }</index>
        return
          db:replace($mgmt:db-custom-indexes, $indexOpts?('filename'), document {$newIndex})
      else 
        for $entry in $entries
        let $value := $entry//@value/data(.)
        let $prevEntry := 
          if ( $value ) then 
            mgmt:get-index-entry($index-shortname, $value)
          else ()
        return
          if ( exists($prevEntry) ) then
            replace node $prevEntry with $entry
          else
            insert node $entry into $indexDoc/index
  };
  
  
  declare %updating function mgmt:index-record-by-id($id as xs:string) {
    (
      mgmt:index-record-by-id($id, $mgmt:db-public),
      mgmt:index-record-by-id($id, $mgmt:db-working)
    )
  };
  
  
  declare %updating function mgmt:index-record-by-id($id as xs:string, $db-name as xs:string) {
    let $basePath :=
      concat('/', $db-name, '/', 
              if ( $db-name eq $mgmt:db-working ) then 'records/' else ''
            )
    let $filepath := concat($basePath, $id,'/',$id,'.xml')
    (: BaseX throws an error when doc-available() fails. :)
    let $existsRecord :=
      try { doc-available($filepath) } catch * { false() }
    return
      if ( $existsRecord ) then
        let $recordNode := doc($filepath)/*
        return mgmt:index-record-node($db-name, $recordNode)
      else if ( mgmt:biblio-id-entry-exists($id, $db-name) ) then
        mgmt:delete-indexed-record($id, $db-name)
      else ()
  };
  
  
  declare %updating function mgmt:index-record-node($db-name as xs:string, $record as element()) {
    let $id := $record//@ID/data(.)
    let $idExists := mgmt:biblio-id-entry-exists($id)
    let $dbNode := mgmt:create-node-entry-for($record)
    let $index := mgmt:get-custom-index('id')
    return
      if ( not(exists($index)) ) then
        mgmt:rebuild-id-index(function($items as item()*) { () })
      else if ( $idExists and mgmt:biblio-id-entry-exists($id, $db-name) ) then
        replace node mgmt:get-index-entry('id', $id)/node[@db eq $db-name] with $dbNode
      else if ( $idExists ) then
        insert node $dbNode into mgmt:get-index-entry('id', $id)
      else
        let $entry := mgmt:create-index-entry-for($id, $dbNode)
        return
          insert node $entry into $index/index
  };
  
  
  declare %updating function mgmt:ingest-articles-from-file-system() {
    let $ingestList := mgmt:identify-ingestible-articles()
    let $basePath := mgmt:get-db-base-path($mgmt:db-articles)
    return
      for $filename in $ingestList
      let $fullPath := concat($basePath,'/',$filename)
      return
        db:replace($mgmt:db-articles, $filename, $fullPath)
  };
  
  (:~ 
    Store a copy of a public Biblio record into the Biblio working database. This 
    will replace any existing working record!
   :)
  declare %updating function mgmt:make-working-copy($id as xs:string) {
    let $publicEntry := mgmt:get-index-entry('id', $id)/node[@db eq $mgmt:db-public]
    return 
      if ( exists($publicEntry) ) then
        let $record := mgmt:get-indexed-record($publicEntry)
        return mgmt:store-working-record($record)
      else error()
  };
  
  (:~ Publish a working Biblio record to the public database, and delete the working 
    copy. :)
  declare %updating function mgmt:publish-record($record as node()) {
    mgmt:publish-record($record, ())
  };
  
  (:~ Publish a working Biblio record to the public database, and delete the working 
    copy. :)
  declare %updating function mgmt:publish-record($record as node(), $expected-id as 
     xs:string?) {
    mgmt:publish-record($record, $expected-id, false())
  };
  
  (:~ Publish a working Biblio record to the public database, and delete the working 
    copy. :)
  declare %updating function mgmt:publish-record($record as node(), $expected-id as 
     xs:string?, $return-job as xs:boolean) {
    let $id := $record//@ID/data(.)
    let $xmlPath := concat($id,"/",$id,".xml")
    let $dbPathPublic := concat($mgmt:db-public,"/",$xmlPath)
    return
    (
      (: Store the new public record. :)
      db:replace($mgmt:db-public, $xmlPath, $record),
      (: Delete the working copy and its index entry. :)
      mgmt:delete-indexed-record($id, $mgmt:db-working),
      (: If the record's identifier doesn't match the previous identifier, 
        decommission the old identifier. :)
      mgmt:decommission-identifier-if-needed($id, $expected-id, ()),
      (: Schedule a job to index the new public record. :)
      let $jobId := mgmt:schedule-indexing($id, $mgmt:db-public)
      return
        if ( $jobId and $return-job ) then 
          update:output( $jobId )
        else ()
    )
  };
  
  (:~ Create or recreate the custom `@ID` index. :)
  declare %updating function mgmt:rebuild-id-index() {
    mgmt:rebuild-id-index(())
  };
  
  (:~ Create or recreate the custom `@ID` index. :)
  declare %updating function mgmt:rebuild-id-index($post-update-function as 
     (function(item()*) as item()*)?) {
    let $opts := $mgmt:custom-indexes?('id')
    (: Get all @IDs in the Biblio databases. :)
    let $allIDs := 
      let $publicIDs := db:open($mgmt:db-public)//@ID
      let $workingIDs := db:open($mgmt:db-working,'records')//@ID
      return ( $publicIDs, $workingIDs )
    let $index := mgmt:create-custom-index($opts, $allIDs)
    let $message := "Done."
    let $updateOutput :=
      if ( exists($post-update-function) ) then
        $post-update-function(<p>{ $message }</p>)
      else $message
    return 
    (
      db:replace($mgmt:db-custom-indexes, $opts?('filename'), document {$index}),
      update:output($updateOutput)
    )
  };
  
  
  declare function mgmt:schedule-indexing($id as xs:string) as xs:string? {
    mgmt:schedule-indexing($id, ())
  };
  
  
  declare function mgmt:schedule-indexing($id as xs:string, $db-name as xs:string?) 
     as xs:string? {
    let $specificDb := 
      if ( exists($db-name) ) then 
        '", "' || $db-name
      else ''
    let $strQuery := 
      'import module namespace mgmt="http://digitalhumanities.org/dhq/ns/biblio/maintenance" '
        || 'at "database-maintenance.xql"; '
      || 'mgmt:index-record-by-id("' || $id || $specificDb || '")'
    let $jobName :=
      let $useDb := if ( $db-name ) then concat($db-name,'-') else ''
      return concat('reindex-',$useDb,$id)
    let $options := 
      map {
        'id': $jobName,
        'start': 'PT2S'
      }
    return
      try {
        jobs:eval($strQuery, (), $options)
      } catch * { () }
  };
  
  
  (:declare function mgmt:store-index-entries($index-shortname as xs:string, $entries as node()) {
    let $indexOpts := $mgmt:custom-indexes?($index-shortname)
    let $filename := $indexOpts?('filename')
    
  };:)
  
  declare (:%updating:) function mgmt:store-provenance-expressions($prov as node()*) {
    let $workingEntity := 
      $prov/self::prov:entity
              [prov:location eq 'biblio-working']
              [not(@prov:id = $prov/prov:wasInvalidatedBy/prov:entity/@prov:ref)]
    let $isWorkingSpecific := function($id) {
        if ( $workingEntity ) then
          $id = $workingEntity/@prov:id/data(.)
        else true()
      }
    let $statements :=
      for $expr in $prov
      group by $specific := 
        if ( $isWorkingSpecific($expr/@prov:id) 
              or exists($expr/descendant::*[$isWorkingSpecific(@prov:ref)])
           ) then
          'biblio-working'
        else 'biblio-public'
      return
        map:entry(xs:string($specific), $expr)
    let $statements := map:merge($statements)
    return $statements
  };
  
  (:~
    Add a Biblio record to the working database.
   :)
  declare %updating function mgmt:store-working-record($record as node()) {
    mgmt:store-working-record($record, ())
  };
  
  (:~
    Add a Biblio record to the working database.
   :)
  declare %updating function mgmt:store-working-record($record as node(), 
     $expected-id as xs:string?) {
    mgmt:store-working-record($record, $expected-id, false())
  };
  
  (:~
    Add a Biblio record to the working database.
   :)
  declare %updating function mgmt:store-working-record($record as node(), 
     $expected-id as xs:string?, $return-job as xs:boolean) {
    (: Construct a path to the record in the working database: 
      /biblio-working/records/$id/$id.xml . :)
    let $id := $record//@ID/data(.)
    let $xmlPath := concat("records/",$id,"/",$id,".xml")
    let $dbPath := concat($mgmt:db-working,"/",$xmlPath)
    (: Index record ID. :)
    return (
      db:replace($mgmt:db-working, $xmlPath, $record)
      ,
      mgmt:decommission-identifier-if-needed($id, $expected-id, $mgmt:db-working)
      (: If there's a record with an outdated ID, delete it from the working 
        database and trigger reindexing on the old ID. :)
      (:if ( $supercedesExpectedId ) then
        let $oldRecord := concat("records/",$expected-id,"/",$expected-id,".xml")
        return
          if ( db:exists($mgmt:db-working, $oldRecord) ) then
            ( db:delete($mgmt:db-working, $oldRecord), 
              let $jobId := mgmt:schedule-indexing($expected-id)
              return
                if ( $jobId and $return-job ) then 
                  update:output( $jobId ) else ()
            )
          else ()
      else ():)
      ,
      let $jobId := mgmt:schedule-indexing($id, $mgmt:db-working)
      return
        if ( $jobId and $return-job ) then update:output( $jobId ) else ()
    )
  };
  
  declare %updating function mgmt:update-db-from-file-system($db-name as xs:string, 
     $is-dry-run as xs:boolean) {
    mgmt:update-db-from-file-system($db-name, $is-dry-run, ())
  };
  
  declare %updating function mgmt:update-db-from-file-system($db-name as xs:string, 
     $is-dry-run as xs:boolean, $post-update-function as (function(item()*) as item()*)?) {
    let $basePath := mgmt:get-db-base-path($db-name)
    let $outdatedFiles := mgmt:identify-outdated-files-in-db($db-name)
    let $lastModifiedDate := $outdatedFiles[1]/@modified-date/data(.)
    let $makeLog := function($action as xs:string, $filename as xs:string) {
        <p>{ concat($action, ' ', $filename) } of database {$db-name}.</p>
      }
    let $mappedUpdatables :=
      (: For each updatable document, obtain its modification timestamps for both 
        the version indexed by the database, and the original version stored in the 
        file system. :)
      for $file in $outdatedFiles
      let $filename := $file/text()
      return
        map {
            'filename': $filename,
            'message': $makeLog('Updated', $filename)
          }
      (: TBD: if a file was added to the file system, add it to the database :)
      (: TBD: if the file no longer exists, delete it :)
    (: Retrieve all of the HTML log messages, and (if there is one) apply the 
      $post-update-function. :)
    let $allMessages :=
      let $html := for $map in $mappedUpdatables return $map?message
      return
        if ( exists($post-update-function) ) then
          $post-update-function($html)
        else $html
    return
    (
      update:output($allMessages),
      (: If this is a dry run, do nothing. Otherwise, apply XQuery Updates for each 
        anticipated file. :)
      if ( $is-dry-run ) then ()
      else
        for $map in $mappedUpdatables
        let $filename := $map?filename
        let $fileSysPath := concat($basePath, $filename)
        return
          db:replace($db-name, $filename, $fileSysPath)
    )
  };



(:  SUPPORT FUNCTIONS  :)
  
  (:~ Given a sequence of nodes from Biblio records, create a full custom index. :)
  (:declare %private function mgmt:create-biblio-id-index($fields as item()*) {
    mgmt:create-custom-index($fields, mgmt:create-biblio-id-entry-for(?))
  };:)
  
  (:~
    Given a node from a Biblio record, create an index entry using the record's 
    Biblio identifier.
   :)
  declare %private function mgmt:create-biblio-id-entry-for($node as node()) {
    let $useNode := $node/root()/*[@ID]/@ID
    return
      <id>{ $useNode/data(.) }</id>
  };
  
  (:~
    Create a custom index in XML.
   :)
  declare function mgmt:create-custom-index($indexOpts as map(*), $instances as item()*) {
    let $createEntryFor := $indexOpts?('generate-entry')
    let $entries :=
      for $instance in $instances
      group by $value := $instance/xs:string(.)
      let $instanceEntries :=
        for $match in $instance
        return
          if ( exists($createEntryFor) ) then $createEntryFor($match)
          else ()
      return mgmt:create-index-entry-for($value, $instanceEntries)
    return
      <index>{ $entries }</index>
  };
  
  (:~
    Given a node from a Biblio record, create an index entry using the BaseX node 
    identifier.
   :)
  declare %private function mgmt:create-node-entry-for($node as node()) {
    let $db-name := db:name($node)
    let $useNode := $node/ancestor-or-self::*[@ID]
    return
      <node db="{$db-name}">{ db:node-id($useNode) }</node>
  };
  
  (:~
    Determine whether a current identifier is different than the previous identifier. 
    If so, decommission the old one by deleting its record and index entry.
   :)
  declare %private %updating function mgmt:decommission-identifier-if-needed($id as xs:string, 
     $previous-id as xs:string?, $db-name as xs:string?) {
    (: Check if the record is intended to overwrite one with an outdated ID. :)
    if ( exists($previous-id) and $previous-id ne '' and $previous-id ne $id ) then
      let $indexedNodes := 
        let $indexEntry := mgmt:get-index-entry('id', $previous-id)
        return
          $indexEntry/node[ if ( exists($db-name) ) then 
                              @db eq $db-name
                            else true() ]
      return
        for $db in $indexedNodes/@db/data(.)
        return mgmt:delete-indexed-record($previous-id, $db)
    else ()
  };
  
  (:~ 
    Delete an indexed record node for a particular database.
   :)
  declare %private %updating function mgmt:delete-indexed-record($id as xs:string, 
     $db-name as xs:string) {
    let $existsEntry := mgmt:biblio-id-entry-exists($id, $db-name)
    let $existsNode := exists(mgmt:get-biblio-record($id, $db-name))
    let $recordDirPath := 
      if ( $db-name eq $mgmt:db-working ) then 'records/'||$id
      else $id
    return
      if ( not(exists(mgmt:get-custom-index('id'))) ) then
        mgmt:rebuild-id-index(function($items as item()*) { () })
      else (
        (: Try to delete the record. :)
        if ( $existsNode ) then
          db:delete($db-name, $recordDirPath)
        else (),
        (: Try to delete the database-specific node entry, deleting the entire index 
          entry if that was the only node entry for the string. :)
        if ( $existsEntry ) then
          let $idEntry := mgmt:get-index-entry('id', $id)
          return
            if ( count($idEntry/*) eq 1 ) then
              delete node $idEntry
            else
              delete node $idEntry/node[@db eq $db-name]
        else ()
      )
  };
