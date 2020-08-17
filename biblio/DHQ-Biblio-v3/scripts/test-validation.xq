xquery version "3.1";

  declare boundary-space preserve;
(:  LIBRARIES  :)
  import module namespace dbqx="http://digitalhumanities.org/dhq/ns/biblio-qa/rest" 
    at "../apps/biblio-workbench.xq";
  import module namespace mrng="http://digitalhumanities.org/dhq/ns/meta-relaxng"
    at "../apps/lib/relaxng.xql";
(:  NAMESPACES  :)
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace xslt="http://basex.org/modules/xslt";
(:  OPTIONS  :)
  declare option output:indent "no";
  declare option output:method "xml";

(:~
  
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  2019
 :)
 
(:  VARIABLES  :)

(:  FUNCTIONS  :)


(:  MAIN QUERY  :)

let $record := doc('/biblio-working/records/antonijević2014/antonijević2014.xml')/*
(:let $sortingXsl := mrng:generate-sorting-stylesheet($record)
let $sortedRecord := xslt:transform($record, $sortingXsl):)
let $sortedRecord := dbqx:arrange-to-schema($record)
let $validationResults := dbqx:validate($sortedRecord)
return
  <report>
    <validation>{ 
      if ( $validationResults(1) eq true() ) then <msg>Valid</msg>
      else
        let $errors := $validationResults(2)
        return
          for $index in (1 to array:size($errors))
          let $error := $errors($index)
          return ('
      ', <msg>{ $error }</msg>, ' ')
    }</validation>
  </report>
  (:<report>
    <xsl>{ $sortingXsl }</xsl>
    <doc>{ $sortedRecord }</doc>
    <validation>{ 
      if ( $validationResults(1) eq true() ) then <msg>Valid</msg>
      else
        let $errors := $validationResults(2)
        return
          for $index in (1 to array:size($errors))
          let $error := $errors($index)
          return ('
      ', <msg>{ $error }</msg>, ' ')
    }</validation>
  </report>:)
