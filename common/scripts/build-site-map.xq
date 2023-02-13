xquery version "3.1";

(:  LIBRARIES  :)
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace file="http://expath.org/ns/file";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace smap="http://apache.org/cocoon/sitemap/1.0";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
(:  OPTIONS  :)
  declare option output:indent "yes";
  declare option output:method "json";
  

(:~
  
  
  @author Ash Clark
  2023
 :)

(:  VARIABLES  :)
  declare variable $script-path := file:base-dir();
  declare variable $dhq-repo external := 
    file:parent($script-path) => file:parent();
  
  declare variable $dhq-repo-contents := file:list($dhq-repo, true());
  declare variable $slash := file:dir-separator();
  declare variable $sitemap := doc(concat($dhq-repo,'sitemap.xmap'));
  declare variable $dhqTOC := doc(concat($dhq-repo,'toc',$slash,'toc.xml'));
  declare variable $context external := 'dhq/';
  
  declare variable $sitemap-matches := 
    local:process-directory-contents($sitemap//smap:match);

(:  FUNCTIONS  :)
  
  declare function local:get-path($match as node()) {
    let $path := $match/@pattern/data(.)
    let $isRegex := exists($match[@type eq 'regexp'])
    return
      (: Handle plain filepaths. :)
      if ( not($isRegex) and not(contains($path, '*')) ) then
        $path
      else
        (: Change wildcards into regular expressions. :)
        let $regexPath :=
          if ( not($isRegex) ) then
            replace($path, '\.', '\\.')
            => replace('\*\*', '.+')
            => replace('\*', '[^/]*')
          else $path
        return $regexPath
  };
  
  declare function local:process-directory-contents($cocoon-matches as node()*) {
    for $match in $cocoon-matches
    let $pathSeq :=
      normalize-space($match/@pattern) => tokenize('/')
    group by $isDir := count($pathSeq) gt 1, $dirL1 := $pathSeq[1]
    order by $dirL1, $isDir
    return 
      if ( (: $dirL1 = $testDirs :) $isDir = true() ) then 
        map:entry((concat($dirL1,$slash)), array {
          for $match in $match
          return local:get-path($match)
        })
      else map:entry('.', array { local:get-path($match) })
  };
  
  declare function local:process-filesystem-contents($relative-path as xs:string) {
    let $dirName := tokenize($relative-path, $slash)[last()]
    let $dirContents := file:list(concat($dhq-repo,$slash,$relative-path))
    let $processedContents :=
      for $resource in $dirContents
      let $fullPath := concat($relative-path,$slash,$resource)
      let $isDir := ends-with($resource, '/')
      let $exactMatch :=
        $sitemap//smap:match/*[@src[. = $fullPath]]
      return
        if ( $isDir ) then
          ()
        else if ( exists($exactMatch) and $exactMatch[self::smap:read] ) then
          $resource
        else if ( exists($exactMatch) and $exactMatch[self::smap:generate] ) then
          let $match := $exactMatch/parent::smap:match
          let $transform := $match/smap:transform
          let $xslMap :=
            if ( exists($transform) ) then 
              for $xsl in $transform
              let $outPattern := $xsl/parent::*/@pattern/data(.)
              return map {
                  'stylesheet': $xsl/@src/data(.),
                  'parameters': map:merge(
                    for $param in $xsl/smap:parameter[@name ne 'context']
                    return map:entry($param/@name/data(.), $param/@value/data(.))
                  ),
                  'out': $outPattern
                }
            else ()
          return map { 
              'in': $fullPath,
              'transforms': array {
                $xslMap
              }
            }
        else ()
    return
      map:entry($dirName, array { $processedContents })
  };


(:  MAIN QUERY  :)

(: let $testDirs := ('about', 'common', 'editorial', 'feed') :)
let $repoContentsList := file:list($dhq-repo)
let $repoContents :=
  let $ignoreDirs := ('articles/')
  for $resource in $repoContentsList
  let $isDir := ends-with($resource, $slash)
  return
    if ( $isDir and not($resource = $ignoreDirs) ) then
      local:process-filesystem-contents(replace($resource, $slash, ''))
    else ()
return map:merge($repoContents)
