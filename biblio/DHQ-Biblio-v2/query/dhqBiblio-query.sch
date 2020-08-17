<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <ns prefix="biblio" uri="http://digitalhumanities.org/dhq/ns/biblio"/>
  
  <!-- Designed to provide us 'poor man's query' over a file set -->
  
  <xsl:variable name="authorQuery"/><!--Flanders</xsl:variable>-->
  
  <xsl:variable name="titleQuery"/><!--Visual Digital Culture: Surface Play and Spectacle in New Media Genres</xsl:variable>-->
  
  <pattern>
    <rule context="biblio:additionalTitle">
      <report test="true()">
        additionalTitle found
      </report>
    </rule>
    <!--<rule context="*[exists(@dhqID)]/dhq:author">
      <report test="normalize-space($authorQuery) and (*/lower-case(normalize-space(.)) = lower-case(normalize-space($authorQuery)))">
        Found candidate for title '<value-of select="$authorQuery"/>'
      </report>
    </rule>
    <rule context="*[exists(@dhqID)]/dhq:title">
      <report test="normalize-space($titleQuery) and (lower-case(normalize-space(.)) = lower-case(normalize-space($titleQuery)))">
        Found candidate for author '<value-of select="$titleQuery"/>'
      </report>
    </rule>
    <rule context="dhq:date">
      <assert test=".='n.d.' or matches(.,'^(19|20)[0-9]{2}$')">
        Look at this date: '<value-of select="."/>'
      </assert>
    </rule>-->
  </pattern>
  
  <!--<xsl:include href="dhqBiblio-schematron-util.xsl"/>-->
  
</schema>