<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="3.0">
  
  <!--
    Read in an article file, write out the same with an @xml:id added to
    every <figure> that does not already have one.
    Written 2025-06-12 by Syd Bauman
    🄯 2025 by Syd Bauman, available under terms of the MIT license.
  -->

  <xsl:output method="xml"/>
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="/node()">
    <xsl:text>&#x0A;</xsl:text>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="figure[ not(@xml:id ) ]">
    <xsl:variable name="cnt" select="count( preceding::figure ) +1" as="xs:integer"/>
    <!-- The largest number of <figure>s in any single article file is 84, so 2 digits will suffice. -->
    <xsl:variable name="num" select="format-integer( $cnt, '00')"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="'figure'||$num"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
    
</xsl:stylesheet>
