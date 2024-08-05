<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  xmlns:dhqf="https://dhq.digitalhumanities.org/ns/functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0">
  
<!--
    Variables, functions, and named templates which are broadly useful throughout 
    the DHQ stylesheets.
    
    Initially compiled by Ash Clark in 2024.
  -->
  
 <!--
      GLOBAL VARIABLES
   -->
  
  <!-- The URI of a collation to use in sorting. With the Unicode Collation Algorithm at primary 
    strength, characters with diacritics will sort alongside their base characters. -->
  <xsl:variable name="sort-collation" 
    select="'http://www.w3.org/2013/collation/UCA?strength=primary'"/>
  
  
 <!--
      NAMED TEMPLATES
   -->
  
  <!-- Create XHTML attributes @xml:lang and @lang to mark the language used. -->
  <xsl:template name="mark-used-language">
    <xsl:param name="language-code" as="xs:string" required="yes"/>
    <xsl:if test="normalize-space($language-code) ne ''">
      <xsl:attribute name="xml:lang" select="$language-code"/>
      <xsl:attribute name="lang" select="$language-code"/>
    </xsl:if>
  </xsl:template>
  
  
  
 <!--
      FUNCTIONS
   -->
  
  
  <!-- Given 1+ string(s), create a single string that can be used as an HTML identifier as well as a 
    sort key. -->
  <xsl:function name="dhqf:make-sortable-key" as="xs:string?">
    <xsl:param name="base-string" as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="exists($base-string) and count($base-string) eq 1">
        <xsl:sequence select="normalize-space($base-string)
                              => translate(' ', '_')
                              => lower-case()
                              => replace('[^\w_-]', '')"/>
      </xsl:when>
      <xsl:when test="exists($base-string)">
        <xsl:variable name="useStrings" as="xs:string*">
          <xsl:for-each select="$base-string">
            <xsl:sequence select="dhqf:make-sortable-key(.)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($useStrings, '_')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  
  <!-- Remove leading zeroes from a volume or article number. 
    (Previously a template named "get-vol".) -->
  <xsl:function name="dhqf:remove-leading-zeroes">
    <xsl:param name="number" as="xs:string"/>
    <xsl:sequence select="replace(normalize-space($number), '^0+', '')"/>
  </xsl:function>
  
</xsl:stylesheet>