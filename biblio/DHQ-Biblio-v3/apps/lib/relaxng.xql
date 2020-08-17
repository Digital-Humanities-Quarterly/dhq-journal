xquery version "3.1";

  module namespace mrng="http://digitalhumanities.org/dhq/ns/meta-relaxng";
(:  LIBRARIES  :)
(:  NAMESPACES  :)
  declare default element namespace "http://relaxng.org/ns/structure/1.0";
  declare namespace a="http://relaxng.org/ns/compatibility/annotations/1.0";
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace dhxo="http://digitalhumanities.org/dhq/ns/xonomy-rng";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace rng="http://relaxng.org/ns/structure/1.0";
  declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

(:~
  Functions for querying the contents of DHQ Biblio's RelaxNG schema.
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  2019
 :)
 
(:  VARIABLES  :)
  declare variable $mrng:schema := doc('../../schema/dhqBiblio.rng');


(:  FUNCTIONS  :)  
  (:~
    Given an element from a RelaxNG schema, create a list of any children allowed by the schema.
   :)
  declare function mrng:expand-child-references($el as element()?) as array(*) {
    if ( empty($el) ) then array {}
    else
      let $children := $el/rng:*
      let $expanded :=
        for $child in $children
        return mrng:expand-reference($child)
      return
        array { distinct-values($expanded) }
  };
  
  (:~
    Create an XSLT stylesheet to sort the contents of an element matching a given <rng:element>. No 
    validation is done; just sorting. Anything not defined by the schema will appear at the bottom of 
    the element.
   :)
  declare function mrng:generate-sorting-stylesheet($element as node()) as node() {
    let $useEl := $element/descendant-or-self::*[1]
    let $gi := local-name($element)
    let $mainTemplate := mrng:generate-sorting-template($gi, true())
    let $macroTemplates := 
      for $childGi in $mainTemplate//xsl:apply-templates/@select[matches(., '^[\w\.-]+$')]/data(.)
      let $referent := mrng:get-definition($childGi)[self::element]
      return
        if ( mrng:get-class($referent) eq 'bibjs.xonomy.MacroItem' ) then
          mrng:generate-sorting-template($childGi, false())
        else ()
    return
      <xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
         xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio" 
         version="2.0">
        <xsl:output indent="no"/>
        <!-- Identity template. -->
        <xsl:template match="@*|node()" priority="-1">
          <xsl:copy-of select="."/>
        </xsl:template>
        <!-- Template(s) to sort BiblioItems and MacroItems. -->
        { $mainTemplate }
        { $macroTemplates }
      </xsl:stylesheet>
  };
  
  (:~
    Given a tag name, generate an array representing the child nodes allowed by the schema. The number 
    of instances of a child (or whether it exists as an alternative to something else) is not taken into
    account.
   :)
  declare function mrng:get-allowed-content($gi as xs:string) {
    let $definition := mrng:get-definition($gi)
    return
      mrng:expand-child-references($definition)
  };
  
  (:~ 
    Given an <rng:element>, determine how that element is classed in the Biblio Xonomy spec.
   :)
  declare function mrng:get-class($el as element(element)) {
    $el/dhxo:class/@key/data(.)
  };
  
  (:~
    Given the name of an <rng:define> element, retrieve that element.
   :)
  declare function mrng:get-definition($name as xs:string) as node()* {
    let $matches := $mrng:schema//define[@name eq $name or ends-with(@name, '.'||$name)]/*
    return
      if ( not(exists($matches)) ) then
        error(QName('http://digitalhumanities.org/dhq/ns/meta-relaxng/err','no-referent'), 
              concat("Not a valid tag name: '",$name,"'"))
      else $matches
  };
  
  (:~
    Given an element name, find the tag names of all possible parents of that element.
   :)
  declare function mrng:find-parents-of($gi as xs:string) as xs:string* {
    let $elementDefs := $mrng:schema//element[@name eq $gi]
    return mrng:find-elements-containing($elementDefs)
  };


(:  SUPPORT FUNCTIONS  :)
  
  (: Given an element from a RelaxNG schema, decide how to dereference this entity for a list of allowed 
    children. XPath notation is used. :)
  declare %private function mrng:expand-reference($el as element()) {
    typeswitch($el)
      case element(attribute) return
        '@'||$el/@name/data(.)
      case element(element) return
        $el/@name/data(.)
      case element(ref) return
        for $part in mrng:get-definition($el/@name)
        return mrng:expand-reference($part)
      case element(text) return 'text()'
      case element(empty) return '()'
      case element() return
        mrng:expand-child-references($el)
      default
        return ()
  };
  
  (: Given a RelaxNG element with a @name, find all possible parent elements of that entity. A sequence 
    is returned instead of an array because order only matters for readability. :)
  declare %private function mrng:find-elements-containing($named-entities as node()*) as xs:string* {
    let $parentNames :=
      for $entity in $named-entities
      let $name := $entity/@name/data(.)
      let $referer := $entity/(ancestor::element, ancestor::define)[1]
      let $refererName := $referer/@name/data(.)
      let $returnValues :=
        if ( exists($referer[self::element]) 
          or exists($referer[self::define][$refererName eq $name]) ) then
          $refererName
        else if ( exists($referer[self::define]) ) then
          let $refs := $mrng:schema//ref[@name eq $refererName]
          return mrng:find-elements-containing($refs)
        else ()
      return distinct-values($returnValues)
    return 
      sort(distinct-values($parentNames))
  };
  
  (: Create an <xsl:template> which applies templates on every child node allowed for this particular 
    element. This has the effect of sorting elements into their expected order. If a node is not 
    explicitly allowed by the schema, it will appear at the bottom of its parent. :)
  declare %private function mrng:generate-sorting-template($gi as xs:string, $is-root as xs:boolean) as node()? {
    let $matchPath := concat(if ($is-root) then '/' else (), $gi)
    (: Filter attributes out from the list of allowed nodes. :)
    let $allowedChildren := 
      array:filter(mrng:get-allowed-content($gi), function($childGi) { 
        not(starts-with($childGi, '@')) 
      })
    (: Create the <xsl:apply-templates/> instructions. :)
    let $applyTemplates :=
      for $index in 1 to array:size($allowedChildren)
      let $childGi := $allowedChildren?($index)
      return
        <xsl:apply-templates select="{$childGi}"/>
    (: Create a catch-all instruction, which will copy anything not matched by the schema. :)
    let $applyExcept :=
      <xsl:apply-templates 
         select="node() except ({string-join($applyTemplates/@select,', ')})"/>
    return
      (: Skip this template if mixed content is allowed. :)
      if ( $applyTemplates[@select eq 'text()'] ) then ()
      else
        <xsl:template match="{ $matchPath }">
          <xsl:copy>
            <xsl:apply-templates select="@*"/>
            { $applyTemplates }
            { $applyExcept }
          </xsl:copy>
        </xsl:template>
  };
