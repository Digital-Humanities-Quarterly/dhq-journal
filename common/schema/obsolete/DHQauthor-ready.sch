<?xml version="1.0" encoding="utf-8"?>

<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
   queryBinding="xslt2">

  <ns prefix="dhq" uri="http://digitalhumanities.org/DHQ/namespace"/>
  
  <p>Authorial readiness check for DHQ articles.</p>
  
  <p>This checks a number of constraints on DHQauthor articles that we can't or don't want to check in the main schema, either because they interrogate attribute values (for example to check cross-referencing), or because they are not absolute rules, or they entail complex dependencies of one kind or another.</p>

  <pattern id="draft-article">
    <p>Constraints related to DHQdraft documents</p>
    <rule context="/*">
      <report test="self::dhq:DHQdraft">This piece is a DHQdraft. For submission to DHQ, please make sure it has a DHQheader, and change the document (top-level) element to DHQarticle.</report>
      <report test="empty(dhq:DHQheader)">This article has no header. It needs a header before it can be submitted to DHQ.</report>
    </rule>
  </pattern>
  
  <pattern id="header-check">
    <p>Misc warnings and heads-up on header</p>
    <rule context="dhq:DHQheader">
      <assert test="normalize-space(dhq:title) = normalize-space(/*/dhq:text/dhq:head)">The title offered in the DHQheader is different from the head given in the text. (Okay?)</assert>
      <assert test="dhq:author[normalize-space(.)]">In the header, no author is given.</assert>
      <assert test="dhq:langUsage/dhq:language/@id">In the header, no language is given.</assert>
      <assert test="dhq:abstract">No abstract is given.</assert>
      <assert test="dhq:teaser[normalize-space(.)]">Teaser is not given, or is empty.</assert>
    </rule>
  </pattern>

  <pattern id="soft-modeling">
    <p>Miscellaneous soft modeling constraints and warnings</p>
    <rule context="/*">
      <report test="exists(dhq:text//dhq:bibl) and exists(dhq:listBibl/dhq:bibl)">bibl elements appear both inline and in a listBibl (please place them all in one location or the other).</report>
    </rule>
    <rule context="dhq:div">
      <report test="empty(dhq:head)">A div has no head. (Okay?)</report>
    </rule>
    <rule context="dhq:xtext">
      <report test="ancestor::dhq:xtext">An xtext appears inside an xtext.</report>
    </rule>
    <rule context="dhq:note">
      <report test="ancestor::dhq:note">A note appears inside a note.</report>
    </rule>
    <rule context="dhq:example">
      <report test="ancestor::dhq:example">An example appears inside an example.</report>
    </rule>
  </pattern>
  
  
  <pattern id="unique-identifiers">  
    <p>Various constraints on unique identifiers</p>
    <rule context="*[@id]">
      <assert test="normalize-space(@id)">An @id is empty</assert>
      <report test="contains(normalize-space(@id), ' ')">An @id contains a space.</report>
      <report test="count($all-ids = current()/@id) &gt; 1">An @id is being used more than once.</report>
    </rule>
  </pattern>
  
  <let name="all-ids" value="//@id"/>
  
  <pattern id="cross-references">
    <p>Cross-referencing constraints</p>
    <rule context="dhq:ref[not(normalize-space(@target))]">
      <report test=".">A ref has no @target. (Okay?)</report>
      <report test="not(normalize-space())">A ref appears with no target and no content (no link will be displayed)</report>
    </rule>
    <rule context="dhq:ptr[not(normalize-space(@target))]">
      <report test=".">A ptr has no @target (no link will be generated)</report>
      <report test="not(normalize-space())">A ref appears with no target and no content (no link will be displayed)</report>
    </rule>
    <rule context="dhq:ref[normalize-space(@target)] | dhq:ptr[normalize-space(@target)]">
      <let name="internal-ref" value="normalize-space(substring-after(@target[starts-with(.,'#')],'#'))"/>
      <let name="target" value="//*[@id = $internal-ref]"/>
      <assert test="@target castable as xs:anyURI">The target of a <value-of select="local-name()"/> is not a URI</assert>
      <assert test="not($internal-ref) or $internal-ref = $all-ids">The target of an internal <value-of select="local-name()"/> must correspond to an @id</assert>
      <assert test="empty($target) or $target[self::dhq:div | self::dhq:figure | self::dhq:example | self::dhq:table | self::dhq:bibl | self::dhq:note | self::dhq:xtext | self::dhq:letter | self::dhq:appendix]">An internal <value-of select="local-name()"/> should point to one of: div, figure, example, table, bibl, note, xtext, letter, appendix</assert>
      <assert test="empty($target) or not(parent::dhq:cit) or $target[self::dhq:bibl]">In a cit, ref or ptr should point to a bibl</assert>
      <assert test="empty(@loc) or $target[self::dhq:bibl]">A ptr with a @loc must point to a bibl</assert>
    </rule>
  </pattern>
  
  <pattern id="bibl-check">
    <rule context="dhq:bibl">
      <report test="dhq:name[not(@role)]">In a bibl, every name must have a @role</report>
    </rule>
  </pattern>
  
  <pattern id="hi-rend">
    <rule context="dhq:hi[@rend]">
      <assert test="every $r in tokenize(normalize-space(@rend),'\s+') satisfies ($r =
        ('bold', 'italic', 'monospace', 'smcaps', 'quotes', 'subscript',
         'superscript', 'underline', 'strikethrough'))">hi/@rend value not recognized; must
      be one or some combination of 'bold', 'italic', 'monospace', 'smcaps', 'quotes',
      'subscript', 'superscript', 'underline', 'strikethrough'</assert>
    </rule>
  </pattern>
  
      
      
</schema>