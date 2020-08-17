xquery version "3.1";

module namespace lev="http://digitalhumanities.org/dhq/ns/levenshtein";
  declare boundary-space preserve;
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:~
  Levenshtein Distance
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  Created 2019-03
 :)


(:  FUNCTIONS  :)
  
  (:~ Given two strings, calculate the edit distance between them. Diacritics are counted as minor 
    changes if the two characters being compared would otherwise be the same. :)
  declare function lev:calculate-distance($source-string as xs:string, $target-string as xs:string?) {
    let $source := lev:split-string($source-string)
    let $target :=
      if ( empty($target-string) or $target-string eq '' ) then 
        array { '' }
      else lev:split-string($target-string)
    let $sourceLength := array:size($source)
    let $targetLength := array:size($target)
    return
      (: Don't handle two 0-length strings. :)
      if ( $sourceLength eq 0 and $targetLength eq 0 ) then 0
      (: The Levenshtein distance is only 0 if the source string is the same as the target. :)
      else if ( $source-string eq $target-string ) then 0
      else
        let $matrix := lev:build-matrix($source, $target)
        return $matrix[last()]($sourceLength + 1)
  };
  
  (:~ Given a sequence of string tokens, calculate the edit distance of each token to each other token 
    in the set. :)
  declare function lev:compare-across-tokens($tokens as xs:string+) as element(fn:map) {
    lev:compare-across-tokens($tokens, -1)
  };
  
  (:~ Given a sequence of string tokens, calculate the edit distance of each token to each other token 
    in the set. If a positive number is set for $max-acceptable-distance, that number is used to filter 
    the returned results. Setting $max-acceptable-distance can greatly reduce processing time. :)
  declare function lev:compare-across-tokens($tokens as xs:string+, 
      $max-acceptable-distance as xs:decimal) as element(fn:map) {
    let $limitingDistance := $max-acceptable-distance ge 0
    let $distinct := 
      for $token in $tokens
      (: Names that are similar to each other are likely to be within a few characters of each other, so 
        we sort each group by string-length. :)
      order by string-length($token) descending, $token
      return $token
    let $results :=
      (: Compare each distinct name to those following groupmates. This keeps name pairs from repeating. :)
      for sliding window $window in $distinct
        start $token at $tokenIndex previous $beforeThis when 
          (: Because the values of @key should be distinct, only the first of a repeated string should 
            start a comparison window. :)
          $beforeThis ne $token
        end $comparedToken next $afterFinal when
          (: If $max-acceptable-distance is a negative number, or is greater than the length of the 
            current token, end the window when there are no more following groupmates to process. :)
          if ( not($limitingDistance) or floor($max-acceptable-distance) gt string-length($token) ) then 
            not($afterFinal)
          (: Otherwise, constrain the window to only those following groupmates which have a similar 
            string length. :)
          else
            not($afterFinal)
            or string-length($afterFinal) lt ( string-length($token) - floor($max-acceptable-distance) )
      let $tokenMaps := 
        (: Reduce the window to only those strings following the start token, which are also distinct. 
          Each value of @key should only occur once. :)
        for $followingToken in distinct-values($window)
        let $levDistance := lev:calculate-distance($token, $followingToken)
        where 
          if ( $limitingDistance ) then
            $levDistance le $max-acceptable-distance
          else true()
        order by $levDistance ascending
        return 
          <number xmlns="http://www.w3.org/2005/xpath-functions" 
            key="{$followingToken}">{ $levDistance }</number>
      return 
        if ( count($tokenMaps) gt 0 ) then
          <map xmlns="http://www.w3.org/2005/xpath-functions" 
            key="{$token}">{ $tokenMaps }</map>
        else ()
    return
      <map xmlns="http://www.w3.org/2005/xpath-functions">
        { $results }
      </map>
  };
  
  (:~ Given a sequence of string tokens, organize them into groups that share the same leading 
    character, lower-cased and without combining marks. Then calculate the edit distance of each token 
    to each other token in its group. :)
  declare function lev:compare-alphabetically-grouped-tokens($tokens as xs:string+) 
      as element(fn:map) {
    lev:compare-alphabetically-grouped-tokens($tokens, -1)
  };
  
  (:~ Given a sequence of string tokens, organize them into groups that share the same leading 
    character, lower-cased and without combining marks. Then, calculate the edit distance of each token 
    to each other token in its group. If a positive number is set for $max-acceptable-distance, that 
    number is used to filter the returned results. :)
  declare function lev:compare-alphabetically-grouped-tokens($tokens as xs:string+, 
      $max-acceptable-distance as xs:decimal) as element(fn:map) {
    let $groupedResults :=
      for $tokenGrp in $tokens
      let $char1 := lev:remove-combining-marks(lower-case(substring($tokenGrp, 1, 1)))
      group by $char1
      order by $char1
      return
        lev:compare-across-tokens($tokenGrp, $max-acceptable-distance)
    return 
      <map xmlns="http://www.w3.org/2005/xpath-functions">
        { $groupedResults/fn:map[@key] }
      </map>
  };
  
  (:~ Given an <fn:map> of edit distances between a collection of tokens, make sure that every edit 
    distance is represented in both keyed <fn:map>s, not just the first. Because order is no longer 
    necessary for communicating the relationships between values, the results are sorted alphabetically 
    (and by distance). :)
  declare function lev:create-full-report($distance-results as element(fn:map)) {
    let $fieldKeys := $distance-results//fn:map[@key]
    let $fullResults :=
      for $strMap in $fieldKeys
      let $thisKey := $strMap/@key/data(.)
      let $otherRefs := 
        for $ref in $fieldKeys[@key ne $thisKey][fn:number[@key eq $thisKey]]
        let $thatKey := $ref/@key/data(.)
        return
          <number xmlns="http://www.w3.org/2005/xpath-functions" 
            key="{$thatKey}">{ $ref/fn:number[@key eq $thisKey]/text() }</number>
      let $allDistances :=
        ( $strMap/fn:number, $otherRefs )
      order by lev:make-sortable-string($thisKey)
      return
        <map xmlns="http://www.w3.org/2005/xpath-functions" key="{$thisKey}">
          {
            for $dist in $allDistances
            order by $dist/text() ascending, lev:make-sortable-string($dist/@key/data(.))
            return $dist
          }
        </map>
    return
      <map xmlns="http://www.w3.org/2005/xpath-functions">
        { $fullResults }
      </map>
  };
  
  (:~ Given an <fn:map> of edit distances between a collection of tokens, organize the results such that 
    tokens which share a low distance score between them are grouped together. :)
  declare function lev:group-likeliest-results($distance-results as element(fn:map)) as element(fn:array) {
    let $mapGroups :=
      for tumbling window $set in $distance-results//fn:map[@key]
        start $firstMember when true()
        end $finalMember next $afterFinal when $afterFinal[fn:number[not(@key/data(.) = ($firstMember//@key/data(.)))]]
      return
        <map xmlns="http://www.w3.org/2005/xpath-functions">
          <array key="group-members">
            { 
              for $member in distinct-values($set//@key) 
              return <string>{ $member }</string>
            }
          </array>
          <map key="edit-distances">{ $set }</map>
        </map>
    return
      <array xmlns="http://www.w3.org/2005/xpath-functions">
        { $mapGroups }
      </array>
  };
  
  (:~ Strip combining marks from a string, leaving the base characters. Combining marks run from U+0300 
    to U+036F. See https://www.unicode.org/reports/tr15 for more on collation. :)
  declare function lev:remove-combining-marks($string as xs:string) as xs:string {
    let $decomposedStr := normalize-unicode($string, 'NFKD')
    return
      replace($decomposedStr,'[̀-ͯ]','')
  };
  
  (:~ Remove characters that are NOT word characters or whitespace. This may be useful for finding 
    strings at distance "0", for example when two distinct strings differ only in punctuation. :)
  declare function lev:remove-nonessential-characters($string as xs:string) {
    normalize-space(replace($string,'[^\w\s]',''))
  };
  
  (:~ Split a string into an array of character tokens. Normalization should be done before this step. :)
  declare function lev:split-string($string as xs:string) as array(xs:string+)* {
    array {
      analyze-string($string, '.')//fn:match/(text() cast as xs:string)
    }
  };
  
  
(:  SUPPORT FUNCTIONS  :)
  
  (:~ Create a matrix of edit distances for each character in the source string and each 
    character in the target string. Assuming that the characters of the source string form the 
    columns of the resulting table, we iterate over the characters of the target string to 
    calculate the distances. When the iteration is complete, the Levenshtein distance should 
    be equal to the final "cell" in the matrix. :)
  declare %private function lev:build-matrix($source as array(xs:string+)*, $target as array(xs:string+)*) {
    let $sourceLength := array:size($source)
    let $sourceRow := array {
        for $charPos in (0 to $sourceLength)
        return $charPos
      }
    return lev:iterate-by-row($source, $target, $sourceRow, 1)
  };
  
  (:~ Recursively compare a character from the source string to each character in the target string, 
    thus creating a row in the edit distance matrix. :)
  declare %private function lev:determine-cost-of-character($source as array(xs:string+)*, 
      $target as array(xs:string+)*, $previous-row as array(*), $target-position as xs:integer, 
      $current-row as array(*)) {
    let $sourceLength := array:size($source)
    let $rowSize := array:size($current-row)
    return
      (: An empty array should be prefixed with the current character position within the 
        target word. :)
      if ( $rowSize eq 0 ) then
        let $prefixedRow := array:append($current-row, $target-position)
        return
          lev:determine-cost-of-character($source, $target, $previous-row, $target-position, $prefixedRow)
      (: The current row is complete when we have handled all characters in the source string. :)
      else if ( $rowSize gt $sourceLength ) then
        $current-row
      (: Otherwise, we get to work calculating the minimum edit distance. :)
      else
        let $sourcePos := $rowSize
        let $targetChar := $target($target-position)
        let $correspChar := $source($sourcePos)
        let $substitutionCost :=
          if ( $targetChar eq $correspChar ) then 0
          else
            (: This is my addition: if the characters would be equal with any diacritics 
              stripped out, use a value of 0.5. :)
            let $nfkdTarget := lev:remove-combining-marks($targetChar)
            let $nfkdCorresp := lev:remove-combining-marks($correspChar)
            return
              if ( $nfkdTarget eq $nfkdCorresp ) then 0.5
              else 1
        let $deletion := $previous-row($sourcePos + 1) + 1
        let $insertion := $current-row($sourcePos) + 1
        let $substitution := $previous-row($sourcePos) + $substitutionCost
        let $distance := min( ($deletion, $insertion, $substitution) )
        (: Add the minimum distance to the current row, and call this function again for the 
          next character in the target string. :)
        let $updatedRow := array:append($current-row, $distance)
        return lev:determine-cost-of-character($source, $target, $previous-row, $target-position, $updatedRow)
  };
  
  (:~ Recursively add rows to the matrix for each character in the target string. :)
  declare %private function lev:iterate-by-row($source as array(xs:string+)*, $target as array(xs:string+)*, 
      $previous-row as array(*), $target-position as xs:integer) {
    (: If we've handled all the characters in the target string, we're done with the matrix. :)
    if ( $target-position gt array:size($target) ) then ()
    (: Otherwise, we build out the matrix. :)
    else
      let $newRow := lev:determine-cost-of-character($source, $target, $previous-row, $target-position, array{})
      return
        (
          $newRow,
          (: The current row (using the current character in $target) is used in the calculations for 
            the next row. :)
          lev:iterate-by-row($source, $target, $newRow, $target-position + 1)
        )
  };
  
  (:~ Given a string of text, create a version that is suitable for alphabetical sorting. :)
  declare %private function lev:make-sortable-string($string as xs:string) {
    lower-case(lev:remove-combining-marks($string))
  };
