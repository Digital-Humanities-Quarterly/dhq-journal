xquery version "3.1";

module namespace dbfx="http://digitalhumanities.org/dhq/ns/biblio/lib";
(:  LIBRARIES  :)
  import module namespace db="http://basex.org/modules/db";
  import module namespace update="http://basex.org/modules/update";
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace file="http://expath.org/ns/file";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace rerr="http://exquery.org/ns/restxq/error";
  declare namespace rest="http://exquery.org/ns/restxq";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace xhtml="http://www.w3.org/1999/xhtml";
  declare namespace xslt="http://basex.org/modules/xslt";

(:~
  A library of functions useful for interacting with the DHQ Biblio databases.
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  Created 2018
 :)


(:  VARIABLES  :)
  declare variable $dbfx:db-public    := 'biblio-public';
  declare variable $dbfx:db-working   := 'biblio-working';
  declare variable $dbfx:db-articles  := 'dhq-articles';
  
  declare variable $dbfx:assets-before-custom := (
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"/>,
    <script type="text/javascript">
      <![CDATA[/* Set up namespace for DHQ functions */
      var bibjs = bibjs || ]]>{ "{}" }<![CDATA[;
      bibjs.baseUrl = ']]>{ dbfx:make-web-url('/dhq/') }<![CDATA[';]]>
    </script>,
    <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/a11y-common.js')}"/>,
    <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/a11y-navbar-menu.js')}"/>
  );
  declare variable $dbfx:assets-after-custom := (
    <link rel="stylesheet" type="text/css" href="{dbfx:make-web-url('/dhq/assets/bootstrap-reboot.min.css')}" />,
    <link rel="stylesheet" type="text/css" href="{dbfx:make-web-url('/dhq/assets/biblio.css')}" />
  );
  declare variable $dbfx:biblio-ns := 'http://digitalhumanities.org/dhq/ns/biblio';
  declare %private variable $dbfx:servlet := file:exists(db:option('webpath')||'servlet.xml');
  declare variable $dbfx:template := doc('../templates/template.xhtml');


(:  FUNCTIONS, GENERAL  :)

  (:~ Given a sequence of query results, return a map of regularized unique strings, 
    each with the number of matching results. If the input sequence consists 
    entirely of nodes, an array of matching nodes is also provided for each unique 
    string.
    
    Regularization is applied by lowercasing the string and removing all characters 
    that aren't letters or numbers. These regularized strings are meant to be used 
    for uniqueness testing and/or sorting, not for display.
   :)
  declare function dbfx:count-instances($sequence as item()*) {
    dbfx:count-instances($sequence, ())
  };
  
  
  (:~ Given a sequence of query results, return a map of regularized unique strings, 
    each with the number of matching results. If the input sequence consists 
    entirely of nodes, an array of matching nodes is also provided for each unique 
    string.
    
    To obtain the unique strings, `distinct-values()` is run first on the 
    unregularized results. Then, a regularized version is created for each of those 
    unique strings, and `distinct-values()` is run again on the regularized 
    versions.
    
    Regularization can be done in one of two ways. The default is to lowercase the 
    string and remove all characters that aren't letters or numbers. Alternatively, 
    you can provide an inline function that performs regularization. These 
    regularized strings are meant to be used for uniqueness testing and/or sorting, 
    not for display.
   :)
  declare function dbfx:count-instances($sequence as item()*, 
                                        $sortable-item-function as (function(item()*) as item()*)?) {
    (: Test if every item in the sequence is a node. :)
    let $instancesAreNodes := 
      every $item in $sequence 
      satisfies $item instance of node()
    (: Do a first pass on uniquing the sequence, using the original, unregularized 
      inputs. Each unique value is made into a map which contains both regularized
      and unregularized values, as well as matching nodes from the input sequence 
      (if $instancesAreNodes returns true). :)
    let $instanceMaps :=
      for $distinctAsIs in distinct-values($sequence)
      let $nodes := ()
      let $sortable :=
        (: If a regularization function has been provided, use it on the current 
          value. :)
        if ( exists($sortable-item-function) ) then
          $sortable-item-function($distinctAsIs)
        (: If there's no regularization function, lowercase the string and remove 
          all non-word characters. ("Word" is used here in the regular expression 
          character group sense). :)
        else
          replace(lower-case($distinctAsIs),'\W','')
      return
        map:merge((
          map:entry('orig', $distinctAsIs),
          map:entry('reg', $sortable),
          (: If $instancesAreNodes, add a map entry containing an array of nodes 
            matching the current value. :)
          (: TBD: Always count the number of results, even if the input sequence doesn't contain nodes. :)
          if ( $instancesAreNodes ) then
            let $matches := $sequence[. eq $distinctAsIs]
            let $primaryEntries := [ ($matches[dbfx:test-primacy(.) eq 1])  ]
            let $withSecondary := array:append($primaryEntries, ($matches[dbfx:test-primacy(.) eq 2]))
            return map:entry('nodes', $withSecondary)
          else ()
        ))
    (: Create a new map, condensing entries so that each distinct regularized value 
      has only one map describing its results. :)
    let $distinctMap :=
      map:merge((
        for $sortableInstance in distinct-values($instanceMaps?reg)
        let $relatedMaps := $instanceMaps[?reg eq $sortableInstance]
        let $nodes := $relatedMaps?nodes
        (: Merge any arrays of node matches. :)
        let $combinedNodes := map:entry('nodes', [ ($nodes?(1)), ($nodes?(2)) ])
        (: Add up the number of results matching the current value. :)
        let $countNodes := 
          let $entryNodes := $combinedNodes?nodes
          let $combinedCount := count($entryNodes?1) + count($entryNodes?2)
          return map:entry('count', $combinedCount)
        let $newMap := map:merge( ($relatedMaps, 
          if ( $instancesAreNodes ) then ($combinedNodes, $countNodes)
          else () 
        ))
        return
          map:entry($sortableInstance, $newMap)
      ))
    return
      $distinctMap
  };
  
  
  declare function dbfx:counts-to-table($sequence as item()*) as node()? {
    dbfx:counts-to-table($sequence, ())
  };
  
  
  declare function dbfx:counts-to-table($sequence as item()*, 
                                        $sortable-item-function as (function(item()*) as item()*)?) as node()? {
    let $countsMap := dbfx:count-instances($sequence, $sortable-item-function)
    return
      <table>
        <thead>
          <th>Count</th>
          <th/>
          <th>Primary Records</th>
          <th>Secondary Records</th>
        </thead>
        <tbody>
          {
            for $distinctKey in map:keys($countsMap)
            let $row := map:get($countsMap, $distinctKey)
            let $count := $row?count
            let $displayStr := $row?orig
            order by $row?reg
            return
              <tr>
                <td>{ count($row?nodes?1) + count($row?nodes?2) }</td>
                <td>{
                    if ( map:contains($row, 'reg') ) then
                      attribute data-regularized { $row?reg }
                    else ()
                  }
                  { $displayStr }
                </td>
                <td>{ dbfx:make-record-links($row?nodes?1) }</td>
                <td>{ dbfx:make-record-links($row?nodes?2) }</td>
              </tr>
          }
        </tbody>
      </table>
  };
  
  
  declare function dbfx:get-sortable-title($title as item()) as xs:string {
    dbfx:get-sortable-title($title,'none-specified')
  };
  
  
  declare function dbfx:get-sortable-title($title as item(), $lang as xs:string) as xs:string {
    let $rmChars := '–—"“”()[]:;.,…_¿?¡!  /'
    let $stopwords := "^(\p{P}*(a|an|das|de|del|der|el|il|la|le|les|lo|the) |l['’] ?|[\p{P}&gt;&lt;]+ ?)"
    let $lowercased := lower-case(translate(normalize-space($title), $rmChars, '  '))
    let $unicodified := (:$lowercased :)normalize-unicode($lowercased, 'NFKD')
    let $cutInitial := replace($unicodified, $stopwords, '')
    let $cutLangSpecific :=
      if ( ( $title instance of element() and $title[@xml:lang]/starts-with(@xml:lang, 'de') ) 
          or starts-with($lang, 'de') ) then
        replace($cutInitial, '^(die) ', '')
      else $cutInitial
    return 
      translate($cutLangSpecific, "'’", '')
  };
  
  (:~ BaseX has a habit of deleting whitespace-only text nodes on serialization. Use 
    this function to insert (explicitly!) a whitespace-only text node. :)
  declare function dbfx:insert-whitespace() as text() {
    text { " " }
  };
  
  
  declare function dbfx:make-record-links($nodes as node()*) as node() {
    <span class="record-list">
      {
        for $node in $nodes
        let $id := dbfx:get-record-id($node)
        return
          ( <a href="{dbfx:make-web-url('/dhq/biblio/api/'||$id)}" target="_blank">{ $id }</a>, text { ' ' } ) 
      }
    </span>
  };
  
  
  declare function dbfx:make-web-url($relative-path as xs:string) {
    if ( $dbfx:servlet ) then
      concat('/basex', $relative-path)
    else $relative-path
  };
  
  
  declare function dbfx:make-xhtml($fragment as node()*, $header as node()?) {
    dbfx:make-xhtml($fragment, $header, (), ())
  };
  
  
  declare function dbfx:make-xhtml($fragment as node()*, $header as node()?, $title-part as xs:string?) {
    dbfx:make-xhtml($fragment, $header, $title-part, ())
  };
  
  
  declare function dbfx:make-xhtml($fragment as node()*, $header as node()?, $title-part as xs:string?, $asset-decls as node()*) {
    copy $html := $dbfx:template
    modify (
      (: Add an optional subtitle to the HTML title. :)
      if ( exists($title-part) ) then 
        let $titleBase := $html//xhtml:title
        return
          replace value of node $titleBase with concat($title-part, ' | ', $titleBase)
      else (),
      (: Add any nodes representing CSS/JS assets to the HTML <head>. :)
      let $allAssets := ($dbfx:assets-before-custom, $asset-decls, $dbfx:assets-after-custom)
      return insert nodes $allAssets as last into $html//xhtml:head,
      (: Replace the template header with the provided node. :)
      replace node $html//xhtml:header with $header,
      (: Finally, insert content into the body of the web page. :)
      insert nodes ($fragment) into $html//xhtml:div[@class eq 'main']
    )
    return $html
  };
  
  
  (:~ :)
  declare function dbfx:tokenize-keywords($keywords as xs:string*) {
    for $string in $keywords
    let $normalized := dbfx:clean-search-term($string)
    let $phraseRegex := '("[^"]+"' || '|' || "'[^']+')"
    let $containsPhrase := matches($normalized, $phraseRegex)
    return
      (: If there are no quote marks indicating a phrase, each word is a token. :)
      if ( not($containsPhrase) ) then
        tokenize($normalized, '\s')
      (: If the entire string is surrounded by quotes, it is treated as a phrase. :)
      else if ( matches($normalized, '^'||$phraseRegex||'$') ) then
        $normalized
      (: If the string contains both phrases and individual word tokens, remove the 
        first phrase, and recurse on what's left of the string. :)
      else
        let $spaceSeparated := tokenize($normalized, '\s')
        let $firstPhrase :=
          let $startQ := 
            index-of($spaceSeparated, $spaceSeparated[matches(., '^["'||"']")][1])
          let $endQ := 
            index-of($spaceSeparated, $spaceSeparated[matches(., '["'||"']$")][1])
          let $seqQ := subsequence($spaceSeparated, $startQ, $endQ)
          let $wholeQ := string-join($seqQ, ' ')
          return
            $wholeQ
        return
          (
            $firstPhrase,
            dbfx:tokenize-keywords(replace($normalized, $firstPhrase, ''))
          )
  };

  (:~ Normalize space and remove punctuation. :)
  declare function dbfx:clean-search-term($keyword as xs:string) {
    let $minSpaced := normalize-space($keyword)
    return
      replace($minSpaced, '[,;:]', '')
  };


(:  FUNCTIONS, BIBLIO  :)

  declare function dbfx:bibliographic-records() as node()* {
    db:open($dbfx:db-public)/*
  };
  
  (:~ Given a superset of Biblio records, return those which match requested search criteria. :)
  declare function dbfx:get-biblio-results($records as node()*, $sort as xs:string, 
      $keywords as xs:string*, $titles as xs:string*, $contributors as xs:string*) as item()* {
    let $hasSearchParams := count(($keywords, $titles, $contributors)) gt 0
    (: Retrieve the requested subset of Biblio entries. :)
    let $matchedRecords :=
      if ( not($hasSearchParams) ) then $records
      else if ( count($titles) gt 1 or $titles ne '' ) then (: TODO: combine match parameters! :)
        let $titlesTokenized := dbfx:tokenize-keywords($titles)
        return
          dbfx:search-records($records, $titlesTokenized, ('title', 'additionalTitle'))
      else if ( count($keywords) gt 1 or $keywords ne '' ) then 
        let $keywordsTokenized := dbfx:tokenize-keywords($keywords)
        return
          dbfx:search-records($records, $keywordsTokenized)
      else if ( count($contributors) gt 1 or $contributors ne '' ) then
        let $contributorsTokenized := dbfx:tokenize-keywords($contributors)
        let $giSeq := ('author', 'editor', 'translator', 'creator')
        return
          dbfx:search-records($records, $contributorsTokenized, $giSeq)
      (: TODO: formalID :)
      else ()
    (: Sort and return the results. :)
    return
      sort($matchedRecords, (), function($item) {
        let $lang := $item/@xml:lang/data(.)
        let $ident := lower-case($item/@ID/data(.))
        let $firstSort :=
          switch ($sort)
            case 'date'   return ($item//dbib:date)[1]/normalize-space(.)
            case 'format' return $item/local-name()
            case 'score'  return ()
            case 'title'  return 
              if ( $lang ) then 
                dbfx:get-sortable-title($item/dbib:title[1], $lang)
              else
                dbfx:get-sortable-title($item/dbib:title[1])
            default return $ident
        let $secondSort :=
          if ( $sort = ('identifier', 'score') ) then ()
          else $ident
        return
          ( $firstSort, $secondSort )
        })
  };
  
  
  declare function dbfx:get-cited-record($bibl as element(tei:bibl)) {
    let $idref := dbfx:get-citation-key($bibl)
    return dbfx:get-record($idref)
  };
  
  
  declare function dbfx:get-fields-by-element($gi as xs:NCName) as node()* {
    let $qname := QName($dbfx:biblio-ns, $gi)
    return
      db:open($dbfx:db-public)//*[node-name(.) = $qname]
  };
  
  
  declare function dbfx:get-record($id as xs:string) as node()* {
    let $getDocFrom := function($dbName as xs:string) {
        let $path := concat('/',$id,'/',$id,'.xml')
        return db:open($dbName, $path)
      }
    let $publicDoc := $getDocFrom($dbfx:db-public)
    (:let $workingDoc := $getDocFrom($dbfx:db-working):)
    return
      if ( exists($publicDoc) ) then
        $publicDoc
      else ()
  };
  
  
  declare function dbfx:get-record-id($node as node()) as xs:string? {
    $node/ancestor-or-self::*[@ID]/@ID/data(.)
  };
  
  
  declare function dbfx:make-biblio-ref($record as node()) as node() {
    xslt:transform($record, doc("../transforms/citation-biblioref.xsl"))
  };
  
  
  declare function dbfx:make-citation($record as node()) as node() {
    xslt:transform($record, doc("../transforms/citation-html.xsl"))
  };
  
  
  declare function dbfx:search-records($records as node()*, $tokens as xs:string*) {
    let $matches := 
      $records
        [ . contains text { $tokens } all using case insensitive ]
    return
      for $matchedEntry score $score in $matches
      order by $score descending
      return $matchedEntry
  };
  
  
  declare function dbfx:search-records($records as node()*, $tokens as xs:string*, $fields as xs:string+) {
    let $qnameList :=
      for $field in $fields
      return
        QName('http://digitalhumanities.org/dhq/ns/biblio', $field)
    let $matchFields := function($record) {
        $record//*[node-name(.) = $qnameList]
      }
    let $matches :=
      $records
        [ $matchFields(.) contains text { $tokens } all using case insensitive ]
    return
      for $matchedEntry score $score in $matches
      order by $score descending
      return $matchedEntry
  };
  
  
  declare function dbfx:test-primacy($node as node()) {
    let $secondClassQNames :=
      (:for $localName in:) ('book', 'conference', 'journal', 'publication', 'series')
      (:return QName($dbfx:biblio-ns, $localName):)
    return
      if ( $node/ancestor::*[local-name(.) = $secondClassQNames] ) then
        2
      else 1
  };



(:  FUNCTIONS, ARTICLES  :)

  declare function dbfx:article-map($article) as map(xs:string, item()*) {
    map {
      (:'article' : $article,:)
      'id' : function() {
          $article//tei:publicationStmt/tei:idno[@type eq 'DHQarticle-id']/normalize-space(.)
        },
      'path' : $article/base-uri() cast as xs:string,
      'title' : function() as xs:string {
          $article//tei:titleStmt/tei:title[1]/normalize-space(.)
        },
      'authors' : function() as array(xs:string*) {
          array { $article//dhq:author_name/dhq:family/normalize-space(.) }
        },
      'bibls' : function() as map(xs:string, item()*) {
          let $allBibls := $article//tei:text//tei:bibl[parent::tei:listBibl]
          let $total := map:entry('total', count($allBibls))
          let $keyStatusGroups :=
            for $bibl in $allBibls
            group by $isKeyed := dbfx:has-valid-key($bibl)
            let $mapKey := if ( $isKeyed ) then 'keyed' else 'nokey'
            return
              map:entry($mapKey,
                        for $match in $bibl return $match)
          return
            map:merge( ($total, $keyStatusGroups) )
        }
    }
  };
  
  
  declare function dbfx:article-set() as map(xs:string, item()*)* {
    for $article in db:open($dbfx:db-articles)
    return dbfx:article-map($article)
  };
  
  
  declare function dbfx:extract-biblio-entries-from-tei($bibliography as node()) as node() {
    xslt:transform($bibliography, doc("../transforms/extract-biblio-from-tei.xsl"))
  };
  
  
  declare function dbfx:make-article-bibliography($bibliography as node()) as node() {
    xslt:transform($bibliography, doc("../transforms/article-bibliography-to-html.xsl"))
  };
  
  
  declare function dbfx:get-article-url($article as node()) {
    let $articlePubStmt := $article//tei:publicationStmt
    let $volume := $articlePubStmt/tei:idno[@type eq 'volume']/normalize-space(.)
    let $issue := $articlePubStmt/tei:idno[@type eq 'issue']/normalize-space(.)
    let $id := $articlePubStmt/tei:idno[@type eq 'DHQarticle-id']/normalize-space(.)
    let $isPublished := exists($articlePubStmt/tei:date[exists(@when) or exists(text())])
    return
      if ( $isPublished ) then
        concat("http://www.digitalhumanities.org/dhq/vol/",$volume,"/",$issue,"/",$id,"/",$id,".html")
      else ''
  };
  
  
  declare function dbfx:get-citation-key($bibl as element(tei:bibl)) as item()? {
    $bibl/@key/data(.)
  };
  
  
  declare function dbfx:has-valid-key($bibl as element(tei:bibl)) as xs:boolean {
    let $keyAttr := dbfx:get-citation-key($bibl)
    return
      exists($keyAttr) and 
      (
        $keyAttr eq '[unlisted]' or
        exists(dbfx:get-record($keyAttr))
      )
  };
