<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  queryBinding="xslt2">


  <p>Check whether ref and ptr are pointing to existing bibls items in the internal bibliography.</p>

 
  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <ns prefix="cc"  uri="http://web.resource.org/cc/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="xs"  uri="http://www.w3.org/2001/XMLSchema"/>
  
  

  <pattern id="id-check">
    <p>Element IDs must be unique</p>
    <rule context="*[exists(@xml:id)]">
      <assert test="empty(//*[@xml:id eq current()/@xml:id]
        except .)">Element appears with a duplicate @xml:id</assert>
    </rule>
  </pattern>
  
  

  <pattern>
    <title>constraints on ptr and ref</title>

    <rule abstract="true" id="target-uri-constraints">
      <assert test="normalize-space(@target)"><name/>/@target is empty</assert>
      <assert test="@target castable as xs:anyURI"><name/>/@target is not a
      URI</assert>
      <assert role="warning" test="matches(@target,'#|/')"><name/>/@target
        appears suspect: it has neither '#' nor '/'</assert>
    </rule>

    <rule context="tei:ptr[starts-with(@target,'#')]">
      <extends rule="target-uri-constraints"/>
      <assert test="replace(@target,'^#','') = //tei:bibl/@xml:id"
        role="warning"><name/> does not reference a bibl</assert>
      <!-- $d is an arabic natural number (one or more digits not starting with 0) -->
      <let name="d" value="'[1-9]\d*'"/>
      <!-- $r is a lower-case roman numeral -->
      <let name="r" value="'m{0,4}(cm|cd|d?c{0,3})(xc|xl|l?x{0,3})(ix|iv|v?i{0,3})'"/>
      <!-- $dr is either a single $d or a hyphen-delimited pair --> 
      <let name="dr" value="concat($d,'(&#x2013;',$d,')?')"/>
      <!-- $rr is the same as $dr, for roman numerals -->
      <let name="rr" value="concat($r,'(&#x2013;',$r,')?')"/>
      <!-- $drrr is a choice between $dr and $rr -->
      <let name="drrr" value="concat('(',$dr,'|',$rr,')')"/>
      <!-- $seq is a sequence of one or more $drrr, comma-delimited -->
      <let name="seq" value="concat('^',$drrr,'(, ',$drrr,')*$')"/>
      
     
    </rule>

    <rule context="tei:ptr">
      <!-- testing tei:ptr linking externally -->
      <extends rule="target-uri-constraints"/>
      <assert test="exists(parent::tei:bibl)"><value-of select="name(..)"
        />/<name/>/@target points externally, but is not inside bibl</assert>
      <assert test="empty(@loc)"><name/> pointing externally should not have @loc</assert>
    </rule>
    <rule context="tei:ref[exists(@target)]">
      <extends rule="target-uri-constraints"/>
      <assert test="normalize-space(.)"><name/> has no text</assert>
      <report test="@type='offline'"><name/> with @target should not have @type='offline'</report>
      <report test="@type='auto'"><name/> has @type='auto': please check</report>
    </rule>
    <rule context="tei:ref">
      <assert test="@type='offline'" role="warning"><name/> has no @target, but is
      also not @type='offline'</assert>
      <assert test="normalize-space(.)"><name/> has no text</assert>
    </rule>
  </pattern>

  <pattern>
    <p>bibl checks</p>
    <rule context="tei:bibl">
      <let name="ptrs-exist" value="@xml:id = //tei:ptr/replace(@target,'^#','')"/>
      <assert test="not($ptrs-exist) or normalize-space(@label)">
        <name/> is cross-referenced by a ptr, so it requires a @label</assert>
      <report test="@label = (//tei:bibl except .)/@label" role="warning">
        <name/>/@label is not unique</report>
    </rule>
    
    <rule context="tei:biblScope[@type='pages']">
      <assert test="matches(.,'\d+(-\d+)?')"><name/>[@type='pages'] doesn't
        appear to be a page or page range</assert>
    </rule>
  </pattern>
  
 
  
</schema>
