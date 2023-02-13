xquery version "3.1";

(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace file="http://expath.org/ns/file";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace smap="http://apache.org/cocoon/sitemap/1.0";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
(:  OPTIONS  :)
  declare option output:indent "yes";
  (: declare option output:method "json"; :)
  

(:~
  Use the DHQ journal repository contents and the Apache Cocoon sitemap to figure out what steps a 
  static site generator would need to make in order to produce the current web hierarchy.
  
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
  
  declare variable $file-patterns-unglobbed :=
    for $match in $sitemap//smap:match
    return
      if ( $match[@type[. eq 'regexp']] ) then
        ()
      else if ( $match/@pattern[contains(., '*')] ) then
        for $src in $match//@src
        return
          replace($src, '\.', '\\.')
          => replace('\{\d\}', '(.+)')
      else ();

(:  FUNCTIONS  :)
  
  declare function local:process-filesystem-contents($relative-path as xs:string) {
    let $dirName := tokenize($relative-path, $slash)[normalize-space() ne ''][last()]
    let $dirContents := file:list(concat($dhq-repo,$slash,$relative-path))
    let $processedContents :=
      for $resource in $dirContents
      let $isDir := ends-with($resource, '/')
      let $fullPath := 
        concat($relative-path,$resource)
      let $globMatch :=
        for $pattern in $file-patterns-unglobbed
        return
          if ( matches($fullPath, $pattern) ) then
            $pattern
          else ()
      let $exactMatch :=
        $sitemap//smap:match/*[@src[. = $fullPath]]
      order by $resource
      return
        if ( $isDir ) then
          local:process-filesystem-contents($fullPath)
        else if ( exists($exactMatch) and $exactMatch[self::smap:read] ) then
          $resource
        else if ( exists($exactMatch) and $exactMatch[self::smap:generate] ) then
          let $match := $exactMatch/parent::smap:match
          let $transform := $match/smap:transform
          let $xslMap :=
            if ( exists($transform) ) then 
              for $xsl in $transform
              let $outPattern := $xsl/parent::*/@pattern/data(.)
              return local:process-transformation($xsl, $outPattern)
            else ()
          return map { 
              'in': $fullPath,
              'transforms': array {
                $xslMap
              }
            }
        else if ( exists($globMatch) ) then
          map { 'regex': $globMatch[1] }
        else if ( $resource = ('.DS_Store', 'LICENSE') ) then ()
        else concat("Nope: ", $fullPath)
    return
      map:entry($dirName, array { $processedContents })
  };
  
  declare function local:process-transformation($xsl-definition as node(), $save-to-path as xs:string) {
    map {
        'stylesheet': $xsl-definition/@src/data(.),
        'parameters': map:merge(
          for $param in $xsl-definition/smap:parameter[@name ne 'context']
          return map:entry($param/@name/data(.), $param/@value/data(.))
        ),
        'out': $save-to-path
      }
  };


(:  MAIN QUERY  :)

(: let $testDirs := ('about', 'common', 'editorial', 'feed') :)
(: $file-patterns-unglobbed :)
let $repoContentsList := file:list($dhq-repo)
let $repoContents :=
  let $ignorables := (
      'articles/', '.git/', '.gitignore', '.DS_Store', 'README.md'
    )
  for $resource in $repoContentsList
  let $isDir := ends-with($resource, $slash)
  let $isIgnorable := $resource = $ignorables
  order by lower-case($resource)
  return
    if ( $isDir and not($isIgnorable) ) then
      local:process-filesystem-contents($resource)
    else if ( $isIgnorable ) then ()
    else $resource
return array { $repoContents }
