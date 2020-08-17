<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  queryBinding="xslt2">


  <p>Authorial readiness check for DHQ articles.</p>

  <p>This checks a number of constraints on DHQauthor articles that we can't or
    don't want to check in the main schema, either because they interrogate
    attribute values (for example to check cross-referencing), or because they
    are not absolute rules, or they entail complex dependencies of one kind or
    another.</p>

  <!-- to do: migrate the old dhq-ready Schematron code into this -->
  <!-- Also check DHQ-TEI-diagnostic.sch for rules that should be
       in here -->

  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <ns prefix="cc"  uri="http://web.resource.org/cc/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="xs"  uri="http://www.w3.org/2001/XMLSchema"/>
  
  <pattern id="top-level">
<!-- Cannot put up with hrefs to http: in
      <?oxygen RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"?>
      <?oxygen SCHSchema="../../common/schema/dhqTEI-ready.sch"?>
      <?xml-model href="../../toc/toc-xml.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    
    -->
    <!--<?oxygen RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"?>
    <?oxygen SCHSchema="../../common/schema/dhqTEI-ready.sch"?>-->
    <rule context="/processing-instruction()">
      <report test="matches(.,'(RNGSchema|SCHSchema|href)=&quot;http')" role="warning">
        Processing instruction points to the Internet - this file will not be portable.
      </report>
      
    </rule>
  </pattern>

  <pattern id="id-check">
    <p>Element IDs must be unique</p>
    <rule context="*[exists(@xml:id)]">
      <assert test="empty(//*[@xml:id eq current()/@xml:id]
        except .)">Element appears with a duplicate @xml:id</assert>
    </rule>
  </pattern>
  
  <pattern id="header-check">
    <p>Content checks in header</p>
    
    
    <rule
      context="tei:availability |
                   cc:License |
                   tei:profileDesc |
                   tei:profileDesc//* |
                   tei:revisionDesc"
      >
      <!-- matching these to create exceptions for the next rules --> </rule>

    <rule context="tei:teiHeader//*">
      <assert test="normalize-space(.)">
        <value-of select="name(..)"/>/<name/> has no text content</assert>
    </rule>
    
    <rule context="tei:teiHeader//tei:date">
      <assert test="@when castable as xs:date"><value-of select="name(..)"
        />/<name/>/@when is not an ISO date</assert>
      <let name="date-str" value="@when/format-date(.,'[D] [MNn] [Y]')"/>
      <assert test=". = $date-str">date value is not @when in 'D Month YYYY'
        format (expecting '<value-of select="$date-str"/>')</assert>
    </rule>

    <rule context="tei:classDecl">
      <assert test="exists(tei:taxonomy[@xml:id='dhq_keywords'])"><name/> is
        missing a 'dhq_keywords' taxonomy declaration</assert>
      <assert test="exists(tei:taxonomy[@xml:id='authorial_keywords'])"><name/>
        is missing an 'authorial_keywords' taxonomy declaration</assert>
    </rule>

    <rule context="tei:taxonomy[@xml:id='dhq_keywords']">
      <!--<let name="contents" value="*|text()[normalize-space(.)]"/>
      <assert test="exists(bibl[1]) and not($contents except tei:bibl[1])"><name/> contains
      unexpected content (should have a single bibl)</assert>
      <assert test="normalize-space(.) = 
        normalize-space('DHQ classification scheme; full list available in the
        DHQ keyword taxonomy')">text content of <name/> is incorrect: should be
        "DHQ classification scheme; full list available in the
        DHQ keyword taxonomy"</assert>--> </rule>
    <rule context="tei:taxonomy[@xml:id='authorial_keywords']"/>
    <rule context="tei:classDecl/*">
      <report test="true()"><name/> unexpected here</report>
    </rule>

    
    <rule context="tei:front//dhq:*">
      <assert test="normalize-space(.)"><name/> is empty</assert>
    </rule>
  </pattern>

  <pattern>
    <p>Specialized cross-referencing checks</p>
    <rule context="tei:keywords">
      <assert test="@scheme = ../../../tei:encodingDesc/tei:classDecl/
        tei:taxonomy/@xml:id/concat('#',.)"><name/>/@scheme is unrecognized
      (should be on a classDecl/taxonomy in encodingDesc)</assert>
    </rule>
  </pattern>
  

  <pattern id="soft-modeling">
    <p>Miscellaneous soft modeling constraints and warnings</p>
    <rule role="warning" context="tei:div">
      <report test="empty(tei:head)">A div has no head.</report>
    </rule>
    <rule role="warning" context="tei:head">
      <assert test="empty(preceding-sibling::tei:head)">This is not the first head in this element; please check (is this a new div or caption)?</assert>
    </rule>
    <rule role="warning" context="tei:floatingText">
      <report test="exists(ancestor::tei:floatingText)"><name/> appears inside
        floatingText</report>
    </rule>
    <rule role="warning" context="tei:note">
      <report test="exists(ancestor::tei:note)"><name/> appears inside
        note.</report>
    </rule>
    <rule role="warning" context="tei:example">
      <report test="exists(ancestor::tei:example)"><name/> appears inside
        example.</report>
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
      
      <assert test="not(@loc) or matches(@loc,$seq)" role="warning"
        ><name/>/@loc '<value-of select="@loc"/>' is unusual: please
        check</assert>
      <report test="contains(@loc,'-')" role="warning"><name/>/@loc contains
        '-' (hyphen): try '&#x2013;' (en-dash)</report>
      <!-- elsewhere we check bibl elements to which we have ptr cross-references,
           to ensure they also have @label -->
       
      <!--
        old code doesn't support sequences 
      <let name="d" value="'\d+'"/>
      <let name="r" value="'m{0,4}(cm|cd|d?c{0,3})(xc|xl|l?x{0,3})(ix|iv|v?i{0,3})'"/>
      <let name="page-range-regex"
        value="concat('^',$d,'(-',$d,')?$|^',$r,'(-',$r,')?','$')"/>
      <!-\-<report test="true()" role="info">page-range-regex is <value-of select="$page-range-regex"/></report>-\->
      <assert test="not(@loc) or matches(@loc,$page-range-regex)" role="warning"
        ><name/>/@loc '<value-of select="@loc"/>' is unusual: please
        check</assert>-->
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
  
  
  <pattern>
    <title>checks of code, eg and formula (math notation)</title>
    <rule context="tei:eg">
      <assert test="contains(.,'&#xA;')" role="warning"><name/> has no carriage
        return</assert>
      <assert test="string-length(.) gt 40" role="warning"><name/> is 40 chars or less</assert>
    </rule>
    <rule context="tei:code">
      <report test="string-length(.) gt 40" role="warning"><name/> is more than 40
        chars</report>
    </rule>
    <rule context="tei:formula">
      <let name="notation-type" value="string-join((@rend,@notation),'-')"/>
      <assert test="@notation=('tex','asciimath')">Unknown @notation on formula</assert>
      <!-- 's' flag for dot-all or the test fails when \n is present     -->
      <assert test="not($notation-type='inline-tex') or matches(string(.),'^\\\(.*\\\)$','s')">inline-tex math is expected to present wrapped escaped parentheses \( ... \)</assert>
      <assert test="not($notation-type='block-tex') or matches(string(.),'^\$\$.*\$\$$','s')">block-tex math is expected to present '$$' delimiters at start and end</assert>
      <assert test="not(@notation='asciimath') or matches(string(.),'^`.*`$','s')">asciimath formula is expected to have back-tick ` delimiters at start and end</assert>
    </rule>
  </pattern>

  <pattern>
    <title>flagging markup content</title>
    <rule context="tei:code | tei:eg | tei:formula"/>
    <rule context="*[exists(text()[normalize-space(.)])]">
      <!-- matches any elements that don't match the first rule -->
      <report role="warning" test="exists(text()[matches(.,'&lt;|&gt;')])">
      text contains markup characters</report>
    </rule>
  </pattern>

  <pattern>
    <title>flagging doubtful text content</title>
    <!-- matches any element containing non-whitespace text content
      that has no ancestor with non-whitespace text content
      (so: paragraphs, heads, etc., not inline markup) -->
    <rule role="warning" context="*[text()[normalize-space()]]
      [empty(ancestor::*/text()[normalize-space()])]">
      <report test="matches(.,'\S&#x2014;') or matches(.,'&#2014;\S')">em dash appears
        next to non-space character</report>
    </rule>
  </pattern>
  
</schema>
