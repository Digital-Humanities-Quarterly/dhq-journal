xquery version "3.1";

(:~
 : Generate a table of DHQ article content in plaintext, with limited metadata. To run this
 : script, follow the instructions for "The general XQuery transformation scenario" at
 : https://github.com/NEU-DSG/wwp-public-code-share/blob/main/docs/setup-xquery.md
 : 
 : ~~~~~
 : 
 : ORIGINAL HEADER:
 : 
 : A script to strip out the text from a TEI document, while retaining some metadata 
 : from the header. While intended for use with TEI created by the Women Writers 
 : Project, it can be used on other documents with a little tweaking.
 :
 : The $ELEMENTS variable gives control over which TEI elements should be output via 
 : XPath. To use morphadorned XML, change $is-morphadorned to true().
 :
 : @return tab-delimited text
 :
 : @author Ashley M. Clark, Northeastern University Women Writers Project
 : @see https://github.com/NEU-DSG/wwp-public-code-share/tree/main/fulltext
 : @version 2.5
 :
 : Changelog:
 :  2020-10-02: v.2.5. Updated GitHub link to use the new default branch "main".
 :  2020-01-28: v.2.4. Made local:move-anchors() accept empty sequences.
 :  2019-07-26: v.2.3. Added MIT license. Removed "werr" namespace declaration.
 :  2019-03-19: v.2.2. In order to remove the dependency on Saxon EE, I removed the 
 :              dynamic function call. Instead, an explicit call to 
 :              wft:anchor-notes() has been commented out. To use the feature
 :              $move-notes-to-anchors, follow the instructions for 
 :              local:anchor-notes() below.
 :  2019-02-14: v.2.1. Merged in sane XPaths from a divergent git branch (see 
 :              2019-01-31 for details). Changed variable $text to $teiDoc.
 :  2019-02-01: v.2.0. Updated to XQuery version 3.1, which allows modules
 :              (libraries) to be dynamically loaded. Added the external variable 
 :              $move-notes-to-anchors, which moves <wwp:note>s from the <hyperDiv> 
 :              to their anchor in the text itself. For backwards compatibility with 
 :              older versions of this script, this new option is off by default. 
 :              The process requires XQuery Update to be enabled by the XQuery 
 :              processor. To make use of the new option, use Saxon EE with XQuery 
 :              Update and "Linked Tree" model turned on. Modified the indentation
 :              of the script for readability.
 :  2019-01-31: Use an easier XPath to select <text> elements (since
 :              all those that are not a child of <group> is the same
 :              set as all those that are a child of <TEI>).
 :  2018-12-20: v.1.4. Added link to GitHub.
 :  2018-12-01: Allow for outermost element of input document to be
 :              <teiCorpus> in addition to <TEI>. Thus the sequence of
 :              elements in $teiDoc may contain both <TEI> and
 :              <teiCorpus>, and to look for the non-metadata bits
 :              themselves we want to look for all <text> desendants,
 :              not just child of outermost element. However, we don't
 :              want to count a <text> more than once, so avoid nested
 :              <text> elements by ignoring those that are within a
 :              <group>. (Since <group> is definitionally a descendant
 :              of <text>, all those will aready be collected by
 :              catching the <text> that is the ancestor of the
 :              <group>.)
 :  2018-11-29: Bug fix (by SB on phone w/ AC): fix assignment of
 :              $header (to the <teiHeader> child of the outermost
 :              element, recorded in $teiDoc, rather than to the
 :              non-existant <teiHeader> child of the <TEI> child of
 :              the element recorded in $teiDoc).
 :  2018-06-21: v.1.3. Added the external variable $preserve-space, which determines 
 :              whether whitespace is respected in the input XML document (the 
 :              default), or if steps are taken to normalize whitespace and add 
 :              whitespace where it is implied (e.g. <lb>).
 :  2018-05-04: v.1.2. With Sarah Connell, added the external variable 
 :              $return-only-words for use when the header row and file metadata are 
 :              unnecessary. Added a default namespace and deleted "wwp:" prefixed 
 :              XPaths. Switched the Morphadorner variables from camel-cased words 
 :              to hyphen-separated. Fixed bug which eats text nodes that are all 
 :              whitespace. The bug occurs when $ELEMENTS2OMIT is used with Saxon 
 :              9.7+ (Oxygen XML Editor 19.0+).
 :  2017-08-03: Added function omit-descendants() to remove given named elements 
 :              from output.
 :  2017-08-01: Removed duplicate results when morphadorned XML includes split 
 :              tokens. Only unbroken tokens and the first split tokens are 
 :              processed  (`//w[not(@part) or @part[data(.) = ('N', 'I')]`).
 :  2017-07-12: v1.1. Added Morphadorner control, this header, and this changelog.
 :  2017-06-09: Fixed XPaths used to derive documents' publication date and author.
 :              Thanks to Thanasis for finding these bugs!
 :  2017-04-28: Moved script from amclark42/xdb-app-central to the
 :              NEU-DSG/wwp-public-code-share GitHub repository.
 :  2016-12-13: v1.0. Created.
 :
 : MIT License
 :
 : Copyright (c) 2019 Northeastern University Women Writers Project
 :
 : Permission is hereby granted, free of charge, to any person obtaining a copy
 : of this software and associated documentation files (the "Software"), to deal
 : in the Software without restriction, including without limitation the rights
 : to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 : copies of the Software, and to permit persons to whom the Software is
 : furnished to do so, subject to the following conditions:
 :
 : The above copyright notice and this permission notice shall be included in all
 : copies or substantial portions of the Software.
 :
 : THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 : IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 : FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 : AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 : LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 : OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 : SOFTWARE.
 :)

(:  IMPORTS  :)
  (:import module namespace wft="http://www.wwp.northeastern.edu/ns/fulltext" 
    at "fulltext-library.xql";:)
(:  NAMESPACES  :)
  declare default element namespace "http://www.tei-c.org/ns/1.0";
  declare namespace dhq="http://www.digitalhumanities.org/ns/dhq";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
(:  OPTIONS  :)
  declare option output:method "text";


(:  VARIABLES  :)
  declare variable $dhq-articles := 
    collection('../../articles/?select=*.xml;recurse=yes;on-error=ignore');
  declare variable $use-docs external := $dhq-articles;
  
  (: Set $return-only-words to 'true()' to remove the header row and file metadata 
    entirely. Only that file's words are returned. :)
  declare variable $return-only-words as xs:boolean external := false();
  (: The "preserve-space" parameter determines whether whitespace is introduced 
    around elements that normally imply whitespace, such as <lb>. The default is to 
    preserve whitespace as it appears in the input XML. :)
  declare variable $preserve-space as xs:boolean external := true();
  (: Set $move-notes-to-anchors to 'true()' in order to move <wwp:note>s close to 
    their anchors, making sure not to break up a word in doing so.
    IMPORTANT: In order to use this feature in oXygen, you will need to follow the 
    instructions for the function local:anchor-notes() below. :)
  declare variable $move-notes-to-anchors as xs:boolean external := false();


(:  FUNCTIONS  :)

  (: Wrapper function to call wft:anchor-notes(). In order to use the feature 
    $move-notes-to-anchors, you will need to do the following set-up once (but only 
    once):
      (1) make sure you have downloaded the XQuery file at
        https://raw.githubusercontent.com/NEU-DSG/wwp-public-code-share/master/fulltext/fulltext-library.xql ;
      (2) make sure the downloaded file is stored in the same location as this 
        script, and that it is named "fulltext-library.xql";
      (3) uncomment the import statement under "IMPORTS" above;
      (4) uncomment the line below that reads `wft:anchor-notes($xml)`, then comment 
        out or delete the line that reads `$xml`; and
      (5) use an XQuery processor that recognizes XQuery Update.
    To accomplish #2 in oXygen, use Saxon EE as your "transformer". Click on the 
    symbol next to "Saxon EE" to open the processor settings. Turn on the "linked 
    tree" model and XQuery Update. Turn off XQuery Update backups. :)
  declare function local:anchor-notes($xml as node()?) {
    if ( exists($xml) ) then
      (:wft:anchor-notes($xml):)
      $xml
    else $xml
  };
  
  (: Get the normalized text content of an element. :)
  declare function local:get-text($element as node()) as xs:string {
    replace($element, '\s+', ' ')
  };
  
  (: Use tabs to separate cells within rows. :)
  declare function local:make-cells-in-row($sequence as xs:string*) {
    string-join($sequence, '&#9;')
  };
  (: Separate each row with a newline. :)
  declare function local:make-rows-in-table($sequence as xs:string*) {
    string-join($sequence, '&#13;')
  };
  
  (: Remove certain named elements from within an XML fragment. :)
  declare function local:omit-descendants($node as node(), $element-names as xs:string*) as node()? {
    if ( empty($element-names) ) then $node
    else if ( $node[self::text()] ) then text { $node }
    else if ( $node[self::*]/local-name() = $element-names ) then ()
    else if ( $node[self::*] ) then
      element { $node/local-name() } {
        $node/@*,
        for $child in $node/node()
        return local:omit-descendants($child, $element-names)
      }
    else ()
  };



(:  MAIN QUERY  :)

let $corpus := 
  $use-docs/TEI[descendant::publicationStmt/date[@when]]
               [descendant::idno[@type eq 'DHQarticle-id']
                                [not(starts-with(., '9'))]]
let $headerRow := ('Article ID', 'Author(s)', 'Full Text')
let $allRows := 
  (
    if ( $return-only-words ) then ()
    else local:make-cells-in-row($headerRow),
    
    for $teiDoc in $corpus
    let $file := tokenize($teiDoc/base-uri(),'/')[last()]
    let $optionalMetadata :=
      if ( $return-only-words ) then ()
      else
        let $header := $teiDoc/teiHeader
        let $idno := 
          $header/fileDesc/publicationStmt/idno[@type eq 'DHQarticle-id']/data(.)
        let $authorSeq := 
          for $author in $header/fileDesc/titleStmt/dhq:authorInfo
          let $name := $author/dhq:author_name/normalize-space()
          let $affiliation := $author/dhq:affiliation/normalize-space()
          return concat($name,'; ',$affiliation)
        let $author := string-join($authorSeq, ' | ')
        return ( $idno, $author )
    (: Refine $teiDoc, ensuring that it contains a <TEI> element, and that notes 
      have been moved to their anchors (if requested). :)
    let $teiDoc :=
      if ( $move-notes-to-anchors ) then
        local:anchor-notes($teiDoc)
      else $teiDoc
    let $teiDoc := $teiDoc/descendant-or-self::TEI
  (: Change $ELEMENTS to reflect the elements for which you want full-text 
      representations. :)
    let $ELEMENTS := $teiDoc/text/body
  (: Below, add the names of elements that you wish to remove from within $ELEMENTS.
      For example, 
        ('castList', 'elision', 'figDesc', 'label', 'speaker')
  :)
    let $ELEMENTS2OMIT := ( 'head' )
    let $fulltext := 
      let $wordSeq := 
        for $element in $ELEMENTS
        let $abridged := local:omit-descendants($element, $ELEMENTS2OMIT)
        return local:get-text($abridged)
      let $wordSeparator := ' '
      return normalize-space(string-join(($wordSeq), $wordSeparator))
    (: The variable $optionalMetadata will be empty if $return-only-words is 'true()'. :)
    let $dataSeq := ( $optionalMetadata, $fulltext )
    order by $file
    return 
      if ( $fulltext ne '' ) then 
        local:make-cells-in-row($dataSeq)
      else ()
  )
return local:make-rows-in-table($allRows)
