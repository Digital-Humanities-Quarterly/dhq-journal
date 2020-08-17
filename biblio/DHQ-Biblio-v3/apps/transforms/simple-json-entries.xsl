<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbib="http://digitalhumanities.org/dhq/ns/biblio"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="xs dbib" version="2.0">
  
  <!--  A simple transformation of DHQ Biblio datasets into the W3C's XML analogue 
        for JSON.
        
        It is assumed that the result of this transformation will be returned to an
        XQuery, which will transform the XML structure into JSON via the XQuery 3.1
        function xml-to-json(). While XSLT 3.0 offers the same functionality, Saxon
        HE does not yet include XSLT 3.0.
        
        Authored by Ashley M. Clark
        2018-10-01
  -->
  
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  
  
<!--  TEMPLATES  -->
  
  <!-- In JSON, a Biblio Set is an array of Biblio Items, themselves represented as
    objects ("maps" in XPath). -->
  <xsl:template match="BiblioSet">
    <array>
      <xsl:apply-templates/>
    </array>
  </xsl:template>
  
  <!-- Biblio Items are distinguished by their identifiers rather than by their tag 
    names. -->
  <xsl:template match="*[@ID]">
    <map>
      <string key="ID">
        <xsl:value-of select="@ID"/>
      </string>
      <string key="genre">
        <xsl:value-of select="local-name()"/>
      </string>
      <xsl:call-template name="issuance"/>
      <xsl:apply-templates/>
    </map>
  </xsl:template>
  
  <!-- For most XML tags inside a Biblio Item, a JSON string will suffice for 
    representing text content. -->
  <xsl:template match="*[not(@ID)][not(*)]" mode="#default" priority="-5">
    <string>
      <xsl:call-template name="gi-key"/>
      <xsl:apply-templates/>
    </string>
  </xsl:template>
  
  <!-- By default, normalize text nodes. -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space()"/>
  </xsl:template>
  
  <!-- The so-called "macro items" (entities which contain the currently-described 
    Item) are represented by JSON objects just as regular Biblio Items are. -->
  <xsl:template match="book | series | conference | journal | publication">
    <map>
      <xsl:call-template name="gi-key"/>
      <xsl:call-template name="issuance"/>
      <xsl:apply-templates/>
    </map>
  </xsl:template>
  
  <!-- Some tags can be represented as JSON numbers, rather than strings. But they
    should fall back to strings if the content isn't castable as an integer. -->
  <xsl:template match="volume | issue | startingPage | endingPage | totalPages">
    <xsl:variable name="isNum" select="normalize-space() castable as xs:integer"/>
    <xsl:element name="{ if ( $isNum ) then 'number' else 'string' }">
      <xsl:call-template name="gi-key"/>
      <xsl:value-of 
        select="if ( $isNum ) then
                  normalize-space() cast as xs:integer 
                else normalize-space()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- In <date>s, the value of @when (if present) should be preferred over text 
    content. -->
  <xsl:template match="date">
    <string>
      <xsl:call-template name="gi-key"/>
      <xsl:choose>
        <xsl:when test="@when">
          <xsl:value-of select="@when"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </string>
  </xsl:template>
  
  
<!-- TITLE CONTENT -->
  
  <!-- Titles can contain stylistic markup for Biblio display purposes. -->
  <xsl:template match="title">
    <string>
      <xsl:call-template name="gi-key"/>
      <xsl:call-template name="mixed-content"/>
    </string>
  </xsl:template>
  
  <!-- When mixed content is allowed, copy text nodes instead of normalizing them. -->
  <xsl:template match="text()" mode="mixed">
    <xsl:copy/>
  </xsl:template>
  
  <!-- Capture quotation marks but not italics. -->
  <xsl:template match="i" mode="mixed"/><!-- use HTML <em>? -->
  <xsl:template match="q" mode="mixed">
    <xsl:param name="ancestors" select="0" as="xs:integer"/>
    <xsl:variable name="isDoubleQ" select="$ancestors mod 2 eq 0"/>
    <xsl:value-of select="if ( $isDoubleQ ) then '“' else '‘'"/>
    <xsl:apply-templates>
      <xsl:with-param name="ancestors" select="$ancestors + 1"/>
    </xsl:apply-templates>
    <xsl:value-of select="if ( $isDoubleQ ) then '”' else '’'"/>
  </xsl:template>
  
  
<!--  DATA ARRAYS  -->
  
  <xsl:template match="author | editor | translator | creator | etal
                      | additionalTitle | formalID | url | note" priority="-4"/>
  
  <xsl:template match="author[1] | editor[1] | translator[1]| creator[1] 
                      | additionalTitle[1] | formalID[1] | url[1] | note[1]">
    <xsl:call-template name="start-array"/>
  </xsl:template>
  
  <xsl:template match="*" mode="array">
    <string>
      <xsl:apply-templates/>
    </string>
  </xsl:template>
  
  <xsl:template match="additionalTitle" mode="array">
    <string>
      <xsl:call-template name="mixed-content"/>
    </string>
  </xsl:template>
  
  <xsl:template match="author | editor | translator | creator" mode="array">
    <map>
      <xsl:apply-templates/>
    </map>
    <xsl:if test="following-sibling::*[1][self::etal]">
      <string>et al.</string>
    </xsl:if>
  </xsl:template>
  
  
<!--  TEMPLATES, NAMED  -->
  
  <xsl:template name="gi-key">
    <xsl:attribute name="key" select="local-name()"/>
  </xsl:template>
  
  <xsl:template name="issuance">
    <xsl:if test="@issuance">
      <string key="issuance">
        <xsl:value-of select="@issuance"/>
      </string>
    </xsl:if>
  </xsl:template>
  
  <!-- When mixed content is allowed, whitespace normalization should only occur 
    after all templates are applied. -->
  <xsl:template name="mixed-content">
    <xsl:variable name="textContent">
      <xsl:apply-templates mode="mixed"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($textContent)"/>
  </xsl:template>
  
  <xsl:template name="start-array">
    <xsl:variable name="gi" select="local-name()"/>
    <array>
      <xsl:call-template name="gi-key"/>
      <xsl:apply-templates select="., following-sibling::*[local-name() eq $gi]" mode="array"/>
    </array>
  </xsl:template>
  
</xsl:stylesheet>