 
module namespace b = "http://wendellpiez.com/ns/biblio";

declare option db:chop 'no';

(: declare variable $sk:frankensteinLMNL := db:open("LMNL-library","Frankenstein.xlmnl"); :)

declare variable $sk:dhqArticles := sk:dhq-articles(); 

(:'db:open('DHQ-articles')':)

declare variable $b:testDoc := document {
  <test>
    <div>
      <head>Test doc</head>
      <p>Testing.</p>
      <p>Testing testing...</p>
      <div>
        <p>Extra testing.</p>
      </div>
      <p>Testing.</p>
      <p>Testing testing...</p>
      <empty/>
      <empty/>
      <empty/>
      <empty/>
      <empty/>
      <empty/>
    </div>
  </test> };


declare function sk:docsketch-html-head($title as xs:string) as element(head)
{
  <head>
    <title>{ $title }</title>
    <link rel="stylesheet" type="text/css" href="/static/style.css"/>
    (:<link rel="stylesheet" type="text/css" href="/static/docsketch-tinyText.css"/>:)
  </head>
};

declare function sk:docsketch-masthead($title as xs:string) as element(div)
{
  <div class="masthead">
    <!-- <div class="logo"><img src="/static/scattered-peas.svg" width="65"/></div> -->
    <h1>{ $title }</h1>
  </div>
};


(:declare variable $b:localDHQ := 'file://F:/Data/DHQ/SVN/dhq'; (\: file://c:/Projects/DHQ/SVN/dhq :\)

declare variable $sk:dhq-tocXML       := $sk:localDHQ || '/trunk/toc/toc.xml';
declare variable $sk:dhq-articlesPath := $sk:localDHQ || '/trunk/articles/';

declare function sk:dhq-articles() as document-node()* {
  let $toc          := doc($sk:dhq-tocXML)
  for $article in distinct-values( $toc//item/@id ) !
    ( $sk:dhq-articlesPath || . || '/' || . || '.xml')
  return (# db:chop false #) { doc($article) }
};
:)

(: PMC-OA functionality
   ^^^^^^^^^^^^^^^^^^^^ :)

(:declare function sk:pmc-oa-request-form($promptQuery as xs:string) as element(form) {
  <form method="post" action="request.html">
    <h4>New query:</h4>
    { () (\: <input name="query" size="120" value="{ $promptQuery }"/> :\) }
    <textarea rows="5" cols="50" name="query" value="{ $promptQuery }">
      { $promptQuery }
    </textarea>
    <input type="submit"/>
    <p>The documents containing the query results will be displayed. The database currently contains { count(db:open('PMCOA-selection'))} documents.</p>
    <h4>Examples</h4>
    <div class="queryExample">
      <p>All artitle titles containing 'human' (case-insensitive)</p>
      <pre>//article-meta//article-title[matches(.,'human','i')]</pre>
    </div>
    <div class="queryExample">
      <p>All math (mml:math|m:math)</p>
      <pre>//*:math</pre>
    </div>
    <div class="queryExample">
      <p>Figs in documents with 12 or more&#xA0;<code>fig</code>&#xA0;elements</p>
      <pre>//fig[count(root()//fig) ge 12]</pre>
    </div>
    <div class="queryExample">
      <p><code>body</code>&#xA0;elements with only &#xA0;<code>supplementary-material</code> and nothing else</p>
      <pre>//body[empty(* except supplementary-material)]</pre>
    </div>
  </form>
};:)

(:declare function sk:execute-pmc-query($query as xs:string) as document-node()* {
  let $nodes :=
    try     { xquery:eval($query, map{ '' : db:open('PLoS_ONE')}) }
    catch * { document { <EXCEPTION>Query failure</EXCEPTION> } }
  return
  
  $nodes/root()
};
:)
(: DHQ functionality
   ^^^^^^^^^^^^^^^^^^^^ :)

(:declare function sk:dhq-query-request-form($promptQuery as xs:string)
  as element(form) {
  <form method="post" action="request.html">
    <h4>New query:</h4>
    { () (\: <input name="query" size="120" value="{ $promptQuery }"/> :\) }
    <textarea rows="5" cols="50" name="query" value="{ $promptQuery }">
      { $promptQuery }
    </textarea>
    <input type="submit"/>
    <!-- p>The documents containing the query results will be displayed. The database currently contains { count($sk:dhqArticles)} documents. Namespace prefixes are bound as follows:</p -->
    <dl>
    <dt>unprefixed</dt>
    <dd><code>http://www.tei-c.org/ns/1.0</code></dd>
    <dt>prefix&#xA0;<code>dhq</code></dt>
    <dd><code>http://www.digitalhumanities.org/ns/dhq</code></dd>
    </dl>
    <h4>Examples</h4>
    <div class="queryExample">
      <p>Return all fourth figures in their documents. (Only documents with four figures or more will be returned.)</p>
      <pre>/descendant::figure[4]</pre>
    </div>
    <div class="queryExample">
      <p>'floatingText' elements</p>
      <pre>//floatingText</pre>
    </div>
    <div class="queryExample">
      <p>Pieces with exactly five 'div' elements in the body</p>
      <pre>//body[count(div) eq 5]</pre>
    </div>
    <div class="queryExample">
      <p>Published in Vol 1, no 1</p>
      <pre>//publicationStmt
  [idno[@type='volume']='001']
  [idno[@type='issue']='1']</pre>
    </div>
    <div class="queryExample">
      <p>All documents (for prompting)</p>
      <pre>/*</pre>
    </div>
    
  </form>
};
:)
(: Returning arbitrary items, not just documents, so we can handle XQuery
   in general. :)
(:declare function sk:execute-dhq-query($query as xs:string) as item()* {
  let $ns-query := (
  'declare default element namespace "http://www.tei-c.org/ns/1.0";&#xA;'    ||
  'declare namespace dhq = "http://www.digitalhumanities.org/ns/dhq";&#xA; ' ||
   $query )
  return
    try     { xquery:eval($ns-query, map{ '' : $sk:dhqArticles }) }
    catch * { document { <EXCEPTION>Query failure</EXCEPTION> } }
};
:)

(:declare function sk:dhq-query-graph-xslt($query as xs:string) as xs:string {
  (\: Dynamically constructing an XSLT containing the query :\)
  '<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="' || $sk:requestPipelines/request[@name='DHQ-graph']/xslt/sk:fetch-xslt(.) || '"/>
  
  <xsl:param name="querySet" select="' || $query || '"/>
    
    
  </xsl:stylesheet>'
};
:)
(: WBNLM stuff :)

(:declare function sk:wbnlm-query-request-form($promptQuery as xs:string) as element(form) {
  <form method="post" action="request.html">
    <h4>New query:</h4>
    { () (\: <input name="query" size="120" value="{ $promptQuery }"/> :\) }
    <textarea rows="5" cols="50" name="query" value="{ $promptQuery }">
      { $promptQuery }
    </textarea>
    <input type="submit"/>
    <p>The documents containing the query results will be displayed. The database currently contains { count(db:open('WBNLM-Samples'))} documents.</p>
    <h4>Examples</h4>
    <div class="queryExample">
      <p>All book or section titles containing 'human' (case-insensitive)</p>
      <pre>//(book-title|title)[matches(.,'human','i')]</pre>
    </div>
    <div class="queryExample">
      <p>All math (mml:math|m:math)</p>
      <pre>//*:math</pre>
    </div>
    <div class="queryExample">
      <p>Figs in documents with 12 or more&#xA0;<code>fig</code>&#xA0;elements</p>
      <pre>//fig[count(root()//fig) ge 12]</pre>
    </div>
    <div class="queryExample">
      <p><code>body</code>&#xA0;elements with only &#xA0;<code>supplementary-material</code> and nothing else</p>
      <pre>//body[empty(* except supplementary-material)]</pre>
    </div>
  </form>
};:)

(:declare function sk:execute-wbnlm-query($query as xs:string) as document-node()* {
  let $nodes :=
    try     { xquery:eval($query, map{ '' : db:open('WBNLM-Samples')}) }
    catch * { document { <EXCEPTION>Query failure</EXCEPTION> } }
  return
  
  $nodes/root()
};:)

(:declare function sk:wbnlm-query-graph-xslt($query as xs:string) as xs:string {
  (\: Dynamically constructing an XSLT containing the query :\)
  '<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
 
  xmlns:dsk="http://wendellpiez.com/docsketch/xslt/util"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="' || $sk:requestPipelines/request[@name='WBNLM-graph']/xslt/sk:fetch-xslt(.) || '"/>
  
  <xsl:param name="querySet" select="' || $query || '"/>
    
    
  </xsl:stylesheet>'
};:)



(: UTILITY STUFF :)

declare variable $sk:xsltPath :=
'file:/C:/Users/Wendell/Documents/GitHub/DocSketch/xslt';
(:  'file:/D:/Work/Projects/PublicProjects/DocumentSketch/BaseX/xslt/' :)

declare function b:fetch-xslt($filename as xs:string) as xs:string {
  $sk:xsltPath || '/' || $filename };


declare function b:and-sequence($items as item()*) as xs:string {
  string-join(

    let $c := count($items)
    for $i at $p in $items
    return
      ( if ($p gt 1) then
        if ($p eq $c) then ' and ' else ', '
      else '',
      string($i)
     ),
   '')
  
};

(: recursively processes the XSLT pipeline as a sequence of XSLT references (passed in as a list of strings) :)
declare function b:run-xslt-pipeline($source as document-node(),
                                       $stylesheets as xs:string*,
                                       $params as map(*)? )
                 as document-node() {
   if (empty($stylesheets)) then $source
   else
      let $intermediate := sk:run-xslt($source, $stylesheets[1], $params)
      return sk:run-xslt-pipeline($intermediate, remove($stylesheets,1),$params)
};

(: for robustness of execution, to catch Saxon errors (to safely message them) and avoid BaseX runtime errors :)
declare function b:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { xslt:transform($source, $stylesheet, $params ) }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};

