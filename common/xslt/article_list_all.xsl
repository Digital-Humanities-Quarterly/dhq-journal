<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace=""
  exclude-result-prefixes="#all"
  version="3.0">
  
<!--
    Using article_list.xsl , generate a list of all DHQ articles for each sort 
    method and each sort direction. These lists are intended for use in DHQ's 
    Internal Preview.
    
    This stylesheet just runs several transformations on the TOC and saves its 
    results in the proofing directory, without creating any output itself.
    
    Ash Clark
    2024
  -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xml" omit-xml-declaration="no"/>
  
 <!--
      PARAMETERS
   -->
  
  <!-- The base URL for DHQ. Passed on to the article HTML transformations. -->
  <xsl:param name="context" select="'dhq'" as="xs:string"/>
  
  <!-- The directory to which the proof-able DHQ site will be saved. -->
  <xsl:param name="proofing-dir" as="xs:string" required="yes"/>
  
  
 <!--
      GLOBAL VARIABLES
   -->
  
  <!-- The document node of this TOC file is retained here for transformation. -->
  <xsl:variable name="toc-source" select="/"/>
  
  
  
 <!--
      TEMPLATES
   -->
  
  <xsl:template match="/toc">
    <!-- The list of articles with the default sort method ("id") are not labeled as 
        such in the filename: -->
    <!-- articles.html is sorted by ID in ascending order. -->
    <xsl:call-template name="generate-list">
      <xsl:with-param name="outputFileName" select="'articles.html'"/>
    </xsl:call-template>
    <!-- articles_desc.html is sorted by ID in descending order. -->
    <xsl:call-template name="generate-list">
      <xsl:with-param name="sort-direction" select="'desc'"/>
      <xsl:with-param name="outputFileName" select="'articles_desc.html'"/>
    </xsl:call-template>
    
    <!-- Also generate lists of articles sorted by issue and title, in ascending and 
      descending order. -->
    <xsl:for-each select="('issue', 'title')">
      <xsl:variable name="sortMethod" select="."/>
      
      <xsl:for-each select="('asc', 'desc')">
        <xsl:variable name="sortDirection" select="."/>
        <xsl:call-template name="generate-list">
          <xsl:with-param name="sort-method" select="$sortMethod"/>
          <xsl:with-param name="sort-direction" select="$sortDirection"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  
 <!--
      NAMED TEMPLATES
   -->
  
  <!-- Use article_list.xsl to generate a list of DHQ articles for the given sort 
    settings and filename. -->
  <xsl:template name="generate-list">
    <xsl:param name="sort-method" select="'id'" as="xs:string"/>
    <xsl:param name="sort-direction" select="'asc'" as="xs:string"/>
    <xsl:param name="outputFileName" as="xs:string"
      select="concat('articles_',$sort-method,
                    if ($sort-direction eq 'desc') then '_'||$sort-direction else ''
                    ,'.html')"/>
    <xsl:variable name="filepath" select="'editorial/'||$outputFileName"/>
    <!-- Define the XSL transformation that needs to occur. -->
    <xsl:variable name="xslOptionMap" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'cache'" select="true()"/>
        <xsl:map-entry key="'source-node'" select="$toc-source"/>
        <xsl:map-entry key="'stylesheet-location'" select="'article_list.xsl'"/>
        <xsl:map-entry key="'stylesheet-params'">
          <xsl:map>
            <xsl:map-entry key="QName( (),'sort')" select="$sort-method"/>
            <xsl:map-entry key="QName( (),'direction')" select="$sort-direction"/>
            <xsl:map-entry key="QName( (),'fpath')" select="$filepath"/>
            <xsl:map-entry key="QName( (),'context')" select="$context"/>
            <xsl:map-entry key="QName( (),'doProofing')" select="true()"/>
            <xsl:map-entry key="QName( (),'path_to_home')" select="'..'"/>
          </xsl:map>
        </xsl:map-entry>
      </xsl:map>
    </xsl:variable>
    <!-- Run the transformation and save the result to the $proofing-dir. -->
    <xsl:result-document href="{$proofing-dir}/{$filepath}" method="xhtml">
      <xsl:sequence select="transform($xslOptionMap)?output"/>
    </xsl:result-document>
  </xsl:template>
  
</xsl:stylesheet>