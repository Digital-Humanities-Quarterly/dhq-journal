xquery version "3.0";

  module namespace dbqx="http://digitalhumanities.org/dhq/ns/biblio-qa/rest";
(:  LIBRARIES  :)
  import module namespace dbfx="http://digitalhumanities.org/dhq/ns/biblio/lib" at "lib/biblio-functions.xql";
  import module namespace dbrx="http://digitalhumanities.org/dhq/ns/biblio/rest" at "biblio-public.xq";
  import module namespace lev="http://digitalhumanities.org/dhq/ns/levenshtein" 
    at "lib/levenshtein-distance.xql";
  import module namespace mgmt="http://digitalhumanities.org/dhq/ns/biblio/maintenance"
    at "lib/database-maintenance.xql";
  import module namespace mrng="http://digitalhumanities.org/dhq/ns/meta-relaxng"
    at "lib/relaxng.xql";
  import module namespace provxq="http://digitalhumanities.org/dhq/ns/prov" at "lib/prov.xql";
  import module namespace request = "http://exquery.org/ns/request";
  import module namespace session = "http://basex.org/modules/session";
  import module namespace wpi="http://www.wwp.northeastern.edu/ns/api/functions" at "lib/api.xql";
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace bprov="http://digitalhumanities.org/dhq/biblio-qa/prov/";
  declare namespace db="http://basex.org/modules/db";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace jobs="http://basex.org/modules/jobs";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace perm="http://basex.org/modules/perm";
  declare namespace prov="http://www.w3.org/ns/prov#";
  declare namespace rest="http://exquery.org/ns/restxq";
  declare namespace rerr="http://exquery.org/ns/restxq/error";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace update="http://basex.org/modules/update";
  declare namespace user="http://basex.org/modules/user";
  declare namespace validate="http://basex.org/modules/validate";
  declare namespace web="http://basex.org/modules/web";
  declare namespace xhtml="http://www.w3.org/1999/xhtml";
  declare namespace xslt="http://basex.org/modules/xslt";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:~
 : RESTXQ functions for creating and maintaining Biblio entries.
 :
 : @author Ashley M. Clark, for Digital Humanities Quarterly
 : Created 2018
 :)


(:  VARIABLES  :)
  declare variable $dbqx:workbench-available := true(); (:doc-available('dev.xml');:)
  declare variable $dbqx:additional-assets := map {
      'acejs': (
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.3.3/ace.js"></script>,
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.3.3/mode-xml.js"></script>,
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.3.3/theme-tomorrow.js"></script>
      ),
      'd3js':
        <script type="text/javascript" src="https://d3js.org/d3.v5.min.js"></script>,
      'd3sets':
        <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/data-driven-sets.js')}"></script>,
      'jquery': 
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>,
      'keywords': 
        <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/asynchronous-keywords.js')}"></script>,
      'modal':
        <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/a11y-modal.js')}"></script>,
      'xonomy': (
        <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/xonomy-3.5.0/xonomy.js')}"></script>,
        <script type="text/javascript" src="{dbfx:make-web-url('/dhq/assets/xonomy-biblio.js')}"></script>,
        <link type="text/css" rel="stylesheet" href="{dbfx:make-web-url('/dhq/assets/xonomy-3.5.0/xonomy.css')}"></link>
      )
    };
  declare variable $dbqx:header :=
    <header>
      <div class="biblio-qa-header">
        <h1>
          <a href="{dbfx:make-web-url('/dhq/biblio-qa')}">DHQ Biblio Workbench</a></h1>
        {
          if ( session:get('id') ) then
            <div>
              <span class="greeting">Hello, { session:get('id') }!</span>
              <form action="{dbfx:make-web-url('/dhq/biblio-qa/logout')}" method="POST" class="logout">
                <button type="submit">Log out</button>
              </form>
            </div>
          else ()
        }
      </div>
      <nav>
        <ul class="nav-menu">
          <li class="nav-item">
            <button id="nav-menu-records-label" name="nav-menu-records-label" class="tab"
               type="button" aria-controls="nav-menu-records" aria-expanded="false">Biblio Records</button>
            <ul id="nav-menu-records" class="sub-nav noshow"
               aria-labelledby="nav-menu-records-label" aria-hidden="true">
              <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/view/records')}" class="button">All</a></li>
              <!--<li><a href="#" class="button">In Progress</a></li>-->
            </ul>
          </li>
          <li class="nav-item">
            <button id="nav-menu-articles-label" name="nav-menu-articles-label" class="tab"
               type="button" aria-controls="nav-menu-articles" aria-expanded="false">DHQ Articles</button>
            <ul id="nav-menu-articles" class="sub-nav noshow" 
               aria-labelledby="nav-menu-articles-label" aria-hidden="true">
              <!--<li><a href="#" class="button">All Sets</a></li>-->
              <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/view/articles')}" class="button">Sets in Progress</a></li>
            </ul>
          </li>
          <li class="nav-item">
            <button id="nav-menu-authorities-label" name="nav-menu-authorities-label" class="tab" 
              type="button" aria-controls="nav-menu-authorities" aria-expanded="false">Authority Control</button>
            <ul id="nav-menu-authorities" class="sub-nav noshow"
               aria-labelledby="nav-menu-authorities-label" aria-hidden="true">
              <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/authority/publishers')}" class="button">Publishers</a></li>
            </ul>
          </li>
        </ul>
      </nav>
    </header>;


(:  PERMISSIONS FUNCTIONS  :)

  (:~ 
    Restrict access to the workbench unless the RESTXQ function has been marked for 
    public access with a `%perm:allow` option. If the workbench should not be 
    published at all, redirect user to the public site.
   :)
  declare
    %rest:GET
    %perm:check("/dhq/biblio-qa", "{$perm}")
  function dbqx:check-auth($perm as map(*)) {
    let $attemptedLoc := $perm?path[.]
    return
      if ( $dbqx:workbench-available ) then
        let $redirect := function() {
            web:redirect( '/dhq/biblio-qa/login', 
                          map { 'redirect': $attemptedLoc })
          }
        return dbqx:is-logged-in($perm, $redirect)
      else web:redirect('/dhq/biblio')
  };
  
  
  declare
    %rest:POST
    %rest:header-param('X-Requested-With', '{$requester}', '')
    %perm:check("/dhq/biblio-qa/workbench", "{$perm}")
  function dbqx:check-auth-via-ajax($perm as map(*), $requester) {
    let $attemptedLoc := $perm?path[.]
    (: If the POST request was issued through an AJAX request, return a custom HTTP 
      status code instead of redirecting. It isn't possible for an XMLHttpRequest to 
      intercept a redirect before the browser follows it; a different response code 
      is necessary. :)
    let $errorFunction :=
      if ( $requester eq 'XMLHttpRequest' ) then
        function() {
          wpi:build-response('901', (), dbqx:get-login-form() )
        }
      else 
        function() {
          web:redirect( '/dhq/biblio-qa/login', 
                        map { 'redirect': $attemptedLoc })
        }
    return
      if ( not($dbqx:workbench-available) ) then
        web:redirect('/dhq/biblio')
      else
        dbqx:is-logged-in($perm, $errorFunction)
  };


(:  RESTXQ FUNCTIONS  :)
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/login')
    %rest:query-param('redirect','{$redirect-to}', '/dhq/biblio-qa')
    %output:method('html')
    %perm:allow('all')
  function dbqx:login-form($redirect-to as xs:string) {
    let $userid := session:get('id')
    let $htmlBody :=
      if ( empty($userid) ) then
        dbqx:get-login-form($redirect-to)
      else
        <p>Welcome, { session:get('id') }!</p>
    let $header :=
      if ( empty($userid) ) then ()
      else $dbqx:header
    return
      dbfx:make-xhtml($htmlBody, $header, 'Log in')
  };
  
  
  declare
    %rest:POST
    %rest:path('/dhq/biblio-qa/login')
    %rest:query-param('username','{$username}', '')
    %rest:query-param('password','{$password}', '')
    %rest:query-param('redirect','{$redirect-to}', '/dhq/biblio-qa')
    %perm:allow('all')
  function dbqx:login($username, $password, $redirect-to) {
    try {
      user:check($username, $password),
      session:set('id', $username),
      web:redirect($redirect-to)
    } catch * {
      web:redirect('/dhq/biblio-qa/login', map { 'redirect': $redirect-to })
    }
  };
  
  
  declare
    %rest:POST
    %rest:path('/dhq/biblio-qa/logout')
  function dbqx:logout() {
    session:delete('id'),
    web:redirect('/dhq/biblio-qa/login')
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/index/title')
    %output:method('html')
  function dbqx:index-of-titles() {
    let $interface :=
      <div>
        <div>
          <p><a href="#">Test</a></p>
        </div>
        <div>
          {
            let $sortTitles := dbfx:get-fields-by-element(xs:NCName('title'))
            let $sortFunction := dbfx:get-sortable-title(?)
            return
              dbfx:counts-to-table($sortTitles, $sortFunction)
              (:for $distinct in dbfx:count-instances($sortTitles,$sortFunction)
              return
                <p>{ $distinct }</p>:)
          }
        </div>
      </div>
    return
      dbfx:make-xhtml($interface, $dbqx:header)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa')
    %output:method('html')
  function dbqx:home() {
    let $workingRecords := db:open($dbfx:db-working, 'records')/*
    let $workingSets := db:open($dbfx:db-working, 'sets')/*
    let $indices := map { }
    let $navbar := 
      <nav class="sidebar">
        <ul class="sidebar-component">
          <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/view/records')}">Biblio Records</a></li>
          <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/view/articles')}">DHQ Articles</a></li>
          <li><a href="{dbfx:make-web-url('/dhq/biblio-qa/authority/publishers')}">Authority Control (Publishers)</a></li>
        </ul>
      </nav>
    let $interface := (
      $navbar,
      <div class="main-content">
        <div>
          <p>There are { count($workingRecords) } Biblio entries in progress.</p>
          <table>
            <tbody>
            {
              for $record in $workingRecords
              let $id := $record/@ID/data(.)
              order by $id
              return
                <tr>
                  <td>{ $record/base-uri() }</td>
                  <td class="cell-min cell-centered"><a href="{dbqx:make-web-url-to-record($id)}">Edit</a></td>
                </tr>
            }
            </tbody>
          </table>
        </div><br/>
        <div>
          <p>There are { count($workingSets) } sets of Biblio entries generated from DHQ articles.</p>
          <table>
            <tbody>
            {
              for $set in $workingSets
              let $dbPath := $set/base-uri()
              let $setId := substring-before(tokenize($dbPath, '/')[last()], '.xml')
              order by $setId
              return
                <tr>
                  <td>{ $dbPath }</td>
                  <td class="cell-min cell-centered"><a href="{dbfx:make-web-url('/dhq/biblio-qa/workbench/set/'||$setId)}">Edit</a></td>
                </tr>
            }
            </tbody>
          </table>
        </div>
      </div>
    )
    return dbfx:make-xhtml($interface, $dbqx:header)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/view/articles')
    %output:method('html')
  function dbqx:article-index() {
    let $articlesActionable :=
      dbfx:article-set()[count(.?bibls()?keyed) lt .?bibls()?total]
    let $articlesOutdated := count(mgmt:identify-outdated-files-in-db($dbfx:db-articles))
    let $interface :=
      <div>
        <div class="toolbar">
          {
            if ( $articlesOutdated gt 0 ) then
            <p>There are { $articlesOutdated } outdated DHQ articles. 
              <a href="{dbfx:make-web-url('/dhq/biblio-qa/maintain')}">View and update.</a></p>
            else ()
          }
          <p>There are { count($articlesActionable) } actionable articles.</p>
        </div>
        <div>
          <table>
            <thead>
              <tr>
                <th class="cell-min cell-centered">Article #</th>
                <th>Article title</th>
                <th class="cell-min cell-centered">Citations without keys</th>
                <th class="cell-min cell-centered">Total citations</th>
                <th class="cell-min cell-centered">Biblio set</th>
              </tr>
            </thead>
            <tbody>
            {
              for $article in $articlesActionable
              let $id := $article?id()
              let $setExists := exists(dbqx:get-biblio-set($article?id()))
              order by $setExists descending, $id
              return
                <tr>
                  <td class="cell-min cell-centered">{ $id }</td>
                  <td>{ $article?title() }</td>
                  <td class="cell-min cell-centered">{ count($article?bibls()?nokey) }</td>
                  <td class="cell-min cell-centered">{ $article?bibls()?total }</td>
                  <td class="cell-min cell-centered"><a href="{dbfx:make-web-url('/dhq/biblio-qa/workbench/set/'||$article?id())}">{
                        if ( $setExists ) then "Edit" else "Preview"
                      }</a></td>
                </tr>
            }
            </tbody>
          </table>
        </div>
      </div>
    return
      dbfx:make-xhtml($interface, $dbqx:header)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/view/articles/{$article-id}')
    %output:method('html')
  function dbqx:article-citations($article-id as xs:string) {
    let $article := db:open($dbfx:db-articles, $article-id)
    let $assets := $dbqx:additional-assets?((:'jquery',:) 'keywords')
    let $articleBibliography := $article//tei:listBibl
    let $bibls := $articleBibliography/tei:bibl
    let $citSerial := map { 'indent': 'yes' }
    let $sidebar :=
      <div class="sidebar">
        <h2>Viewing bibliographic records for article
          <a href="{ dbfx:get-article-url($article) }" target="_blank">{ $article-id }</a></h2>
        <div class="sidebar-component">
          <p><a href="{dbfx:make-web-url('/dhq/biblio-qa/create/set/'||$article-id)}">Create/edit Biblio entries</a></p>
        </div>
        { dbqx:get-search-component() }
      </div>
    let $interface := dbfx:make-article-bibliography($articleBibliography)
    let $htmlParts := 
      <div class="container">
        { $sidebar }
        { $interface }
      </div>
    return
      dbfx:make-xhtml($htmlParts, $dbqx:header, $article-id, $assets)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/view/records')
    %output:method('html')
  function dbqx:id-index() {
    let $xmlIndex := mgmt:get-custom-index('id')//text[@string]
    let $interface :=
      <div>
        <div class="toolbar">
          <p>There are { count($xmlIndex) } Biblio entries.</p>
          <p><a href="{dbfx:make-web-url('/dhq/biblio-qa/maintain/index/id')}">Rebuild the <code>@ID</code> index.</a></p>
        </div>
        <div>
          <table>
            <thead>
              <tr>
                <th>Biblio identifier</th>
                <th>Derived citation</th>
                <th>Status</th>
                <th class="cell-min cell-centered">Biblio entry</th>
              </tr>
            </thead>
            <tbody>
            {
              for $entry in $xmlIndex
              let $idValue := $entry/@string/data(.)
              let $hasWorkingCopy := exists($entry/node[@db eq $dbfx:db-working])
              let $entryStatus := 
                if ( $hasWorkingCopy ) then "held for editing"
                else "ready for publication"
              let $actions :=
                <a href="{dbqx:make-web-url-to-record($idValue)}">Edit</a>
              order by $hasWorkingCopy descending, lower-case($idValue)
              return
                <tr>
                  <td class="cell-min">{ $idValue }</td>
                  <td></td>
                  <td>{ $entryStatus }</td>
                  <!--<td><a href="{dbfx:make-web-url('/dhq/biblio-qa/view/records/'||$idValue)}">View entry</a></td>-->
                  <td class="cell-min cell-centered">{ $actions }</td>
                </tr>
            }
            </tbody>
          </table>
        </div>
      </div>
    return
      dbfx:make-xhtml($interface, $dbqx:header)
  };
  
  
  (:~ 
   :)
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/authority')
    %output:method('html')
  function dbqx:authority-control-home() {
    let $form := 
      <form>
        
      </form>
    return
      dbfx:make-xhtml($form, $dbqx:header, "Authority")
  };
  
  
  (:~ 
   :)
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/authority/publishers')
    %rest:query-param('max-distance', '{$max-distance}', '3')
    %output:method('xhtml')
  function dbqx:publishers-authority($max-distance as xs:decimal) {
    let $assets := $dbqx:additional-assets?((:'jquery',:) 'd3js', 'd3sets')
    let $canonicalFieldValues := array { mgmt:get-custom-index('publisher')//text/@string/data(.) (: currently unused :) }
    let $contestedFieldValues := dbqx:bibliographic-records()//dbib:publisher
    let $likelySets := dbqx:get-disambiguation-results($contestedFieldValues, $max-distance)
    let $distMaps := $likelySets/fn:map[@key eq 'edit-distances']/fn:map
    let $entriesByValue := $likelySets/fn:array[@key eq 'entries-by-value']/fn:map
    let $gridComponents :=
      for $valGrp in $distMaps
      let $key := $valGrp/@key/data(.)
      let $members := $valGrp/fn:number/@key/data(.)
      let $tmpId :=
        let $index := count($valGrp/preceding-sibling::fn:map)+1
        return concat('grp',$index)
      return
        <li class="set-container" data-set="{$key}" data-set-id="{$tmpId}">
          <span class="set-name">
            <textarea id="{$tmpId}-name-input" name="{$tmpId}-name" form="authentry" 
              autocomplete="off" rows="2" aria-labelledby="label-grp-name" 
              class="subtle handle">{ $key }</textarea>
          </span>
          <fieldset class="set-member-group" aria-labelledby="label-grp-members">
          {
            for $member in $members
            let $alsoMemberOf := $distMaps[@key ne $key][fn:number[@key eq $member]]
            let $biblioEntries :=
              let $entryArray := 
                $entriesByValue[fn:string[@key eq 'value']/text() eq $member]
                               /fn:array[@key eq 'entries']
              return $entryArray/fn:string/text()
            let $numEntries := count($biblioEntries)
            return
              <span class="set-member" data-key="{$member}" data-set-ref="{$key}">
                <label>
                  <input type="checkbox" name="{$tmpId}-members[]" value="{$member}"
                    form="authentry">{
                      if ( $key eq $member and $key = $canonicalFieldValues ) then
                        attribute class { 'membership-flag canonical-flag' }
                      else 
                        attribute class { 'membership-flag' }
                    }</input>
                  "{ $member }"
                </label>
                { dbfx:insert-whitespace() }
                <button name="clone-{$tmpId}" type="button" class="drag-handle">Clone</button>
                <span>Occurs in { $numEntries } Biblio entr{ if ( $numEntries eq 1 ) then 'y' else 'ies' 
                }</span>
                <span>{
                    attribute class { 
                      let $base := "set-member-refs"
                      return 
                        if ( count($alsoMemberOf) eq 0 ) then 
                          concat($base, ' set-member-refs-empty')
                        else $base
                    }
                  }
                  <span>Candidate in other group(s):</span>
                  <ul>
                  {
                    for $groupRef in $alsoMemberOf
                    return
                      <li class="set-ref">{ $groupRef/@key/data(.) }</li>
                  }
                  </ul>
                </span>
              </span>
          }
          </fieldset>
        </li>
    (:let $entries := dbrx:serialize-results($contestedFieldValues/root(.), (), 'json'):)
    (: Make the data available as JSON in the web interface. :)
    let $jsonData :=
      <script type="application/javascript">
        <![CDATA[
          // Set up namespace for DHQ functions
          var bibjs = bibjs || {};
          bibjs.data = bibjs.data || {};
          bibjs.data = ]]>{ xml-to-json($likelySets) }<![CDATA[;]]>
      </script>
    let $interface :=
      <div class="container">
        <div class="sidebar">
          <div class="sidebar-component">
            <p>Instructions: The grid you see was compiled from Biblio values for this 
              field type. For each row, decide what the canonical value should be in Biblio, and 
              check off all existing values which refer to the same entity.</p>
            <p>Press or drag the “Clone” button to enter drag-and-drop mode. String values can be 
              copied to other rows, but can only be associated with one canonical name at a time.</p>
          </div>
          <form id="authentry" action="{dbfx:make-web-url('/dhq/biblio-qa/authority/publishers')}" method="post" enctype="text/plain">
            <button type="submit">Submit</button>
          </form>
          <div class="sidebar-component sidebar-sticky kbd-instructions" style="display: none;">
            <p><em>Keyboard drag-and-drop mode:</em> Tab through the canonical names and their 
              associated values. To add a clone to the current selection, use the Space or the 
              Enter keys. This will take you out of drag-and-drop mode.</p>
          </div>
        </div>
        <div>
          <div class="container label-group">
            <span id="label-grp-name" class="label" style="width: 30%;">Canonical name</span>
            <span id="label-grp-members" class="label" style="width: 30%;">Matching field values</span>
          </div>
          <ul id="sets" class="grid">
            { $gridComponents }
          </ul>
        </div>
        { $jsonData }
      </div>
    return
      dbfx:make-xhtml($interface, $dbqx:header, 'Publishers', $assets)
  };
  
  
  declare
    %rest:POST('{$data}')
    %rest:path('/dhq/biblio-qa/authority/publishers')
    %output:method('xhtml')
    %updating
  function dbqx:publishers-authority-resolution($data) {
    (: Turn the JSON string into pseudo-JSON XML. :)
    let $useData := dbqx:convert-disambiguation-data($data)
    let $fieldIndexEntries :=
      for $set in $useData/fn:array/fn:map
      let $canonicalName := $set/fn:string[@key eq 'name']/dbqx:convert-reserved-characters(.)
      return mgmt:create-index-entry-for($canonicalName, ())
    return
    (
      mgmt:index-all('publisher', $fieldIndexEntries),
      (: For each set of values corresponding to a single entity... :)
      for $set in $useData/fn:array/fn:map
      let $canonicalName := $set/fn:string[@key eq 'name']/dbqx:convert-reserved-characters(.)
      let $variations := $set/fn:array[@key eq 'variations']/fn:string/dbqx:convert-reserved-characters(.)
      let $matchingFields := 
        dbqx:bibliographic-records()//dbib:publisher[. = $variations]
      return
        (: ...change the field values to the canonical string, and reindex those records. :)
        for $field in $matchingFields
        let $db := db:name($field)
        return
          (: If this field's variation matches the canonical string, do nothing. :)
          if ( $field/xs:string(.) = $canonicalName ) then ()
          (: Otherwise, replace the field value with the canonical version. :)
          else
            (
              replace value of node $field with $canonicalName,
              if ( dbqx:get-node-identifier($field) ) then
                let $jobId := mgmt:schedule-indexing(dbqx:get-node-identifier($field), $db)
                return ()
              else ()
            )
      ,
      update:output(
        web:redirect('/dhq/biblio-qa/authority/publishers') )
      (:update:output($useData(\:dbfx:make-xhtml($useData, $dbqx:header, 'Publishers'):\)):)
    )
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/workbench/record/{$recordID}')
    %output:method('html')
  function dbqx:record-workbench($recordID as xs:string) {
    let $record := dbqx:get-newest-record($recordID)
    let $sidebar :=
      <div class="sidebar">
        <h2>Editing Biblio entry {$recordID}</h2>
        <div class="sidebar-component">
          <div>
            <form method="post" class="data-form data-form-xonomy" 
               action="{dbfx:make-web-url(concat('/dhq/biblio-qa/workbench/record/',$recordID,'/validate'))}">
              <button onclick="bibjs.xonomy.validateXml(event)" type="submit">Validate</button>
            </form>
            <form method="post" class="data-form data-form-xonomy" 
               action="{dbfx:make-web-url(concat('/dhq/biblio-qa/workbench/record/',$recordID,'/arrange'))}">
              <button onclick="bibjs.xonomy.rearrangeData(event)" type="submit">Arrange to schema</button>
            </form>
          </div>
          <div id="validation-results">
            
          </div>
        </div>
        <div class="container sidebar-component">
        {
          let $saveXmlForm :=
            <form id="save-record" method="post" class="data-form data-form-xonomy"
               action="{dbqx:make-web-url-to-record($recordID)}">
              <button onclick="bibjs.xonomy.saveXml(event)" type="submit">Save</button>
            </form>
          let $asynchParts := dbqx:make-asynch-status-components($saveXmlForm)
          return (
              <div class="flex">
                { $asynchParts[1] }
                <form id="publish-record" method="post" class="data-form data-form-xonomy"
                  action="{dbqx:make-web-url-to-record($recordID)||'/publish'}">
                 <button onclick="bibjs.xonomy.saveAsPublicXml(event)" type="submit">Publish</button>
               </form>
              </div>,
              $asynchParts[2]
            )
        }
        </div>
        { dbqx:get-search-component() }
      </div>
    return dbqx:make-workbench($record, $sidebar, $recordID)
  };
  
  
  (:~ 
    Save a Biblio item to the working database.
   :)
  declare
    %rest:POST("{$record}")
    %rest:path('/dhq/biblio-qa/workbench/record/{$record-id}')
    %updating
  function dbqx:update-record($record-id as xs:string, $record as node()?) {
    if ( exists($record) ) then
    (
      (: Store item :)
      mgmt:store-working-record($record, $record-id)
      ,
      let $locationHeader :=
        <http:header name="Location" 
          value="{dbfx:make-web-url('/dhq/biblio-qa/workbench/records/'||$record-id)}"/>
      return
        update:output( wpi:build-response('201', $locationHeader) )
    )
    else update:output( wpi:build-response('400') )
  };
  
  
  declare
    %rest:POST('{$record}')
    %rest:path('/dhq/biblio-qa/workbench/record/{$record-id}/publish')
    %output:method('xhtml')
    %updating
  function dbqx:publish-record($record-id as xs:string, $record) {
    let $recordXml := dbqx:check-record-submission($record)
    return
      if ( exists($recordXml) ) then
        (: Run strict validation on the XML record. :)
        let $valReport := dbqx:validate($recordXml)
        let $isValid := $valReport(1)
        return 
          if ( $isValid ) then (
              mgmt:publish-record($recordXml/*, $record-id),
              update:output(<p>Published!</p>)
            )
          else
            update:output( dbqx:report-validation-errors($valReport) )
      else ()
  };
  
  
  declare
    %rest:POST("{$record}")
    %rest:path('/dhq/biblio-qa/workbench/record/{$record-id}/arrange')
    %output:method('xml')
  function dbqx:arrange-record-contents($record-id as xs:string, $record) {
    let $fallbackXml := dbqx:get-newest-record($record-id)
    let $recordXml := dbqx:check-record-submission($record, $fallbackXml)
    return 
      if ( exists($recordXml) ) then
        dbqx:arrange-to-schema($recordXml/descendant-or-self::*[1])
      else if ( mgmt:biblio-id-entry-exists($record-id) ) then
        wpi:build-response('500')
      else wpi:build-response('404')
  };
  
  (:~
    Validate a Biblio entry. If XML is provided in the body of the request, that XML 
    is validated. Otherwise, validate the newest record matching the identifier.
   :)
  declare
    %rest:POST('{$record}')
    %rest:path('/dhq/biblio-qa/workbench/record/{$record-id}/validate')
    %output:method('xhtml')
  function dbqx:validate-record($record-id as xs:string, $record) {
    let $fallbackXml := dbqx:get-newest-record($record-id)
    let $recordXml := dbqx:check-record-submission($record, $fallbackXml)
    return
      if ( exists($recordXml) ) then
        let $valReport := dbqx:validate($recordXml)
        return dbqx:report-validation-errors($valReport)
      else if ( mgmt:biblio-id-entry-exists($record-id) ) then
        wpi:build-response('500')
      else wpi:build-response('404')
  };
  
  (:~ 
    Create a <biblioRef> citation for a record.
   :)
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/workbench/record/{$record-id}/reference')
    %output:method('xml')
  function dbqx:make-biblio-ref($record-id as xs:string) {
    let $useRecord := dbqx:get-newest-record($record-id)
    return
      if ( $useRecord ) then
        dbfx:make-biblio-ref($useRecord)
      (: If there's an index entry for the given identifier, but a record couldn't 
        be retrieved, something internal went wrong (likely the ID index going out 
        of date). :)
      else if ( mgmt:biblio-id-entry-exists($record-id) ) then
        wpi:build-response('500')
      else wpi:build-response('404')
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/create/set/{$article-id}')
    %updating
  function dbqx:create-set($article-id as xs:string) {
    let $setPath := dbqx:get-biblio-set-dirpath($article-id, false())
    return
    (
      if ( db:exists($dbfx:db-working, $setPath) ) then
        ()
      else
        let $biblioSet := dbqx:create-biblio-set($article-id)
        return dbqx:store-biblio-set($article-id, $biblioSet)
      ,
      update:output(
        web:redirect('/dhq/biblio-qa/workbench/set/'||$article-id) )
    )
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/workbench/set/{$article-id}')
    %output:method('html')
  function dbqx:set-workbench($article-id as xs:string) {
    let $requestedSet := dbqx:get-biblio-set($article-id)
    let $requestedSetExists := exists($requestedSet)
    let $extracts := 
      if ( $requestedSetExists ) then $requestedSet
      else dbqx:create-biblio-set($article-id)
    let $articleLink :=
      try {
        <a href="{ dbfx:get-article-url(db:open($dbfx:db-articles, $article-id)) }" 
          target="_blank">{ $article-id }</a>
      } catch * { $article-id }
    let $asyncSaveParts :=
      let $saveForm :=
        <form id="save-set" method="post" class="data-form data-form-xonomy"
            action="{dbfx:make-web-url('/dhq/biblio-qa/workbench/set/'||$article-id)}">
          <button onclick="bibjs.xonomy.saveXml(event)" type="submit">Save</button>
        </form>
      return
        dbqx:make-asynch-status-components($saveForm)
    let $sidebar :=
      <div class="sidebar">
        <h2>{
            if ( $requestedSetExists ) then "Editing"
            else "Viewing"
          } bibliographic records for article {$articleLink}</h2>
        <div class="sidebar-component">
          <div class="container">
            { $asyncSaveParts[self::form] }
            <form id="harvest-completed" method="post" class="data-form data-form-xonomy"
               action="{dbfx:make-web-url(concat('/dhq/biblio-qa/workbench/set/',$article-id,'/harvest'))}">
              <button type="submit" onclick="bibjs.xonomy.saveAndHarvestXml(event)" 
                aria-controls="{$asyncSaveParts[@role eq 'status']/@id/data(.)}">Harvest and Save</button>
            </form>
          </div>
          { $asyncSaveParts[self::p] }
        </div>
        { dbqx:get-search-component() }
        <div id="warnings" class="sidebar-component">
          {
            for $bibItem in $extracts/dbib:BiblioSet/dbib:BiblioItem
            let $id := $bibItem/@ID/data(.)
            let $matched := mgmt:biblio-id-exists($id)
            return
              if ( $matched ) then
                <p><strong><a href="#" class="xonomy-match-id">{$id}</a></strong> matches existing entry: 
                  { 
                    let $match := mgmt:get-canonical-record($id)
                    return dbfx:make-citation($match)
                  }</p>
              else ()
          }
        </div>
      </div>
    return
      dbqx:make-workbench($extracts, $sidebar, $article-id)
  };
  
  
  (:~ 
    Save a <BiblioSet> to the working database.
   :)
  declare
    %rest:POST("{$full-set}")
    %rest:path('/dhq/biblio-qa/workbench/set/{$set-id}')
    %updating
  function dbqx:update-set($set-id as xs:string, $full-set as node()) {
    (
      dbqx:store-biblio-set($set-id, $full-set)
      ,
      let $locationHeader :=
        <http:header name="Location" 
          value="{dbfx:make-web-url('/dhq/biblio-qa/workbench/set/'||$set-id)}"/>
      return
        update:output( wpi:build-response('201', $locationHeader) )
    )
  };
  
  
  (:~ 
    This is a harvest operation. Readied and permissively-valid Items are ingested 
    into the biblio-working database. Readied Items that are not permissively-valid
    are augmented with warnings.
   :)
  declare
    %rest:POST("{$working-set}")
    %rest:path('/dhq/biblio-qa/workbench/set/{$set-id}/harvest')
    %output:method('xml')
    %output:omit-xml-declaration('yes')
    %updating
  function dbqx:harvest-records($set-id as xs:string, $working-set as xs:string) {
    let $xml-set := parse-xml($working-set)
    (: Run permissive validation on the XML. :)
    let $validatedSet := dbqx:validate-set-permissively($xml-set)
    (: Split the contents of the @ready BiblioSet. Items that will be ingested are 
      turned into <biblioRef>s. :)
    let $readySetItems := $validatedSet//dbib:BiblioSet[@ready eq 'true']/dbib:*
    let $existingRefs := $readySetItems[self::dbib:biblioRef]
    let $ingestible := $readySetItems[not(self::dbib:biblioRef)]
    let $referenceSet :=
      copy $bibSet := $validatedSet
      modify replace node $bibSet//dbib:BiblioSet[@ready eq 'true'] with 
        <BiblioSet xmlns="http://digitalhumanities.org/dhq/ns/biblio" ready="true"> {
          let $allRefs :=
            (
              $existingRefs,
              for $entry in $ingestible
              return dbfx:make-biblio-ref($entry)
            )
          return
            (
              for $ref in $allRefs
              order by $ref/@key/data(.)
              return $ref,
              " "
            )
        } </BiblioSet>
      return $bibSet
    return
    (
      (: Ingest records, and update the custom ID index. :)
      for $item in $ingestible
      (: Ensure that BaseX does not drop the namespace declaration when XML 
        fragments are saved on their own. :)
      let $qName := 
        QName('http://digitalhumanities.org/dhq/ns/biblio', $item/local-name())
      let $nsItem :=
        copy $modItem := $item
        modify rename node $modItem as $qName
        return $modItem
      return mgmt:store-working-record($nsItem)
      ,
      (: Save the validated and modified report. :)
      dbqx:store-biblio-set($set-id, $referenceSet)
      ,
      (: Return the validated report to the client. :)
      update:output($referenceSet)
    )
  };


  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/maintain')
    %output:method('html')
  function dbqx:maintain() {
    let $outdatedArticles := mgmt:identify-outdated-files-in-db($dbfx:db-articles)
    let $interface :=
      <div class="container container-main">
        <div class="container container-col">
          <p>There are { count($outdatedArticles) } outdated DHQ articles.</p>
          
          {
            if ( count($outdatedArticles) gt 0 ) then
            (
              <p>
                <a href="{dbfx:make-web-url('/dhq/biblio-qa/maintain/update-articles')}" class="button">Update all</a>
              </p>,
              <ul>
              {
                for $file in $outdatedArticles
                return
                  <li>{ $file/text() }</li>
              }
              </ul>
            )
            else ()
          }
        </div>
      </div>
    return dbfx:make-xhtml($interface, $dbqx:header)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/maintain/index/id')
    %output:method('html')
    %updating
  function dbqx:update-id-index() {
    let $wrap := dbfx:make-xhtml(?, $dbqx:header)
    return mgmt:rebuild-id-index($wrap)
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio-qa/maintain/update-articles')
    %output:method('html')
    %updating
  function dbqx:update-articles() {
    let $wrap := dbfx:make-xhtml(?, $dbqx:header)
    return mgmt:update-db-from-file-system($dbfx:db-articles, false(), $wrap)
  };
  
  
  declare
    %rest:POST
    %rest:query-param('contains', '{$contains}', '')
    %rest:path('/dhq/biblio-qa/mint')
    %output:method('json')
    %perm:allow('all')
  function dbqx:get-biblio-identifiers($contains) {
    let $useAttrs := dbqx:bibliographic-records()//@ID/data(.)
    let $useAttrs :=
      if ( $contains ) then
        for $query in $contains
        return $useAttrs[contains(., $query)]
      else $useAttrs
    let $ids := 
      for $id in $useAttrs
      order by lower-case($id)
      return $id
    return array { $ids }
  };
  
  
  declare
    %rest:POST
    %rest:path('/dhq/biblio-qa/mint/{$identifier}')
    %output:method('json')
    %perm:allow('all')
  function dbqx:test-available-id($identifier as xs:string) {
    let $match := dbfx:get-record($identifier)
    return
      if ( exists($match) ) then
        dbfx:make-citation($match)
      else ()
  };
  
  
  
(:  SUPPORT FUNCTIONS  :)
  
  (:~
    Add an attribute for the sole purpose of communicating validation information to 
    the Xonomy editor, such as "this Biblio item has a duplicate ID".
   :)
  declare %private function dbqx:add-temporary-attributes($item as node()) {
    if ( $item/self::dbib:biblioRef ) then $item
    else
      let $id := $item/@ID/data(.)
      let $hasUniqueId := not(mgmt:biblio-id-exists($id))
      (: Remove old validation attributes before adding fresh ones. :)
      let $freshItem := dbqx:clear-temporary-attributes($item)
      return
        if ( not($hasUniqueId) ) then
          let $match := mgmt:get-canonical-record($id)
          let $citation := dbfx:make-citation($match)
          return
            copy $modItem := $freshItem
            modify 
              insert node attribute duplicate-id { $citation } into $modItem
            return $modItem
        else $freshItem
  };
  
  (:~
    
   :)
  declare %private function dbqx:bibliographic-records() {
    let $working := db:open($dbfx:db-working, 'records')/*
    let $omitIds := $working/@ID/data(.)
    let $public := dbfx:bibliographic-records()[not(/*/@ID = $omitIds)]
    return ($working, $public)
  };
  
  
  declare %private function dbqx:check-record-submission($record) {
    dbqx:check-record-submission($record, ())
  };
  
  
  declare %private function dbqx:check-record-submission($record, $on-error as item()?) {
    try { parse-xml($record) }
    catch * { $on-error }
  };
  
  
  declare %private function dbqx:clear-temporary-attributes($item as node()) {
    copy $clearedItem := $item
    modify delete nodes ( $clearedItem//@validation-message, $clearedItem//@duplicate-id )
    return $clearedItem
  };
  
  
  (:~
   :)
  declare %private function dbqx:convert-disambiguation-data($data as xs:string?) as node() {
    let $dataLines := tokenize($data, '\n')
    let $json := $dataLines[matches(., '^json=')]
    (: Prefer JSON over the form parameters, but convert the form parameters if 
      needed (e.g., JS doesn't load). :)
    let $xmlData :=
      if ( $json ) then json-to-xml(substring-after($json, '='))
      else
        <fn:array>
        {
          for $param in $dataLines[matches(., '^grp\d+-name=')]
          let $paramParts := tokenize($param, '=')
          let $setNum := substring-before($paramParts[1],'-name')
          let $setName := $paramParts[2]
          let $members := 
            let $arrayParam := concat('^',$setNum,'-members\[\]=')
            return $dataLines[matches(., $arrayParam)]
          return
            <fn:map>
              <fn:string key="name">{ $setName }</fn:string>
              <fn:array key="variations">
              {
                for $member in $members
                return
                  <fn:string>{ substring-after($member, '=') }</fn:string>
              }
              </fn:array>
            </fn:map>
        }
        </fn:array>
    return
      (: Remove <fn:map>s with no associated string values. The remainder should be 
        only those sets which either are canonical, or were just updated. :)
      copy $xmlMunged := $xmlData
      modify
        for $emptyMap in $xmlMunged/fn:array/fn:map[fn:array[@key eq 'variations'][empty(node())]]
        return delete node $emptyMap
      return $xmlMunged
  };
  
  
  declare %private function dbqx:convert-reserved-characters($text as xs:string) {
    let $normalized := normalize-space($text)
    let $amp := replace($normalized, '&amp;amp;', '&amp;')
    return $amp
  };
  
  
  declare %private function dbqx:create-biblio-set($article-id as xs:string) as node()? {
    let $ography := db:open($dbfx:db-articles, $article-id)//tei:listBibl
    let $entries :=
      <listBibl xmlns="http://www.tei-c.org/ns/1.0">
      {
        for $bibl in $ography/tei:bibl
        let $key := dbfx:get-citation-key($bibl)
        return
          if ( exists($key) and mgmt:biblio-id-exists($key) ) then
            let $record := mgmt:get-canonical-record($key)
            return dbfx:make-biblio-ref($record)
          else if ( exists($key) and $key eq '[unlisted]' ) then
            ()
          else
            $bibl
      }
      </listBibl>
    let $extracts := dbfx:extract-biblio-entries-from-tei($entries)
    let $xqTested := 
      copy $set := $extracts/dbib:BiblioSet
      modify
        for $bibItem in $set//dbib:*[@ID]
        let $tested := dbqx:add-temporary-attributes($bibItem)
        return
          if ( not(deep-equal($tested, $bibItem)) ) then
            replace node $bibItem with $tested
          else ()
      return $set
    return $xqTested
  };
  
  
  declare function dbqx:disambiguate($value as xs:string, $variations as xs:string, $get-matches as (function(node()*) as node()*)) {
    (: TODO :)
  };
  
  
  declare %private function dbqx:get-biblio-set($set-id as xs:string) as node()? {
    try {
      db:open($dbfx:db-working, dbqx:get-biblio-set-filepath($set-id, false()))
    } catch * { () }
  };
  
  
  (:declare function dbqx:get-biblio-set-dirpath($set-id as xs:string) as xs:string {
    dbqx:get-biblio-set-dirpath($set-id, true())
  };:)
  
  
  declare %private function dbqx:get-biblio-set-dirpath($set-id as xs:string, $include-db as xs:boolean) as xs:string {
    let $prefix := 
      if ( $include-db ) then
        concat($dbfx:db-working,'/')
      else ''
    return concat($prefix,'sets/',$set-id)
  };
  
  
  declare %private function dbqx:get-biblio-set-filepath($set-id as xs:string, $include-db as xs:boolean) as xs:string {
    let $dirpath := dbqx:get-biblio-set-dirpath($set-id, $include-db)
    return concat($dirpath,'/',$set-id,'.xml')
  };
  
  declare function dbqx:get-disambiguation-results($nodes as node()*, $max-distance as xs:decimal) {
    let $distinctTokens := distinct-values($nodes/normalize-space(.))
    let $likelySets := 
      let $distanceResults :=
        lev:compare-alphabetically-grouped-tokens($distinctTokens, $max-distance)
      return lev:create-full-report($distanceResults)
    let $biblioInstances :=
      <array xmlns="http://www.w3.org/2005/xpath-functions" key="entries-by-value">
      {
        for $group in $likelySets//fn:map[@key]
        let $key := $group/@key/data(.)
        let $mod :=
          <map xmlns="http://www.w3.org/2005/xpath-functions">
            <string key="value">{$key}</string>
            <array key="entries">
            {
              for $match in $nodes[normalize-space(.) eq $key]
              return
                <string>{ dbqx:get-node-identifier($match) }</string>
            }
            </array>
          </map>
        return $mod
      }
      </array>
    let $wrapped :=
      <map xmlns="http://www.w3.org/2005/xpath-functions">
        { $biblioInstances }
      {
        copy $keyed := $likelySets
        modify
          insert node attribute key { 'edit-distances' } into $keyed
        return $keyed
      }
      </map>
    return $wrapped
  };
  
  
  declare %private function dbqx:get-login-form() as node() {
    dbqx:get-login-form('')
  };
  
  
  declare %private function dbqx:get-login-form($redirect-to as xs:string) as node() {
    <div class="container container-grid">
      <h1 id="login-heading" class="grid-item grid-item-centered">Please log in.</h1>
      
      <form id="login-form" action="{dbfx:make-web-url('/dhq/biblio-qa/login')}" method="post" 
            class="grid-item grid-item-centered container container-grid">
        {
          if ( $redirect-to ne '' ) then
            <input type="hidden" name="redirect" value="{$redirect-to}"/>
          else ()
        }
        <label for="username">Username</label>
        <input name="username" />
        <label for="password">Password</label>
        <input name="password" type="password" />
        <button type="submit">Submit</button>
      </form>
    </div>
  };
  
  
  declare %private function dbqx:get-newest-record($id as xs:string) {
    let $useId := web:decode-url($id)
    let $indexEntry := mgmt:get-index-entry('id', $useId)
    let $priority :=
      ( $indexEntry/node[@db eq $dbfx:db-working], 
        $indexEntry/node[@db eq $dbfx:db-public] )[1]
    return
      if ( $priority ) then
        let $dbName := $priority/@db/data(.)
        let $nodeId := $priority/normalize-space() cast as xs:integer
        return db:open-id($dbName, $nodeId)
      else ()
  };
  
  
  declare function dbqx:get-node-identifier($node as node()?) {
    if ( $node ) then
      root($node)/*[@ID]/@ID/data(.)
    else ()
  };
  
  
  declare %private function dbqx:get-record($db-name as xs:string, $id as xs:string) {
    let $indexEntry := mgmt:get-index-entry('id', $id)
    let $nodeId := ($indexEntry/node[@db eq $db-name])[1]/xs:integer(.)
    return
      if ( exists($nodeId) ) then
        db:open-id($db-name, $nodeId)
      else ()
  };
  
  
  declare %private function dbqx:get-search-component() {
    let $onclickFn := "bibjs.search.pageThroughResults(event)"
    let $resultsNav := 
      <nav class="results-nav">
        <ol>
          <li class="results-pg-nav results-pg-first">
            <button name="results-pg-first" type="button" onclick="{$onclickFn}" 
              disabled="disabled">First</button></li>
          <li class="results-pg-nav results-pg-prev">
            <button name="results-pg-prev" type="button" onclick="{$onclickFn}" 
              disabled="disabled">Previous</button></li>
          <li class="results-pg-nav results-pg-next">
            <button name="results-pg-next" type="button" onclick="{$onclickFn}" 
              disabled="disabled">Next</button></li>
          <li class="results-pg-nav results-pg-last">
            <button name="results-pg-last" type="button" onclick="{$onclickFn}" 
              disabled="disabled">Last</button></li>
        </ol>
      </nav>
    return
      <div id="search-module" class="sidebar-component">
        <h3>Search existing records</h3>
        <form action="{dbfx:make-web-url('/dhq/biblio/api')}" class="container container-grid">
          <input type="hidden" name="fields" value="citation" />
          <label for="keywords">Keywords</label>
          <input type="search" id="keywords" name="keywords" />
          <button type="submit">Search</button>
        </form>
        <div id="search-results" class="noshow">
          <div class="flex" style="justify-content:space-between;">
            <h4>Results <span class="info-count"></span></h4>
            <button id="search-results-toggle" name="search-results-toggle" type="button" 
              class="dismissable-btn" aria-controls="search-results-pane" aria-expanded="true"
              onclick="bibjs.a11y.toggleCollapsibleEvent(event);">Toggle visibility</button>
          </div>
          <div id="search-results-pane" class="sidebar-component dismissable">
            { $resultsNav }
            <div class="citation-group"></div>
            { $resultsNav }
          </div>
        </div>
      </div>
  };
  
  
  declare %private function dbqx:get-working-record($id as xs:string) {
    let $filepath := dbqx:get-working-record-filepath($id, true())
    return doc($filepath)
  };
  
  
  declare %private function dbqx:get-working-record-dirpath($id as xs:string, $include-db as xs:boolean) as xs:string {
    let $prefix := 
      if ( $include-db ) then
        concat($dbfx:db-working,'/')
      else ''
    return concat($prefix,'records/',$id)
  };
  
  
  declare %private function dbqx:get-working-record-filepath($id as xs:string, $include-db as xs:boolean) as xs:string {
    let $dirpath := dbqx:get-working-record-dirpath($id, $include-db)
    return concat($dirpath,'/',$id,'.xml')
  };
  
  
  declare %private function dbqx:is-logged-in($perm as map(*), $on-error as function(*)) {
    let $user := session:get('id')
    where not($perm?allow = 'all') and empty($user)
    return $on-error()
  };
  
  
  declare %private function dbqx:make-asynch-status-components($form as node()) as node()+ {
    let $formId := $form/descendant-or-self::form[@id]/@id/data(.)
    let $statusId := concat($formId,'-status')
    return
      if ( $statusId eq '-status' ) then $form
      else
        (
          copy $formMod := $form
          modify 
            let $submitBtn := $formMod//button[@type eq 'submit']
            let $ariaAttr := $submitBtn/@aria-controls
            return
              if ( exists($ariaAttr) ) then
                replace value of node $ariaAttr with concat($ariaAttr/data(.),' ',$statusId)
              else
                insert node attribute aria-controls { $statusId } into $submitBtn
          return $formMod
          ,
          <p role="status" aria-live="polite">{ attribute id { $statusId } }</p>
        )
  };
  
  
  declare function dbqx:make-data-import-prov-activity($label as item()*) {
    let $id := dbqx:mint-prov-identifier('import')
    let $useLabel :=
      if ( exists($label) ) then $label
      else <prov:label xml:lang="en">Import of Biblio data from version control.</prov:label>
    return
      provxq:activity($id, current-dateTime(), (), $label)
  };
  
  (:~ Create a generic PROV entity to represent the idealized form of a Biblio entry. :)
  declare function dbqx:make-generic-prov-entity($id as item()) as node() {
    let $useId :=
      typeswitch ($id)
        case xs:QName return $id
        default return dbqx:set-prov-QName($id)
    return provxq:entity($useId, "Generic form")
  };
  
  
  declare function dbqx:make-specialized-prov-entity($item as node(), $db-name as xs:string, 
     $generic-entity as node()) as node()* {
    let $useId := dbqx:mint-prov-identifier($generic-entity/@prov:id/data(.))
    return
      dbqx:make-specialized-prov-entity($item, $db-name, $generic-entity, $useId)
  };
  
  
  declare function dbqx:make-specialized-prov-entity($item as node(), $db-name as xs:string, 
     $generic-entity as node(), $id as xs:QName) as node()* {
    let $biblioRef := dbfx:make-biblio-ref($item)/descendant-or-self::dbib:biblioRef
    let $entity := 
      provxq:entity($id, (), $db-name, 
        <prov:type xsi:type="xsd:QName">dbib:{ node-name($item) }</prov:type>, $biblioRef)
    let $specialRel :=
      provxq:specialization-of($entity, $generic-entity)
    return
      ( $entity, $specialRel )
  };
  
  
  declare %private function dbqx:make-web-url-to-record($record-id as xs:string) {
    let $encodedId := web:encode-url($record-id)
    let $relPath := concat('/dhq/biblio-qa/workbench/record/',$encodedId)
    return
      dbfx:make-web-url($relPath)
  };
  
  
  declare %private function dbqx:make-workbench($contents as node()?, $sidebar as node(), $title-part as xs:string) {
    let $assets := $dbqx:additional-assets?((:'jquery',:) 'modal', 'xonomy', 'keywords')
    let $htmlParts := 
      if ( $contents ) then
        let $interface := 
          <div class="main-content">
            <div id="xonomy-source" class="noshow">{ serialize($contents) }</div>
            <div id="xonomy-editor"></div>
          </div>
        return ( $sidebar, $interface )
      else
        <div class="warning">
          <p>The requested resource does not exist.</p>
          <p><a href="{dbfx:make-web-url('/dhq/biblio-qa')}">Return to index</a></p>
        </div>
    return
      dbfx:make-xhtml($htmlParts, $dbqx:header, $title-part, $assets)
  };
  
  declare function dbqx:mint-prov-identifier($base-id as xs:string) as xs:QName {
    dbqx:mint-prov-identifier($base-id, ())
  };
  
  declare function dbqx:mint-prov-identifier($base-id as xs:string, $index as xs:string?) as xs:QName {
    let $currentDateTime := 
      let $now := current-dateTime()
      return format-dateTime($now, '[Y0001][M01][D01][H01][m01]')
    return
      dbqx:set-prov-QName( concat($base-id,'-',$currentDateTime,$index) )
  };
  
  declare %private function dbqx:report-validation-errors($validation-results as array(*)) {
    let $isValid := $validation-results(1)
    let $errors :=
      if ( $isValid ) then ()
      else $validation-results(2)
    return
      <div>
        <p>{ if ( $isValid ) then 'Valid.' else 'Invalid:' }</p>
        {
          if ( not($isValid) ) then
            <ul>
            {
              for $index in (1 to array:size($errors))
              let $error := $errors($index)
              return
                <li>{ $error }</li>
            }
            </ul>
          else ()
        }
      </div>
  };
  
  (: Given an identifier, assign it Biblio's PROV namespace. :)
  declare %private function dbqx:set-prov-QName($id as xs:string) as xs:QName {
    let $useId := 
      if ( starts-with($id, 'bprov:') ) then $id 
      else concat('bprov:',$id)
    return
      QName('http://digitalhumanities.org/dhq/biblio-qa/prov/', $useId)
  };
  
  declare %private %updating function dbqx:store-biblio-set($set-id as xs:string, $biblio-set as node()) {
    let $path := dbqx:get-biblio-set-filepath($set-id, false())
    return
      db:replace($dbfx:db-working, $path, $biblio-set)
  };
  
  (:~ 
    Arrange the contents of a BiblioItem such that its children follow the order 
    defined by the schema.
   :)
  declare function dbqx:arrange-to-schema($item as node()) {
    let $stylesheet := mrng:generate-sorting-stylesheet($item)
    return xslt:transform($item, $stylesheet)
  };
  
  declare function dbqx:validate($item as node()) {
    let $report := validate:rng-report($item, '../schema/dhqBiblio.rng')
    let $isValid := $report//status eq "valid"
    let $messages :=
      array {
        for $message in distinct-values($report//message)
        return $message
      }
    return
      array { $isValid, $messages }
  };
  
  declare %private function dbqx:validate-permissively($input as node()) {
    dbqx:validate-permissively($input, ())
  };
  
  
  declare %private function dbqx:validate-permissively($input as node(), $parameters as map(*)?) {
    xslt:transform($input, 'transforms/permissive-validation.xsl', $parameters)
  };
  
  
  declare %private function dbqx:validate-item-permissively($item as node()) {
    let $xqTestedItem := dbqx:add-temporary-attributes($item)
    return dbqx:validate-permissively($xqTestedItem)
  };
  
  
  declare %private function dbqx:validate-set-permissively($biblio-set as node()) {
    let $matchedIds := ()
    let $refreshedSet :=
      copy $newSet := $biblio-set
      modify 
        for $item in $newSet//dbib:BiblioSet[@ready eq 'true']/dbib:*
        let $refreshedItem := dbqx:add-temporary-attributes($item)
        return replace node $item with $refreshedItem
      return $newSet
    return dbqx:validate-permissively($refreshedSet)
  };
