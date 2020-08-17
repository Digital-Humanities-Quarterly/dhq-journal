<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Messaging infrastructure -->
  
  <xsl:template name="report">
    <xsl:param name="code">XXX</xsl:param>
    <xsl:variable name="report">
      <xsl:value-of select="$code"/>
      <xsl:text> report for </xsl:text>
      <xsl:call-template name="xpath"/>
      <xsl:text> in document </xsl:text>
      <xsl:value-of select="$id"/>
    </xsl:variable>
    
    <xsl:message>
      <xsl:value-of select="$report"/>
    </xsl:message>
    <xsl:comment>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$report"/>
      <xsl:text> </xsl:text>
    </xsl:comment>
  </xsl:template>
  
       
     
  <!-- XPath-generating code for diagnostics -->

  <xsl:template name="xpath">
    <xsl:for-each select="ancestor::*">
      <xsl:apply-templates select="." mode="xpath-step"/>
    </xsl:for-each>
    <xsl:apply-templates select="." mode="xpath-step"/>
  </xsl:template>

  <xsl:template match="/" mode="xpath-step">/</xsl:template>

  <xsl:template match="*" mode="xpath-step">
    <xsl:text>/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:if test="../*[name()=name(current())][2]">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::*[name()=name(current())])"/>
      <xsl:text>]</xsl:text> </xsl:if>
  </xsl:template>

  <xsl:template match="@*" mode="xpath-step">
    <xsl:text>/</xsl:text>
    <xsl:value-of select="name()"/>
  </xsl:template>

  <xsl:template match="text()" mode="xpath-step">
    <xsl:text>/text()</xsl:text>
    <xsl:if test="../text()[2]">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::text())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="comment()" mode="xpath-step">
    <xsl:text>/comment()</xsl:text>
    <xsl:if test="../comment()[2]">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::comment())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="xpath-step">
    <xsl:text>/processing-instruction()</xsl:text>
    <xsl:if test="../processing-instruction()[2]">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="count(.|preceding-sibling::processing-instruction())"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
