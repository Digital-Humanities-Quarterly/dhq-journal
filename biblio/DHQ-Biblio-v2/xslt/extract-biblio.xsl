<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  version="2.0">
  
<!--  Extracts bibl listings from a DHQ article and converts them into a rough version of Biblio format,
      providing a rough start at data entry. -->
  
  <xsl:strip-space elements="TEI text front body back listBibl"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <!--<?xml-model href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax"?>
    <?xml-model href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    <?xml-stylesheet type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"?>-->
    <xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"</xsl:processing-instruction>
    <xsl:apply-templates select="//back/listBibl"/>
  </xsl:template>
  
  <xsl:template match="listBibl">
    <BiblioSet>
      <xsl:apply-templates/>
      </BiblioSet>
  </xsl:template>
  
  <xsl:template match="listBibl/*">
    <BiblioItem dhqID="{@xml:id}">
       <xsl:for-each select="@key">
          <xsl:attribute name="ID" select="."/>
       </xsl:for-each>
      <xsl:apply-templates/>
    </BiblioItem>
  </xsl:template>
  
  <!-- ref becomes url -->
  <xsl:template match="ref">
    <url>
      <!-- Copying @target unless it is also given as the element contents -->
      <xsl:copy-of select="@target[not(normalize-space(.) = normalize-space(current()))]"/>
      <xsl:value-of select="normalize-space(.)"/>
    </url>
  </xsl:template>


   <xsl:template match="title">
      <!-- throwing away rendering information -->
      <title>
         <xsl:apply-templates/>
      </title>
   </xsl:template>
   
  <xsl:template match="pubPlace">
    <place>
      <xsl:apply-templates/>
    </place>
  </xsl:template>
  
   <xsl:template match="publisher">
      <publisher>
         <xsl:apply-templates/>
      </publisher>
   </xsl:template>
   
   
  <xsl:template match="title//text() | pubPlace//text() | publisher//text() | date//text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
  
   <xsl:variable name="dateRegEx" as="xs:string">[12][0-9]{3}</xsl:variable>
   
   <!--<xsl:template match="text()[matches(.,$dateRegEx)]">
      <date>
         <xsl:value-of select="."/>
      </date>
   </xsl:template>-->
  <xsl:template match="listBibl/*/text()">
    <xsl:if test="not(matches(.,'^[\s\p{P}]+$'))">
      <FIXME>
        <xsl:variable name="ws-collapsed" select="replace(.,'\s+',' ')"/>
        <xsl:analyze-string select="$ws-collapsed" regex="{$dateRegEx}">
          <xsl:matching-substring>
            <date>
              <xsl:value-of select="."/>
            </date>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </FIXME>
    </xsl:if>
  </xsl:template>
  
  <!-- Anything not mapped is copied in the Biblio namespace. -->
  <xsl:template match="*">
    <xsl:element name="{local-name()}" namespace="http://digitalhumanities.org/dhq/ns/biblio">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>