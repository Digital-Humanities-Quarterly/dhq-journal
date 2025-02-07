<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Mar 23, 2024</xd:p>
      <xd:p><xd:b>Author:</xd:b> syd</xd:p>
      <xd:p>Read in the DHQ search.html file created by the UVEPSS process and write
      out a version with some mods:
      <xd:ul>
        <xd:li>“issue” and “volume” boxes swapped to correct order</xd:li>
        <xd:li>Re-sort the “Search only in” checkbox list so that the languages all come last</xd:li>
      </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xhtml"/>
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="div[ @class eq 'ssNumFilters']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="fieldset">
        <xsl:sort select="@id"/>
        <!-- This works because “volume” has ID ssNum1, and “issue” ssNum2. -->
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="ul[ @class eq 'ssSearchInCheckboxList']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="li[ label[ not( starts-with( .,'language:') ) ] ]"/>
      <xsl:apply-templates select="li[ label[      starts-with( .,'language:')   ] ]"/>
    </xsl:copy>
   </xsl:template>

</xsl:stylesheet>