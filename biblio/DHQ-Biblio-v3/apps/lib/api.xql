xquery version "3.1";

module namespace wpi="http://www.wwp.northeastern.edu/ns/api/functions";
(:  NAMESPACES  :)
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace rest="http://exquery.org/ns/restxq";
  declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
  A library of functions to simplify the development of an XQuery API.

  @author Ashley M. Clark, Northeastern University Women Writers Project
  @version 1.3
  @see https://wwp.northeastern.edu/utils/lib/content/api.xql

  2019-10-04, v1.3: Added a few non-sorting articles to wpi:get-sortable-string().
    Added xqDoc descriptions of functions.
  2018-12-03, v1.2: Declared previously-undeclared namespaces (e.g. "http"). The 
    declaration for "map" is commented out, since eXist has the prefix bound to a 
    different namespace. Change the eXist-specific map:new() to XQuery 3.1's 
    map:merge().
  2018-05-29: Added the access control header as a global variable. Restricted
    types on function parameters. Updated wpi:get-sortable-string() with 
    additional words not to sort on.
  2016-08-16: Created this file using functions and logic from the Cultures of 
    Reception XQuery library.
  :)

(:
  VARIABLES
 :)
  
  declare variable $wpi:accessHeader := 
    <http:header name="Access-Control-Allow-Origin" value="*"/>;


(:
  FUNCTIONS
 :)
  
  (:~
    Using the EXPath HTTP Client, construct a response to an HTTP request.
    
    @param statusCode a string representing a three-digit HTTP status code
    @param headerParts zero or more HTTP headers, in the EXPath HTTP XML format
    @param output any outputs to be returned in the response
    @return a sequence of items for the HTTP response
   :)
  declare function wpi:build-response($statusCode as xs:string, $headerParts as node()*, 
     $output as item()*) as item()* {
    let $header :=
      <rest:response>
        <http:response status="{$statusCode}">
          { $headerParts }
        </http:response>
      </rest:response>
    return ( $header, $output )
  };
  
  (:~
    Using the EXPath HTTP Client, construct a response to an HTTP request.
    
    @param statusCode a string representing a three-digit HTTP status code
    @param headerParts zero or more HTTP headers, in the EXPath HTTP XML format
    @return an XML description of the HTTP response
   :)
  declare function wpi:build-response($statusCode as xs:string, 
     $headerParts as node()*) as item() {
    wpi:build-response($statusCode, $headerParts, ())
  };
  
  (:~
    Using the EXPath HTTP Client, construct a response to an HTTP request.
    
    @param statusCode a string representing a three-digit HTTP status code
    @return an XML description of the HTTP response
   :)
  declare function wpi:build-response($statusCode as xs:string) as item() {
    wpi:build-response($statusCode, (), ())
  };
  
  (:~
    Construct a URL using a base URI and any given query parameters.
    
    @param linkBase a string representing the URI to be used before any additional query parameters.
    @param queryParams key-value pairs to use when constructing the URL
    @return a URL in string form
   :)
  declare function wpi:get-query-url($linkBase as xs:string, $queryParams as 
     map(xs:string, item()*)) as xs:string {
    let $paramBits :=
      for $key in map:keys($queryParams)
      let $seq := map:get($queryParams,$key)
      return 
        for $value in $seq
        return concat($key,'=',$value)
    let $queryStr :=  if ( count($paramBits) ge 1 ) then 
                        concat('?',string-join($paramBits,'&amp;'))
                      else ''
    return concat($linkBase, $queryStr)
  };
  
  (:~
    Given a string, create a version for alphabetical sorting by lower-casing the 
    characters and removing articles at the beginning of the string.
    
    @param str the string
    @return a version of the string suitable for alphabetical sorting
   :)
  declare function wpi:get-sortable-string($str as xs:string) as xs:string {
    replace(lower-case($str), "^((the|an|a|la|le|el|lo|las|les|los|de|del|de la) |l')", '')
  };
  
  (:~
    Create an HTTP 'Link' header, formatted according to RFC 5988. For use with the 
    EXPath HTTP client.

    @param limit the maximum number of results per page
    @param currentPage a number representing the requested "page" of results
    @param totalPages how many pages there are for this query in total, using $limit
    @param linkBase a string representing the URI to be used before any additional query parameters.
    @param queryParams key-value pairs to use when constructing the URL
    @return an XML serialization of an HTTP Link header
   :)
  declare function wpi:make-link-header($limit as xs:integer, $currentPage as xs:integer, 
     $totalPages as xs:integer, $linkBase as xs:string, 
     $queryParams as map(xs:string, item()*)) as node()? {
    let $limitParam := map:entry('limit',$limit)
    let $paramSeq := if ( empty($queryParams) ) then ($limitParam)
                     else ($queryParams, $limitParam)
    let $first := if ( $currentPage gt 1 ) then
                   let $page := map:entry('page','1')
                   let $paramSeqPlusPage := ($paramSeq, $page)
                   let $url := wpi:get-query-url($linkBase, map:merge($paramSeqPlusPage))
                   return concat('<',$url,'>; rel="first"')
                 else ()
    let $prev := if ( $currentPage gt 1 and $currentPage le $totalPages ) then
                   let $page := map:entry('page', $currentPage - 1)
                   let $paramSeqPlusPage := ($paramSeq, $page)
                   let $url := wpi:get-query-url($linkBase, map:merge($paramSeqPlusPage))
                   return concat('<',$url,'>; rel="prev"')
                 else ()
    let $next := if ( $currentPage lt $totalPages ) then
                   let $page := map:entry('page', $currentPage + 1)
                   let $paramSeqPlusPage := ($paramSeq, $page)
                   let $url := wpi:get-query-url($linkBase, map:merge($paramSeqPlusPage))
                   return concat('<',$url,'>; rel="next"')
                 else ()
    let $last := if ( $totalPages gt 0 and $currentPage ne $totalPages ) then
                   let $page := map:entry('page',$totalPages)
                   let $paramSeqPlusPage := ($paramSeq, $page)
                   let $url := wpi:get-query-url($linkBase, map:merge($paramSeqPlusPage))
                   return concat('<',$url,'>; rel="last"')
                 else ()
    let $linksVal := ( $first, $prev, $next, $last )
    return 
      if ( not(empty($linksVal)) ) then 
        <http:header name="Link" value="{string-join($linksVal,', ')}"/>
      else ()
  };
  
  (:~
    Given a sequence, return a subset determined by the number of results and 
    the page requested.

    @param set a sequence of zero or more results
    @param page a number representing the requested "page" of results
    @param limit the maximum number of results per page
    @return a subset of $set
   :)
  declare function wpi:reduce-to-subset($set as item()*, $page as xs:integer, $limit as xs:integer) as item()* {
    let $intPage := if ( $limit eq 0 ) then 0 else $page
    let $totalRecords := count($set)
    let $subSet := 
      if ( $limit eq 0 ) then
        ()
      else if ( $limit gt 0 ) then
        let $range := if ( $intPage gt 0 ) then 
                        (($intPage - 1) * $limit) + 1
                      else 1
        return subsequence($set,$range,$limit)
      else $set
    return $subSet
  };
