<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="#all">
   
   <!-- Generating XPath expressions for arbitrary nodes -->
   
   <xsl:template mode="xpath" match="/ | node() | @*">
      <xsl:apply-templates select="parent::*" mode="xpath"/>
      <xsl:apply-templates select="." mode="xpath-step"/>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="/" priority="1">
      <xsl:text>/</xsl:text>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="*" name="element-step">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../*[node-name(.)=node-name(current())]"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="text()">
      <xsl:text>/text()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../text()"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="processing-instruction()">
      <xsl:text>/processing-instruction()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../processing-instruction()"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="comment()">
      <xsl:text>/comment()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../comment()"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template name="position-among">
      <xsl:param name="this" select="."/>
      <xsl:param name="set" required="yes"/>
      <xsl:if test="count($set) > 1">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="count($this|$set[. &lt;&lt; $this])"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
   </xsl:template>
   
   <xsl:template mode="xpath-step" match="@*">
      <xsl:text>/@</xsl:text>
      <xsl:value-of select="name()"/>
   </xsl:template>
</xsl:stylesheet>