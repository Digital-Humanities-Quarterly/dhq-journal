<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbib="http://digitalhumanities.org/dhq/ns/biblio/util"
  exclude-result-prefixes="xs dbib"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml" omit-xml-declaration="yes"/>
  
  
<!--  VARIABLES  -->
  <xsl:variable name="nbsp" select="'&#160;'"/>
  
  
<!--  TEMPLATES  -->
  
  <xsl:template match="text()">
    <xsl:copy/>
  </xsl:template>
  
  <!--<xsl:template match="text()[normalize-space() eq '']" priority="2">
    <xsl:value-of select="$nbsp"/>
  </xsl:template>-->
  
  <xsl:template match="/">
    <div class="container container-grid cite-actionable">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="/TEI">
    <xsl:apply-templates select="//back/listBibl"/>
  </xsl:template>
  
  <xsl:template match="/bibl | listBibl/bibl">
    <div class="cite-metadata">
      <span>
        <xsl:text>Key: </xsl:text>
        <xsl:value-of select="if ( @key ) then @key else 'none'"/>
      </span>
    </div>
    <div class="hangindent cite-entry">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!--
  <xsl:template match="listBibl">
    <xsl:apply-templates/>
  </xsl:template>-->
  
  <xsl:template name="italicize" match="*[@rend eq 'italic']" priority="5">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  
  <xsl:template name="quote" match="*[@rend eq 'quotes']" priority="5">
    <xsl:text>“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”</xsl:text>
  </xsl:template>
  
  <xsl:template match="title | hi | emph | foreign">
    <xsl:call-template name="italicize"/>
  </xsl:template>
  
  <xsl:template match="soCalled">
    <xsl:call-template name="quote"/>
  </xsl:template>
  
  <xsl:template match="ptr">
    <xsl:variable name="link" select="@target/data(.)"/>
    <a href="{$link}" target="_blank">
      <xsl:value-of select="$link"/>
    </a>
  </xsl:template>
  
  
</xsl:stylesheet>