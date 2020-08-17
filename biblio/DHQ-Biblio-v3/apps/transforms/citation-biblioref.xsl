<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbib="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="dbib dhq xs"
  version="2.0">
  
  <!-- Create <biblioRef> citations from the HTML results of citation-html.xsl. -->
  
  <xsl:import href="citation-html.xsl"/>
  <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="yes"/>
  
  
<!--  TEMPLATES  -->
  
  <xsl:template match="/">
    <xsl:variable name="htmlCitation" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="/dbib:*"/>
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="if ( exists($htmlCitation) ) then $htmlCitation else *" mode="mod-html"/>
  </xsl:template>
  
  <xsl:template match="*" mode="mod-html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="mod-html">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="/div" mode="mod-html">
    <BiblioSet ready="true">
      <xsl:apply-templates mode="#current"/>
    </BiblioSet>
  </xsl:template>
  
  <xsl:template match="/* | p[@class eq 'citation']" mode="mod-html">
    <biblioRef key="{@data-bibid}">
      <xsl:apply-templates mode="#current"/>
    </biblioRef>
  </xsl:template>
  
  <xsl:template match="em" mode="mod-html">
    <i>
      <xsl:apply-templates mode="#current"/>
    </i>
  </xsl:template>
  
</xsl:stylesheet>