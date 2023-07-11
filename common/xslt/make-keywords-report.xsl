<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wwp="http://www.wwp.northeastern.edu/ns/textbase"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
<!--
    Use the output of ../scripts/keywordsScript.py , to insert <keywords> into their
    corresponding DHQ articles. At the same time, generate a report on the migration.
    
    Ash Clark
    2023
  -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml" omit-xml-declaration="no"/>
  
 <!--  PARAMETERS  -->
 <!--  GLOBAL VARIABLES  -->
  
  
 <!--  IDENTITY TEMPLATES  -->
  
  <xsl:template match="*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | text() | comment() | processing-instruction()" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  
 <!--  TEMPLATES, #default mode  -->
  
  <xsl:template match="/all_keywords">
    <table>
      <thead>
        <tr>
          <th>Article no.</th>
          <th>Keywords</th>
          <th>Github link</th>
          <th>Had DHQ keywords already?</th>
          <th>Has CDATA?</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates/>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template match="keywords" priority="2"/>
  
  <xsl:template match="keywords[@corresp][term]" priority="3">
    <xsl:variable name="articleId" select="replace(@corresp, '\.xml$', '')"/>
    <xsl:variable name="articlePath" select="'../../articles/'||$articleId||'/'||$articleId||'.xml'"/>
    <xsl:variable name="hasExistingKeywords" 
      select="exists(doc($articlePath)//keywords[@*[contains(., 'dhq_keywords')]]//item[normalize-space() ne ''])"/>
    <!-- Generate a line for the XHTML report. -->
    <tr>
      <th>
        <xsl:value-of select="$articleId"/>
      </th>
      <td>
        <ol>
          <xsl:for-each select="term">
            <li>
              <xsl:value-of select="@corresp"/>
            </li>
          </xsl:for-each>
        </ol>
      </td>
      <td>
        <a href="https://github.com/Digital-Humanities-Quarterly/dhq-journal/blob/add-keywords/articles/{$articleId}/{$articleId}.xml">XML</a>
      </td>
      <td>
        <xsl:if test="$hasExistingKeywords">
          <strong style="color:purple;">Yes, check existing keywords</strong>
        </xsl:if>
      </td>
      <td>
        <xsl:if test="contains(unparsed-text($articlePath), '![CDATA[')">
          <strong style="color:red;">Yes, needs manual copy-paste</strong>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>