<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://www.digitalhumanities.org/ns/util"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
  
  <!-- Performs a whitespace-normalization pass -->
  
  <!--<xsl:output indent="yes"/>-->
  
  <!--<xsl:template match="/">
    <xsl:apply-templates mode="d:ws-munge"/>
    </xsl:template>-->
  
  <xsl:function name="d:ws-deep-equal" as="xs:boolean">
    <xsl:param name="t1" as="node()"/>
    <xsl:param name="t2" as="node()"/>
    <xsl:variable name="t1-normal">
      <xsl:apply-templates select="$t1" mode="d:munge"/>
    </xsl:variable>
    <xsl:variable name="t2-normal">
      <xsl:apply-templates select="$t2" mode="d:munge"/>
    </xsl:variable>
    <xsl:sequence select="deep-equal($t1-normal,$t2-normal)"/>
  </xsl:function>
  
    
  
  <xsl:template match="*" mode="d:ws-munge">
    <xsl:variable name="stripped">
      <xsl:apply-templates select="."  mode="d:strip"/>
    </xsl:variable>
    <xsl:apply-templates select="$stripped"  mode="d:munge"/>
  </xsl:template>

  <xsl:template match="*|text()"  mode="d:strip">
    <!-- this mode removes any comments or PIs -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates  mode="d:strip"/>
    </xsl:copy>
  </xsl:template>
      
  <xsl:template match="*"  mode="d:munge">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates  mode="d:munge"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template  mode="d:munge" priority="2"
    match="text()[not(preceding-sibling::node()|following-sibling::node())]">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template  mode="d:munge"
    match="text()[not(preceding-sibling::node())]">
    <xsl:variable name="t" select="replace(.,'^\s+','')"/>
    <xsl:value-of select="replace($t,'\s+',' ')"/>
  </xsl:template>
  
  <xsl:template  mode="d:munge"
    match="text()[not(following-sibling::node())]">
    <xsl:variable name="t" select="replace(.,'\s+$','')"/>
    <xsl:value-of select="replace($t,'\s+',' ')"/>
  </xsl:template>
  
  <xsl:template  mode="d:munge"
    match="text()">
    <xsl:value-of select="replace(.,'\s+',' ')"/>
  </xsl:template>
  
  <xsl:template match="*[d:element-content(.)]"  mode="d:munge">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- if an element is specified as containing only element
        content, text nodes are skipped -->
      <xsl:apply-templates select="*"  mode="d:munge"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="d:element-content" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:apply-templates select="$e" mode="d:element-content"/>
  </xsl:function>
  
  <xsl:template mode="d:element-content" as="xs:boolean"
    match="*">
    <xsl:sequence select="false()"/>
  </xsl:template>
  
  <!--<xsl:template mode="d:element-content" as="xs:boolean"
    match="*[empty(text()[normalize-space(.)])]">
    <!-\- elements that don't contain text -\->
    <xsl:sequence select="true()"/>
  </xsl:template>-->
  
  <xsl:template mode="d:element-content" as="xs:boolean"
    match="tei:encodingDesc | tei:classDecl | tei:taxonomy">
    <!-- elements that may not contain text -->
    <xsl:sequence select="true()"/>
  </xsl:template>
  
  
</xsl:stylesheet>
