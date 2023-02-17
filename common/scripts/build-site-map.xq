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
  declare option output:method "json";
  

(:~
  Use the DHQ journal repository contents and the Apache Cocoon sitemap to figure out what steps a 
  static site generator would need to make in order to produce the current web hierarchy.
  
  This script requires the EXPath File Module. It can be run with BaseX, Saxon PE, or Saxon EE.
  
  @author Ash Clark
  2023
 :)

(:  VARIABLES  :)
  (: If the $dhq-repo filepath isn't provided through the XQuery transformation scenario, we can 
    extrapolate it from the filepath of this XQuery. :)
  declare variable $script-path := file:base-dir();
  declare variable $dhq-repo external := 
    file:parent($script-path) => file:parent();

  (: The character used to separate directories from their contents in the current operating system. :)
  declare variable $slash := file:dir-separator();
  (: The Cocoon sitemap, found in the DHQ repository directory. :)
  declare variable $sitemap := doc(concat($dhq-repo,'sitemap.xmap'));
  (: The DHQ journal table of contents, used to determine which articles get published to which 
    directories. :)
  declare variable $dhqTOC := doc(concat($dhq-repo,'toc',$slash,'toc.xml'));
  
  (: A map of the //@src file patterns which correspond to either wildcard globs or regular expressions. 
    These are parsed into regular expressions and associated with their original Cocoon elements.  :)
  declare variable $file-patterns-unglobbed :=
    let $allPatterns :=
      (: For each Cocoon <match>... :)
      for $match in $sitemap//smap:match
      return
        (: If the current <match> is a regular expression, analyze its @pattern to find its groups, then
          use them to fill in descendant @src patterns. :)
        if ( $match[@type[. eq 'regexp']] ) then
          let $groups :=
            let $analysis := analyze-string($match/@pattern/data(.), "\([^)]+\)")
            return $analysis//fn:match/data(.)
          for $src in $match//@src
          let $analysis :=
            if ( matches($src, '\{\d\}') ) then
              analyze-string($src/data(.), '\{\d\}')
            else ()
          let $groupReplacement :=
            for $strPart in $analysis/*
            return
              if ( $strPart[self::fn:match] ) then
                let $index :=
                  replace($strPart, '\{(\d)\}', '$1')
                  => xs:integer()
                return $groups[$index]
              else $strPart/data(.)
          return
            if ( exists($groupReplacement) ) then
              map:entry(string-join($groupReplacement, ''), $src/parent::*)
            else ()
        (: If the current <match> contains an asterisk in its @pattern, consider it to be in the glob 
          format. Each descendant @src is converted into a regular expression. :)
        else if ( $match/@pattern[contains(., '*')] ) then
          for $src in $match//@src
          let $patternRev :=
            replace($src, '\.', '\\.')
            => replace('\{\d\}', '(.+)')
          return map:entry($patternRev, $src/parent::*)
        (: If the current <match> is not a wildcard, we don't need to cover it here. It's 
          straightforward enough already. :)
        else ()
    return map:merge($allPatterns)
    ;

(:  FUNCTIONS  :)
  
  (:  :)
  declare function local:process-filesystem-contents($relative-path as xs:string) {
    let $dirName := tokenize($relative-path, $slash)[normalize-space() ne ''][last()]
    let $dirContents := file:list(concat($dhq-repo,$slash,$relative-path))
    let $processedContents :=
      for $resource in $dirContents
      let $isDir := ends-with($resource, $slash)
      let $fullPath := 
        concat($relative-path,$resource)
      let $globMatch :=
        for $pattern in map:keys($file-patterns-unglobbed)
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
        else () (: concat("Nope: ", $fullPath) :)
    let $condensedContents :=
      for $content in $processedContents
      group by $wildcardPattern := 
        if ( $content instance of map(xs:string, item()*) and map:contains($content, 'regex') ) then
          map:get($content, 'regex')
        else false()
      return
        if ( $wildcardPattern ) then
          let $match := $file-patterns-unglobbed?($wildcardPattern)
          return
            typeswitch ($match)
              case element(smap:generate) return
                let $xslMap :=
                  let $matchParent := $match/parent::*
                  let $outPattern := 
                    $matchParent/@pattern/data(.)
                  for $xsl in $matchParent/smap:transform
                  return local:process-transformation($xsl, $outPattern)
                return map {
                    'regexPaths': true(),
                    'in': $wildcardPattern,
                    'transforms': array { $xslMap }
                  }
              default return $content[1]
        else $content
    return
      map:entry($dirName, array { $condensedContents })
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

(: Get the contents of the local DHQ journal repository. :)
let $repoContentsList := file:list($dhq-repo)
let $repoContents :=
  let $ignorables := (
      (: Directories to ignore :)
      concat('articles',$slash), concat('.git',$slash), 
      (: Files to ignore :)
      '.gitignore', '.DS_Store', 'README.md'
    )
  (: Process each directory and file inside the repository, skipping anything in $ignorables. :)
  for $resource in $repoContentsList
  let $isDir := ends-with($resource, $slash)
  let $isIgnorable := $resource = $ignorables
  order by lower-case($resource)
  return
    (: If $resource is a directory, parse its contents using the Cocoon sitemap. :)
    if ( $isDir and not($isIgnorable) ) then
      local:process-filesystem-contents($resource)
    else if ( $isIgnorable ) then ()
    (: TODO parse files against the Cocoon sitemap? (or do them by hand) :)
    else $resource
return
  array { $repoContents }
  (: $file-patterns-unglobbed :)