xquery version "3.1";

  declare boundary-space preserve;
(:  LIBRARIES  :)
(:  NAMESPACES  :)
  declare default element namespace "http://www.tei-c.org/ns/1.0";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
(:  OPTIONS  :)
  declare option output:indent "no";

(:~
  Insert new <keywords> into DHQ articles.
  
  @author Ash Clark
  @since 2023
 :)
 
(:  VARIABLES  :)
  declare variable $article-path := "../../articles/";
  declare variable $keywords := doc('../xml/keywordsOutput.xml');

(:  FUNCTIONS  :)
  

(:  MAIN QUERY  :)

for $newKeywordGroup in $keywords//keywords[term]
let $articleFilename := $newKeywordGroup/@corresp/data(.)
let $articleId := substring-before($articleFilename, '.xml')
(: Strip off the @corresp. :)
let $moddedKeywords :=
  <keywords scheme="#dhq_keywords">{ $newKeywordGroup/node() }</keywords>
let $articleDocPath := concat($article-path,$articleId,'/',$articleFilename)
return
  (: Skip articles with CDATA! :)
  if ( contains(unparsed-text($articleDocPath), '![CDATA[') ) then ()
  else if ( doc-available($articleDocPath) ) then
    let $articleDoc := doc($articleDocPath)
    let $oldKeywordGroup := $articleDoc//keywords[@scheme eq '#dhq_keywords']
    let $hasExistingKeywords :=
      exists($oldKeywordGroup//item[normalize-space() ne ''])
    return
      if ( $hasExistingKeywords ) then
        insert nodes ( $moddedKeywords, 
          text { "
          " },
          comment { " Keywords below were retained for proofing. " },
          text { "
          " } ) 
          before $oldKeywordGroup
      else if ( exists($oldKeywordGroup) ) then
        replace node $oldKeywordGroup with $moddedKeywords
      else if ( exists($articleDoc//textClass) ) then
        insert node $moddedKeywords as first into $articleDoc//textClass
      else if ( exists($articleDoc//profileDesc) ) then
        insert node
      <textClass>
          { $moddedKeywords }
      </textClass> 
          as last into $articleDoc//profileDesc
      else error((), "Missing XML structure for "||$articleId)
  else error((), "File "||$articleId||" is missing")
