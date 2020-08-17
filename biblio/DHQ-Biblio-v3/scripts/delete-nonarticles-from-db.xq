xquery version "3.1";

(: NAMESPACES :)
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace db="http://basex.org/modules/db";
  declare namespace update="http://basex.org/modules/update";

(:~
 : Create or maintain a database of DHQ articles.
 :
 : @author Ashley M. Clark
 : Created 2018-04-05.
 :)

(: OPTIONS :)
  declare option db:autooptimize 'true';
  declare option db:chop 'false';
  declare option db:stripns 'false';
  declare option db:updindex 'true';
  declare option db:skipcorrupt 'true';
  
(: VARIABLES :)
  declare variable $articles-path external := '/Users/ashleyclark/DHQ/dhq/articles';
  declare variable $db-name := 'dhq-articles';
  declare variable $db-opts := map {
    'autooptimize'  : true(),
    'chop'          : false(),
    'updindex'      : true(),
    'skipcorrupt'   : true()
  };
  declare variable $skip-paths := (
    'customXml',
    'docProps',
    'META-INF',
    'templates',
    'test_suite',
    'word'
  );


(: FUNCTIONS :)
  (: Delete a file from the database. :)
  declare updating function local:rm($path as xs:string) {
    db:delete($db-name, $path)
  };
  
  (: Escape special characters in a string representing a file or directory path, 
    intended for use in a regular expression. :)
  declare function local:replace-for-regex($text as xs:string) {
    replace($text, '([\[\]\.])','\$1')
  };


(: MAIN QUERY :)

(: If the database doesn't exist yet, output a message but otherwise do nothing. :)
if ( not(db:exists($db-name)) ) then
  update:output("Run dbmaker_dhq-articles.bxs to create database "||$db-name||".")
(: If the database has already been created, do some maintenance on it. :)
else
  let $fileList := db:list($db-name)
  let $mergeSkippable := string-join($skip-paths,'|')
  let $regexSkippable := concat('^(',local:replace-for-regex($mergeSkippable),')')
  return
  (
    update:output("Database '"||$db-name||"' found.")
    ,
    (: Delete any files matching any of the $skip-paths defined above. :)
    for $skippable in $skip-paths
    let $regexFile := concat('^',local:replace-for-regex($skippable))
    return 
      if ( exists($fileList[matches(.,$regexFile)]) ) then
      (
        update:output("Deleting resources matching path '"||$skippable||"'."),
        local:rm($skippable)
      )
      else ()
    ,
    (: Delete any other non-standard DHQ article files not covered by $skip-paths. :)
    for $file in $fileList
    let $fullPath := concat($db-name,'/',$file)
    (: If the file matches one of $skip-paths, we know it has already been deleted,
      and nothing more needs to be done. :)
    let $hasBeenDeleted := matches($file, $regexSkippable)
    return
      if ( $hasBeenDeleted ) then ()
      else
        (: Delete files that don't match DHQ's 6-number file-naming system, or which 
          start with '9'. :)
        let $hasAtypicalFilename := not(matches($file,'/[0-8]\d{5,5}\.xml$'))
        (: Delete files that (perhaps erroneously) are missing a DHQ article identifier. :)
        let $hasNoArticleId := 
          let $idno := doc($fullPath)//tei:idno[@type eq 'DHQarticle-id']
          return
            not(exists($idno)) or exists($idno[normalize-space(.) eq ''])
        return 
          if ( $hasAtypicalFilename or $hasNoArticleId ) then
          (
            update:output("Deleting resource matching path '"||$file||"'."),
            local:rm($file)
          )
          else ()
  )
