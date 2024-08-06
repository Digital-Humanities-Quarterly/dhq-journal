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
  
  
  <!-- Returns a pair of quote marks appropriate to the language and nesting level.
    This function was originally dhq:quotes() in dhq2html.xsl. -->
  <xsl:function name="dhqf:get-quotes" as="xs:string+">
    <xsl:param name="who" as="node()"/>
    <!-- $langspec is either $who's nearest ancestor w/ xml:lang, or the root element if no @xml:lang is found.
         The point of $langspec is *only* to determine the scope of counting levels. -->
    <xsl:variable name="langspec" select="$who/ancestor-or-self::*[exists(@xml:lang)][last()]"/>
    <!-- $nominal-lang is the value of xml:lang given ('fr','de','jp' etc etc.) or 'en' if none is found (with deference) -->
    <xsl:variable name="nominal-lang" select="if (exists($langspec)) then ($langspec/@xml:lang) else 'en'"/>
    
    <!-- $levels are counted among (inline) ancestors that 'toggle' quotes. -->
    <!-- An intervening $langspec has the effect of turning levels off. So a French quote inside an English
         quote restarts with guillemets, while an English quote inside French restarts with double quote. -->
    <!-- Note in this implementation, we exploit the overlapping requirement between French and English to optimize.
         More languages may require more logic. -->
    
    <!--tei:quote[@rend = 'inline']|tei:called|tei:title[@rend = 'quotes']|tei:q|tei:said|tei:soCalled-->
    <xsl:variable name="scope" select="($langspec | $who/ancestor-or-self::tei:note)[last()]"/>
    <xsl:variable name="levels" select="$who/( ancestor::tei:quote[@rend eq 'inline']
                                             | ancestor::tei:called
                                             | ancestor::soCalled
                                             | ancestor::tei:q
                                             | ancestor::said
                                             | ancestor::tei:title[@rend eq 'quotes']
                                             )[ancestor-or-self::* intersect $scope]"/>
    <!-- $level-count is 0 for an outermost quote; we increment it unless the language is French -->
    <xsl:variable name="level-count" select="count($levels) + (if (starts-with($nominal-lang,'fr')) then 0 else 1) "/>
    <!-- Now level 0 gets guillemet, while odd-numbered levels get double quotes -->
    <xsl:choose>
      <!-- Note we emit pairs of xsl:text b/c we actually want discrete strings, returning a pair -->
      <xsl:when test="$level-count = 0">
        <xsl:text>«</xsl:text>
        <xsl:text>»</xsl:text>
      </xsl:when>
      <xsl:when test="$level-count mod 2 (: odds :)">
        <xsl:text>“</xsl:text>
        <xsl:text>”</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>‘</xsl:text>
        <xsl:text>’</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
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