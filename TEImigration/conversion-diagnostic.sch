<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   queryBinding="xslt2">


  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  
 <!-- <pattern>
    <rule context="tei:ref">
      <report test="contains(.,',')" role="warning"><name/> contains a comma</report>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="tei:ref[starts-with(@target,'#')]">
      <assert test="replace(@target,'^#','') = //@xml:id">
        <name/>/@target internal link does not resolve</assert>
    </rule>
  </pattern>-->
  
  <!--<pattern>
    <rule context="tei:graphic">
      <report test="exists(@type)"><name/> appears with @type=<value-of select="@type"/></report>
      <assert test="exists(@type)"><name/> has no @type: @url file suffix is '<value-of select="replace(@url,'^.+/.+\.(.+)$','$1')"/>'</assert>
    </rule>
  </pattern>-->
  
  <pattern>
    <rule context="tei:history/tei:change[exists(@when)]">
      <!--<assert test="@when castable as xs:date or
        @when castable as xs:gYear or
        @when castable as xs:gMonth or
        @when castable as xs:gDay or
        @when castable as xs:gYearMonth or
        @when castable as xs:gMonthDay or
        @when castable as xs:time or
        @when castable as xs:dateTime"><name/>/@when has invalid content '<value-of select="@when"/>'</assert>-->
      <assert test="@when castable as xs:date">history/<name/>/@when is not yyyy-mm-dd: '<value-of select="@when"/>'</assert>
    </rule>
    <rule context="tei:*[exists(@when)]">
      <!--<assert test="@when castable as xs:date or
        @when castable as xs:gYear or
        @when castable as xs:gMonth or
        @when castable as xs:gDay or
        @when castable as xs:gYearMonth or
        @when castable as xs:gMonthDay or
        @when castable as xs:time or
        @when castable as xs:dateTime"><name/>/@when has invalid content '<value-of select="@when"/>'</assert>-->
      <assert test="@when castable as xs:date"><value-of select="name(..)"/>/<name/>/@when is not yyyy-mm-dd: '<value-of select="@when"/>'</assert>
    </rule>
  </pattern>
  
<!-- 
  <choice>
  <data type="date"/>
  <data type="gYear"/>
  <data type="gMonth"/>
  <data type="gDay"/>
  <data type="gYearMonth"/>
  <data type="gMonthDay"/>
  <data type="time"/>
  <data type="dateTime"/>
  </choice>

-->
  <!--<pattern>
    <rule context="dhq:caption">
      <report test="exists(tei:p/tei:p)"><name/> appears with p</report>
      <assert test="exists(tei:p/tei:p)"><name/> appears without p</assert>
    </rule>
  </pattern>-->
  
</schema>
