<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbib="http://digitalhumanities.org/dhq/ns/biblio/util"
  xmlns:bib="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="xs dbib bib"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  version="2.0">
  
  <!--  Extracts bibl listings from a DHQ article and converts them into a rough version of Biblio format,
        providing a rough start at data entry.
        
        Authored by Wendell Piez
        Modified by Ashley M. Clark
    -->
  
  <xsl:strip-space elements="TEI text front body back listBibl"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:variable name="dateRegEx" as="xs:string">[12][0-9]{3}(-[01][0-9](-[0-3][0-9])?)?</xsl:variable>
  <xsl:key name="biblID" match="//listBibl/*" use="concat('#', @xml:id)"/>


<!-- TEMPLATES -->
  
  <xsl:template match="/TEI">
    <!--<xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax</xsl:processing-instruction>
      <xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
      <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"</xsl:processing-instruction>-->
    <xsl:apply-templates select="//back/listBibl"/>
  </xsl:template>
  
  <xsl:template match="listBibl">
    <BiblioSet>
      <!-- Drop area for harvestable entries. -->
      <BiblioSet ready="true">
        <xsl:choose>
          <xsl:when test="bib:*">
            <xsl:copy-of select="bib:*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="xml:space" select="'preserve'"/>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </BiblioSet>
      
      <xsl:apply-templates select="* except bib:*"/>
    </BiblioSet>
  </xsl:template>
  
  <xsl:template match="bibl">
    <BiblioItem dhqID="{@xml:id}" ID="{@xml:id}">
      <xsl:for-each select="@key">
        <xsl:attribute name="ID" select="."/>
      </xsl:for-each>
      <xsl:apply-templates/>
      <xsl:call-template name="add-optional-url"/>
    </BiblioItem>
  </xsl:template>
  
  <!-- Zotero bibliographies use <biblStruct>, which simplifies what this stylesheet can say confidently 
    about the Biblio item. -->
  <xsl:template match="biblStruct">
    <xsl:variable name="zoteroType" select="@type"/>
    <xsl:variable name="biblioGenre" select="
        if ( $zoteroType eq 'webpage' ) then 'WebSite'
        else if ( $zoteroType eq 'blogPost' ) then 'Posting'
        else if ( $zoteroType = ('book', 'bookSection', 'conferencePaper', 'journalArticle') ) then
          concat(upper-case(substring($zoteroType,1,1)), substring($zoteroType,2))
        else 'BiblioItem'
       "/>
    <xsl:variable name="needsMacroItem" select="
        $biblioGenre = ('BookSection', 'ConferencePaper', 'JournalArticle')
       "/>
    <xsl:element name="{$biblioGenre}">
      <xsl:attribute name="dhqID" select="@xml:id"/>
      <xsl:attribute name="ID" select="@xml:id"/>
      <!-- @issuance? -->
      <xsl:apply-templates select="analytic"/>
      <xsl:choose>
        <xsl:when test="$biblioGenre eq 'BookSection'">
          <book>
            <xsl:apply-templates select="monogr"/>
          </book>
        </xsl:when>
        <xsl:when test="$biblioGenre eq 'ConferencePaper'">
          <!-- TODO -->
        </xsl:when>
        <xsl:when test="$biblioGenre eq 'JournalArticle'">
          <journal issuance="continuing">
            <xsl:apply-templates select="monogr"/>
          </journal>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="monogr"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- TODO: URLs, DOIs, notes... -->
      <url>
        <xsl:value-of select="@corresp"/>
      </url>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="analytic | monogr | imprint">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="title">
    <!-- There should only be one <title> per group of children. -->
    <xsl:variable name="gi" 
      select="if ( preceding-sibling::title ) then 'additionalTitle' 
              else 'title'"/>
    <xsl:element name="{$gi}">
      <!-- Throw away rendering information. -->
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:call-template name="add-optional-url"/>
  </xsl:template>
  
  <xsl:template match="emph | foreign | hi[@rend eq 'italic']">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  
  <xsl:template match="hi[@rend eq 'quotes'] | soCalled">
    <q>
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  
  <xsl:template match="pubPlace">
    <place>
      <xsl:apply-templates/>
    </place>
  </xsl:template>
  
  <xsl:template match=" author | editor | publisher | sponsor 
                      | name[@role = ('author', 'editor', 'translator', 'publisher', 'sponsor')]">
    <xsl:variable name="contributorType" 
      select="if ( @role ) then @role/data(.) else local-name()"/>
    <xsl:element name="{$contributorType}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="date">
    <date>
      <xsl:attribute name="when">
        <xsl:choose>
          <xsl:when test="@when">
            <xsl:value-of select="@when"/>
          </xsl:when>
          <xsl:when test="dbib:is-date(normalize-space(.))">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </date>
  </xsl:template>
  
  <!-- Skip empty <date>s. -->
  <xsl:template match="date[not(@*)][not(text())]"/>
  
  <xsl:template match="idno">
    <formalID>
      <xsl:apply-templates/>
    </formalID>
  </xsl:template>
  
  <!-- <tei:ref> becomes <biblio:url>. If the @target doesn't match the text content, two <url>s are 
    created. -->
  <xsl:template match="ref">
    <xsl:variable name="differingTarget" as="xs:string?">
      <xsl:variable name="target" select="@target/data(.)"/>
      <xsl:variable name="normalizedTarget" select="normalize-space(lower-case($target))"/>
      <xsl:value-of 
        select="if ( $normalizedTarget ne normalize-space(lower-case(.)) ) then $target else ()"/>
    </xsl:variable>
    <url>
      <xsl:value-of select="normalize-space(.)"/>
    </url>
    <xsl:if test="$differingTarget">
      <url>
        <xsl:value-of select="normalize-space($differingTarget)"/>
      </url>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ptr">
    <url>
      <xsl:value-of select="@target"/>
    </url>
  </xsl:template>
  
  <!-- If <tei:ptr> links to another entry in the bibliography, copy and process it here as a generic 
    <biblio:macroItem>. -->
  <xsl:template match="ptr[starts-with(@target, '#')]" priority="5">
    <xsl:variable name="macroEntry" select="key('biblID', @target/data(.))"/>
    <xsl:choose>
      <xsl:when test="$macroEntry">
        <macroItem dhqID="{$macroEntry/@xml:id}"><!-- TODO: make <biblioRef> -->
          <xsl:apply-templates select="$macroEntry/node()"/>
        </macroItem>
      </xsl:when>
      <xsl:otherwise>
        <url>
          <xsl:value-of select="@target"/>
        </url>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="title//text() | pubPlace//text() | publisher//text() | date//text()">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- Text within bibliography entries is tested for date strings. -->
  <xsl:template match="listBibl/*/text()">
    <xsl:if test="not(matches(.,'^[\s\p{P}]+$'))">
      <xsl:variable name="ws-collapsed" select="replace(.,'\s+',' ')"/>
      <xsl:analyze-string select="$ws-collapsed" regex="{$dateRegEx}">
        <xsl:matching-substring>
          <date when="{.}">
            <xsl:value-of select="."/>
          </date>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:if>
  </xsl:template>
  
  <!-- Anything not mapped is copied in the Biblio namespace. -->
  <xsl:template match="*">
    <xsl:element name="{local-name()}" namespace="http://digitalhumanities.org/dhq/ns/biblio">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  
<!--  TEMPLATES, named  -->
  
  <xsl:template name="add-optional-url">
    <xsl:if test="@ref">
      <url>
        <xsl:value-of select="@ref"/>
      </url>
    </xsl:if>
  </xsl:template>
  
  
<!--  FUNCTIONS  -->
  
  <!-- Test if a string can be cast as a date of the form YYYY(-MM(-DD)?)?. -->
  <xsl:function name="dbib:is-date" as="xs:boolean">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of
      select=" $string castable as xs:date
            or $string castable as xs:gYear
            or $string castable as xs:gYearMonth"/>
  </xsl:function>
  
</xsl:stylesheet>