xquery version "3.1";

module namespace dbrx="http://digitalhumanities.org/dhq/ns/biblio/rest";
(:  LIBRARIES  :)
  import module namespace dbfx="http://digitalhumanities.org/dhq/ns/biblio/lib" at "lib/biblio-functions.xql";
  import module namespace request = "http://exquery.org/ns/request";
  import module namespace wpi="http://www.wwp.northeastern.edu/ns/api/functions" at "lib/api.xql";
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace fetch="http://basex.org/modules/fetch";
  declare namespace file="http://expath.org/ns/file";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace rest="http://exquery.org/ns/restxq";
  declare namespace rerr="http://exquery.org/ns/restxq/error";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace web="http://basex.org/modules/web";
  declare namespace xhtml="http://www.w3.org/1999/xhtml";
  declare namespace xslt="http://basex.org/modules/xslt";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:~
 : RESTXQ functions for the public Biblio interface.
 :
 : @author Ashley M. Clark, for Digital Humanities Quarterly
 : Created 2018
 :)


(:  VARIABLES  :)
  declare variable $dbrx:get-metadata :=
    map {
      'contributors': 
          function($record as node()) as xs:string* {
            for $contributor in $record/(dbib:author|dbib:editor|dbib:translator|dbib:creator)
            return $contributor/normalize-space(.)
          },
      'citation':
          function($record as node()) as node() {
            dbfx:make-citation($record)
          },
      'date': 
          function($record as node()) as xs:string* {
            ($record/dbib:date)[1]/normalize-space(.)
          },
      'format': 
          function($record as node()) as xs:string* {
            let $formatGi := $record/local-name()
            return lower-case(replace($formatGi, '([A-Z])', ' $1'))
          },
      'id': 
          function($record as node()) as xs:string* {
            $record/@ID/data(.)
          },
      'title': 
          function($record as node()) as xs:string* {
            $record/dbib:title/normalize-space(.)
          }(:,
      'series-title': 
          function($record as node()) as xs:string {
            
          }:)
    };
  declare %private variable $dbrx:header :=
    <header>
      <h1>
        <a href="{dbfx:make-web-url('/dhq/biblio')}">DHQ Bibliographic Records</a></h1>
      <div><!-- TBD: navigation bar --></div>
    </header>;
  declare variable $dbrx:metadata-serialization-map :=
    map {
      'contributors'  : map {
        'heading' : <th>Authors, editors, and contributors</th>,
        'get-cell': function($record as node()) as node() {
                      let $contributors :=
                        for $contributor in $dbrx:get-metadata('contributors')($record)
                        return <li>{ $contributor }</li>
                      return
                        <td>
                          <ul>{ $contributors }</ul>
                        </td>
                    }
        },
      'citation'      : map {
        'heading' : <th>Citation</th>,
        'get-cell': function($record as node()) as node() {
                      <td>{ $dbrx:get-metadata('citation')($record) }</td>
                    }
        },
      'date'          : map {
        'heading' : <th class="cell-min">Date</th>,
        'get-cell': function($record as node()) as node() {
                      <td class="cell-min cell-centered">{ $dbrx:get-metadata('date')($record) }</td>
                    }
        },
      'format'        : map {
        'heading' : <th class="cell-centered">Format</th>,
        'get-cell': function($record as node()) as node() {
                      <td class="cell-centered">{ $dbrx:get-metadata('format')($record) }</td>
                    }
        },
      'id'            : map {
        'heading' : <th class="cell-min cell-centered">Identifier</th>,
        'get-cell': function($record as node()) {
                      <td class="cell-min cell-centered">{ $dbrx:get-metadata('id')($record) }</td>
                    }
        },
      'title'         : map {
        'heading' : <th>Title</th>,
        'get-cell': function($record as node()) as node() {
                      <td>{ $dbrx:get-metadata('title')($record) }</td>
                    }
        },
      'series-title'  : map {
        'heading' : <th>Series title</th>
        }
    };


(:  RESTXQ FUNCTIONS  :)

  declare
    %rest:GET
    %rest:path('/dhq/assets/{$filename=.+}')
  function dbrx:assets($filename as xs:string) {
    try {
      let $relPath := concat('assets/',$filename)
      let $absPath := concat(file:base-dir(),$relPath)
      let $file := fetch:binary($absPath)
      let $contentTypeHeader :=
        <http:header name="Content-Type" value="{fetch:content-type($absPath)}"/>
      return
        wpi:build-response('200', $contentTypeHeader, $file)
    } catch * {
      dbrx:send-404-response()
    }
  };
  
          (: TODO: actual web interface :)
  declare
    %rest:GET
    %rest:path('/dhq/biblio/{$id}')
  function dbrx:retrieve-entry($id as xs:string) {
    web:redirect(concat('/dhq/biblio/api/',$id))
  };
  
  
  (:  API ENDPOINTS  :)
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio/api')
    %rest:query-param('sort', '{$sort}', 'identifier')
    %rest:query-param('keywords', '{$keywords}', '')
    %rest:query-param('title', '{$titles}', '')
    %rest:query-param('contributor', '{$contributors}', '')
    %rest:query-param('fields', '{$fields}', '')
    %rest:query-param('limit', '{$limit}', '20')
    %rest:query-param('page', '{$page}', '1')
    %rest:query-param('method', '{$method}', 'xhtml')
    %output:indent('no')
  function dbrx:get-bibliography-set($sort as xs:string, $keywords as xs:string*, $titles as xs:string*, 
      $contributors as xs:string*, $fields as xs:string*, $limit as xs:integer, $page as xs:integer, 
      $method as xs:string) as item()+ {
    let $matchedSet :=
      let $biblioPublic := dbfx:bibliographic-records()
      return
        dbfx:get-biblio-results($biblioPublic, $sort, $keywords, $titles, $contributors)
    let $useSubset := wpi:reduce-to-subset($matchedSet, $page, $limit)
    let $returnSet := dbrx:serialize-results($useSubset, $fields, $method)
    let $restResponse :=
      dbrx:set-response-headers($useSubset, $limit, $page, $method)
    return
      ( $restResponse, $returnSet )
  };
  
  
  declare
    %rest:GET
    %rest:path('/dhq/biblio/api/{$id}')
    %rest:query-param('method', '{$method}', 'xml')
  function dbrx:retrieve-entry($id as xs:string, $method as xs:string) {
    let $match := dbfx:bibliographic-records()[@ID eq $id]
    return
      if ( exists($match) ) then 
        switch ($method)
          case 'json' return (
            dbrx:set-response-serialization('text/json'),
            dbrx:serialize-set-as-json($match)
          )
          default return $match
      else
        dbrx:send-404-response()
  };



(:  SUPPORT FUNCTIONS  :)
  
  
  declare %private function dbrx:get-html-item-for-index($item as node(), $selected-fields as xs:string+) {
    let $id := $item//@ID/data(.)
    return
      <tr>
        {
          for $field in $selected-fields
          let $fieldEntry := $dbrx:metadata-serialization-map($field)
          return
            if ( map:contains($fieldEntry, 'get-cell') ) then
              $fieldEntry('get-cell')($item)
            else <td>N/a</td>
        }
        <td class="cell-min cell-centered"><a href="{dbfx:make-web-url('/dhq/biblio/'||$id)}">complete entry</a></td>
      </tr>
  };
  
  
  declare %private function dbrx:make-link-header($limit as xs:integer, $page as xs:integer, 
      $total-results as xs:integer) as node()? {
    let $totalPages := xs:integer(ceiling($total-results div $limit))
    let $requestParams :=
      let $mapEntries :=
        for $param in request:parameter-names()
        where not($param = ('page', 'limit'))
        return 
          map:entry($param, request:parameter($param))
      return map:merge($mapEntries)
    return
      wpi:make-link-header($limit, $page, $totalPages, "/dhq/biblio/api", $requestParams)
  };
  
  
  declare %private function dbrx:make-results-table($xml-results as node()*, $selected-fields as xs:string+) {
    <table>
      <thead>
        <tr>
          {
            for $field in $selected-fields[. = map:keys($dbrx:metadata-serialization-map)]
            return
              $dbrx:metadata-serialization-map($field)('heading')
          }
          <th class="cell-min">XML record</th>
        </tr>
      </thead>
      <tbody>
        {
          for $record in $xml-results
          return dbrx:get-html-item-for-index($record, $selected-fields)
        }
      </tbody>
    </table>
  };
  
  
  declare %private function dbrx:send-404-response() as item()* {
    let $headers := (
      <http:header name="Content-Language" value="en"/>,
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    )
    let $message :=
      <p xmlns="http://www.w3.org/1999/xhtml">The requested page is not available.</p>
    let $xhtml := dbfx:make-xhtml($message, $dbrx:header, 'Not Found')
    return wpi:build-response('404', $headers, $xhtml)
  };
  
  
  declare function dbrx:serialize-results($results as node()*, $fields as xs:string*, $method as xs:string) {
    let $allFields := for $parameter in $fields
                      return tokenize(normalize-space($parameter), '\s')
    let $useFields := 
      if ( count($fields) ge 1 and exists($allFields[. = map:keys($dbrx:metadata-serialization-map)]) ) then 
        $allFields[. = map:keys($dbrx:metadata-serialization-map)]
      else
        ('title', 'contributors', 'date', 'format')
    return
      switch ($method)
        case 'xml' return
          dbrx:serialize-set-as-xml($results)
        case 'json' return
          dbrx:serialize-set-as-json($results)
        default return
          dbrx:make-results-table($results, $useFields)
  };
  
  
  declare %private function dbrx:serialize-set-as-xml($results as node()*) {
    if ( count($results) gt 1 ) then
      <BiblioSet xmlns="http://digitalhumanities.org/dhq/ns/biblio">
        { $results }
      </BiblioSet>
    else $results
  };
  
  
  declare %private function dbrx:serialize-set-as-json($results as node()*) {
    let $xml := dbrx:serialize-set-as-xml($results)
    let $pseudojson :=
      xslt:transform($xml, doc("transforms/simple-json-entries.xsl"))
    return
      xml-to-json($pseudojson)
  };
  
  
  declare %private function dbrx:serialize-set-as-html() {
    
  };
  
  
  declare %private function dbrx:set-response-headers($results as node()*, $limit as xs:integer, 
      $page as xs:integer, $method as xs:string) {
    (: Create HTTP headers. :)
    let $linkHeader := dbrx:make-link-header($limit, $page, count($results))
    let $corsHeader := $wpi:accessHeader
    let $restResponse := wpi:build-response('200', ($linkHeader, $corsHeader))
    return
      dbrx:set-response-serialization($method, $restResponse)
  };
  
  
  declare function dbrx:set-response-serialization($serialization-type as xs:string) as node() {
    dbrx:set-response-serialization($serialization-type, ())
  };
  
  
  declare function dbrx:set-response-serialization($serialization-type as xs:string, 
      $response as element()?) as node() {
    let $mediaType :=
      if ( $serialization-type = ('html', 'json', 'text', 'xhtml', 'xml') ) then
        concat('text/', $serialization-type)
      else if ( matches($serialization-type, "(text|application)/(html|json|text|xhtml|xml)") ) then
        $serialization-type
      else 'text/text'
    return
      <rest:response>
        <output:serialization-parameters>
          <output:media-type value='{$mediaType}'/>
        </output:serialization-parameters>
        { 
          if ( $response ) then $response/node() else ()
        }
      </rest:response>
  };
