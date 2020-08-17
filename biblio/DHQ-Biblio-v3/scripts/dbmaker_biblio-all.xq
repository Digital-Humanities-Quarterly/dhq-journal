xquery version "3.1";

(:  NAMESPACES  :)
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
(:  OPTIONS  :)
  declare option output:indent "yes";

(:~
  An XQuery to create a BaseX command script which, in turn, can be used to create 
  the 'biblio-public' and 'biblio-working' databases.
  
  To run this script with the BaseX Client, change to the BaseX directory in your
  terminal and run:
     basexclient -b"dhq-svn-dir-path=/PATH/TO/dhq" -b"biblio-dir-path=/PATH/TO/data/" \
                  -o"biblio-setup.bxs" "/PATH/TO/scripts/dbmaker_biblio-all.xq"
  
  To run the command script, you can then use:
     basexclient biblio-setup.bxs
  
  @author Ashley M. Clark
  2018-10-02
 :)

(:  VARIABLES  :)

  (: REQUIRED. An absolute file path to the directory where DHQ lives. :)
  declare variable $dhq-svn-dir-path external;
  
  (: OPTIONAL. The name of the database which will hold the Subversion <BiblioSet> 
    serializations for ingestion into the 'biblio-public' database. :)
  declare variable $svnbiblio-db-name external := 'biblio-all';
  
  (: OPTIONAL. An absolute file path to the directory containing DHQ articles. :)
  declare variable $article-dir-path external := $dhq-svn-dir-path || "/articles";
  (: A map of the BaseX options specific to the DHQ article database. :)
  declare variable $article-index-opts := map {
    'attrinclude':  "*:id,*:key,*:ref,*:target,*:when",
    'ftinclude':    "Q{http://www.tei-c.org/ns/1.0}author,"
                  || "Q{http://www.tei-c.org/ns/1.0}bibl,"
                  || "Q{http://www.tei-c.org/ns/1.0}title",
    'textinclude':  "Q{http://www.tei-c.org/ns/1.0}idno",
    'tokeninclude':  "*:id,*:key,*:ref,*:target,*:when"
  };
  
  (: OPTIONAL. An absolute file path to the directory containing Biblio data. :)
  declare variable $biblio-dir-path external := $dhq-svn-dir-path || "/biblio/DHQ-Biblio-v3/data";
  (: A map of the BaseX options specific to the Biblio databases. :)
  declare variable $biblio-index-opts := map {
    'attrinclude':  "*:id,*:ID,*:dhqID,*:issuance,*:provenance",
    'ftinclude':    "Q{http://digitalhumanities.org/dhq/ns/biblio}title,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}author,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}editor,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}translator,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}creator,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}note",
    'ftindex':      true(),
    'textinclude':  "Q{http://digitalhumanities.org/dhq/ns/biblio}familyName,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}formalID,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}title,"
                  || "Q{http://digitalhumanities.org/dhq/ns/biblio}url",
    'tokeninclude': "*:id,*:ID,*:dhqID,*:issuance,*:provenance"
  };
  (: A map of the BaseX options specific to the Biblio custom indices. :)
  declare variable $custom-index-opts := map {
    'attrinclude':  "*:db,*:string",
    'ftinclude':    '',
    'ftindex':      false(),
    'textinclude':  "id",
    'tokeninclude': '',
    'tokenindex':   false()
    
  };
  (: A map of the BaseX options which should be set before any databases are 
    created. See http://docs.basex.org/wiki/Options for more. :)
  declare variable $option-map := map {
    'autooptimize': true(),
    'attrindex':    true(),
    'chop':         false(),
    'skipcorrupt':  true(),
    'textindex':    true(),
    'tokenindex':   true(),
    'updindex':     true()
  };


(:  FUNCTIONS  :)
  
  (: Create a sequence of BaseX "SET" commands for options in a given map. :)
  declare function local:set-options($options) as node()* {
    for $optKey in map:keys($options)
    return
      <set option="{$optKey}">{ $options($optKey) }</set>
  };


(:  MAIN QUERY  :)

<commands>
  <!-- Set general options. -->
  { local:set-options($option-map) }
  
  
  <!-- Set DHQ article-specific options. -->
  { local:set-options($article-index-opts) }
  
  <!-- Create the dhq-articles database and remove non-article resources. -->
  <create-db name="dhq-articles">{ $article-dir-path }</create-db>
  <open name="dhq-articles"/>
  <!-- Delete data when the path does not match that of a DHQ article (templates, 
    test data, etc.). -->
  <xquery><![CDATA[
    xquery version "3.0";
    declare namespace db="http://basex.org/modules/db";
    
    declare function local:fits-article-convention($path as xs:string) as xs:boolean {
      matches($path,'[0-8]\d{5,5}(\.xml)?$')
    };
    
    let $deletables := 
      for $path in db:dir('dhq-articles', '')
      let $pathStr := xs:string($path/text())
      let $isAcceptable := local:fits-article-convention($pathStr)
      return
        (: If the directory path matches the convention for article IDs, check the 
          directory's contents for resources that do not match the conventions. :)
        if ( $isAcceptable ) then
          db:dir('dhq-articles', $pathStr)
            [not(local:fits-article-convention(text()))]
            /concat($pathStr,'/',text())
        (: Return the paths of any resources that should be deleted. :)
        else
          $pathStr
    return
      for $path in $deletables
      return db:delete('dhq-articles', $path)
  ]]></xquery>
  <create-index type="fulltext"/>
  <optimize/>
  <close/>
  
  
  <!-- Set Biblio-specific options. -->
  { local:set-options($biblio-index-opts) }
  
  <!-- Create the SVN-serialized Biblio database and do some maintenance on it. -->
  <create-db name="{$svnbiblio-db-name}">{ $biblio-dir-path }</create-db>
  <open name="{$svnbiblio-db-name}"/>
  <delete path="Biblio-dupes.xml"/>
  <delete path="Biblio-problemGenres.xml"/>
  <close/>
  
  <!-- If it doesn't already exist, create the biblio-public database using the 
    entries from the SVN Biblio database. -->
  <check input="biblio-public"/>
  <open name="{$svnbiblio-db-name}"/>
  <xquery><![CDATA[
    xquery version "3.0";
    declare namespace db="http://basex.org/modules/db";
    declare default element namespace "http://digitalhumanities.org/dhq/ns/biblio";
    declare copy-namespaces preserve, inherit;
    
    for $bibItem in /BiblioSet/*
    let $bibID := $bibItem/@ID/data(.)
    let $dbPath := $bibID || '/' || $bibID || '.xml'
    let $nsItem := 
      copy $modItem := $bibItem 
      modify insert node namespace {''} { 'http://digitalhumanities.org/dhq/ns/biblio' } as first into $modItem 
      return $modItem
    
    return 
      if ( exists($bibItem[self::BiblioSet]) 
        or not(exists($bibItem/@ID))
        or db:exists('biblio-public', $dbPath) ) then ()
      else
        db:replace('biblio-public', $dbPath, $nsItem)
  ]]></xquery>
  <open name="biblio-public"/>
  <create-index type="fulltext"/>
  <optimize/>
  <close/>
  
  <!-- Create the biblio-working database if it doesn't already exist. -->
  <check input="biblio-working"/>
  <create-index type="fulltext"/>
  <optimize/>
  <close/>
  
  
  <!-- Set options specific to the Biblio ID index. -->
  { local:set-options($custom-index-opts) }
  
  <!-- Create the custom Biblio @ID index if it doesn't already exist. -->
  <check input="biblio-custom-index"/>
  <!-- (Re)index the identifiers in the Biblio databases. -->
  <xquery><![CDATA[
    xquery version "3.0";
    declare namespace db="http://basex.org/modules/db";
    
    let $publicIDs := db:open('biblio-public')//@ID
    let $workingIDs := 
      db:open('biblio-working','records')//@ID
    let $allIDs := ( $publicIDs, $workingIDs )
    let $index := <index>{
      for $ids in $allIDs
      group by $id := $ids/data(.)
      return <text string="{$id}">{
        for $match in $ids
          let $db := db:name($match)
          return
            <node db="{$db}">{ db:node-id($match/parent::*) }</node>
      }</text>
    }</index>
    return
      db:replace('biblio-custom-index', 'biblio-id-index.xml', $index)
  ]]></xquery>
</commands>
