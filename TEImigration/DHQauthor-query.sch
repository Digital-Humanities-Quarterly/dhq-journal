<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
   queryBinding="xslt2">


  <ns prefix="dhqa" uri="http://digitalhumanities.org/DHQ/namespace"/>
  
  <pattern>
    <!--<rule context="dhqa:ptr[starts-with(@target,'#')]">
      <let name="target" value="substring-after(@target,'#')"/>
      <assert test="//*[@id=$target]/self::dhqa:bibl">ptr points to a <value-of select="//*[@id=$target]/name()"/></assert>
      </rule>-->
    <!--<rule context="*[exists(@id)]">
      <let name="lc" value="lower-case(@id)"/>
      <assert test="@id = $lc">@id '<value-of select="@id"/>' isn't all lower case</assert>
      <!-\-<report test="count(//@id[.=$lc]) gt 1">casting an ID to '<value-of select="$lc"/>' will break it</report>-\->
      </rule>-->
    <rule context="dhqa:keywords">
      <report test="true()">keywords found</report>
    </rule>
    
    
  </pattern>

</schema>
