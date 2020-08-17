<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   queryBinding="xslt2">

  <!-- Schematron for alerting us to sore spots in DHQ TEI conversion
       results.
  
  Some of these will require tweaks to the conversion (TEImigration.xsl),
  to the source data (articles in the dhq branch) or both, or directly 
  to the result files. -->
  
  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  
  <pattern>
    <rule context="tei:biblScope[@type='pages']">
      <report test="true()"><name/>[@type='pages'] found: '<value-of select="."/>'</report>
    </rule>
  </pattern>
  
  
  <!--<pattern>
    <rule context="tei:ref">      
      <report test="@type='auto'"><name/> has @type='auto': please check</report>
    </rule>
  </pattern>
-->

  <!--<pattern>
    <title>ptr and ref usage checks</title>
    <rule abstract="true" id="parens-check">
      <let name="preceding" value="(preceding-sibling::text()|preceding-sibling::*)[last()]"/>
      <let name="following" value="(following-sibling::text()|following-sibling::*)[1]"/>
      <report test="matches($preceding,'\($') and matches($following,'^\)')"><name/> is surrounded by parentheses</report>
      <report test="matches($preceding,'\[$') and matches($following,'^\]')"><name/> is surrounded by brackets</report>
    </rule>   
    
    <rule context="tei:bibl/tei:ptr">
      <extends rule="parens-check"/>
      <assert test="normalize-space(@target) and @target castable as xs:anyURI">bibl/ptr/@target is not a URI</assert>
      <report test="starts-with(@target,'#')"><value-of select="name(..)"/>/<name/> is an internal cross-reference</report>
    </rule>
    <rule context="tei:ptr">
      <!-\- this rule only matches ptr not inside bibl -\->
      <extends rule="parens-check"/>
      <assert test="starts-with(@target,'#') and @target castable as xs:anyURI"><value-of select="name(..)"/>/<name/>/@target is not an internal cross-reference</assert>
      <assert test="replace(@target,'^#','') = //@xml:id" role="warning"><name/> outside bibl does not reference a bibl</assert>
      <assert test="not(@loc) or matches(@loc,'\d+(-\d+)?')"><name/>/@loc '<value-of select="@loc"/>' is unusual: please check</assert>
    </rule>
    <rule context="tei:ref">
      <extends rule="parens-check"/>
      <assert test="normalize-space(.)"><name/> has no text</assert>
      <assert test="normalize-space(@target) and @target castable as xs:anyURI"><name/>/@target is not a URI</assert>
    </rule>
    </pattern>
  
  <pattern>
    <title>Where do ptr and ref appear in cit?</title>
    <rule context="tei:cit/tei:ptr | tei:cit/tei:ref">
      <report test="true()" role="info"><value-of select="name(..)"/>/<name/> appears</report>
    </rule>
  </pattern>
  
  <pattern>
    <title>checks of code and eg</title>
    <rule context="tei:eg">
      <assert test="contains(.,'&#xA;')" role="warning"><name/> has no carriage return</assert>
      <assert test="string-length(.) gt 40"><name/> is 40 chars or less</assert>
    </rule>
    <rule context="tei:code">
      <report test="contains(.,'&#xA;')"><name/> has a carriage return</report>
      <report test="string-length(.) gt 40"><name/> is more than 40 chars</report>
    </rule>
  </pattern>
  
  <pattern>
    <title>reports when 'Appendix' is mentioned</title>
    <rule context="/*">
      <report test="matches(.,'appendi(x|ces)','i')">"appendix" (or appendices) is mentioned (case-insensitive search)</report>
    </rule>
  </pattern>
-->  
    
</schema>
