<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:bib="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns:dbib="http://digitalhumanities.org/dhq/ns/biblio/util"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  version="3.0">
  
<!--
    Zotero's TEI export -> DHQ Biblio records
    
    Ashley M. Clark, for Digital Humanities Quarterly
    2020
  -->
  
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no"/>
  <xsl:mode on-no-match="shallow-skip"/>
  
 <!--  PARAMETERS  -->
  
  <xsl:param name="biblio-genre" select="'BiblioItem'" as="xs:string"/>
  <xsl:param name="relaxng-path" select="'./biblioV3/schema/dhqBiblio.rng'" as="xs:string"/>
  
  
 <!--  GLOBAL VERIABLES  -->
  
  <!-- Biblio items AudiovisualItem, Reference?
    Zotero types Document, Map, Software... -->
  <xsl:variable name="genre-map" select="(
        map {
          'biblioGenre': 'ArchivalItem',
          'zoteroType': (
              'manuscript'
            )
        }, map {
          'biblioGenre': 'Artwork',
          'zoteroType': (
              'artwork'
            )
        }, map {
          'biblioGenre': 'BlogEntry',
          'zoteroType': (
              'blogPost',
              'podcast'
            )
        }, map {
          'biblioGenre': 'Book',
          'zoteroType': (
              'book'
            )
        }, map {
          'biblioGenre': 'BookInSeries',
          'zoteroType': (  'book'  )
        }, map {
          'biblioGenre': 'BookSection',
          'zoteroType': (
              'bookSection'
            )
        }, map {
          'biblioGenre': 'ConferencePaper',
          'zoteroType': (
              'conferencePaper'
            )
        }, map {
          'biblioGenre': 'JournalArticle',
          'zoteroType': (
            'journalArticle',
            'magazineArticle'
          )
        }, map {
          'biblioGenre': 'Other',
          'zoteroType': (
            )
        }, map {
          'biblioGenre': 'PhysicalMedia',
          'zoteroType': (
            )
        }, map {
          'biblioGenre': 'Posting',
          'zoteroType': (
              'forumPost'
            )
        }, map {
          'biblioGenre': 'PublicGov',
          'zoteroType': (
              'bill',
              'case',
              'hearing',
              'patent',
              'statute'
            )
        }, map {
          'biblioGenre': 'Report',
          'zoteroType': (
              'report'
            )
        }, map {
          'biblioGenre': 'Series',
          'zoteroType': (
            )
        }, map {
          'biblioGenre': 'Thesis',
          'zoteroType': (
              'thesis'
            )
        }, map {
          'biblioGenre': 'VideoGame',
          'zoteroType': ()
        }, map {
          'biblioGenre': 'WebSite',
          'zoteroType': (
              'webpage'
            )
        }
      )"/>
  
  
  
 <!--  IDENTITY TEMPLATES  -->
  
  <xsl:template match="text()" mode="#all">
    <xsl:param name="copy-text" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:if test="$copy-text">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>
  
  
 <!--  TEMPLATES, #default mode  -->
  
  <!-- Put each leading processing instruction on its own line. -->
  <xsl:template match="/processing-instruction()">
    <xsl:if test="position() = 1">
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
    <xsl:copy/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">
      <xsl:text>href="</xsl:text><xsl:value-of select="$relaxng-path"/><xsl:text>" </xsl:text>
      <xsl:text>type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
    </xsl:processing-instruction>
    <xsl:apply-templates select="processing-instruction() | node()"/>
  </xsl:template>
  
  <xsl:template match="/biblStruct">
    <!--<xsl:element name="{$biblio-genre}">
      <xsl:apply-templates></xsl:apply-templates>
    </xsl:element>-->
    <xsl:next-match>
      <xsl:with-param name="biblio-genre" select="$biblio-genre"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="listBibl">
    <BiblioSet>
      <!-- Drop area for harvestable entries. -->
      <BiblioSet ready="true">
        <xsl:text> </xsl:text>
      </BiblioSet>
      
      <xsl:apply-templates select="*"/>
    </BiblioSet>
  </xsl:template>
  
  <!-- Zotero bibliographies use <biblStruct>, which simplifies what this stylesheet can say confidently 
    about the Biblio item. -->
  <xsl:template match="biblStruct">
    <xsl:param name="biblio-genre" as="xs:string">
      <xsl:variable name="zoteroType" select="@type" as="xs:string"/>
      <xsl:value-of select="dbib:get-corresponding-biblio-genre($zoteroType)"/>
    </xsl:param>
    <xsl:variable name="needsMacroItem" 
       select="$biblio-genre = ('BookSection', 'ConferencePaper', 'JournalArticle')"/>
    <xsl:variable name="useIssuance"
       select=" if ( $biblio-genre = ('Book', 'ConferencePaper', 'Thesis') ) then 'monographic'
                (:else if ( $biblio-genre = ('JournalArticle') ) then 'continuing':)
                else ()"/>
    <xsl:element name="{$biblio-genre}">
      <xsl:attribute name="dhqID" select="@xml:id"/>
      <xsl:attribute name="ID" select="@xml:id"/>
      <xsl:if test="$useIssuance">
        <xsl:attribute name="issuance" select="$useIssuance"/>
      </xsl:if>
      <xsl:apply-templates select="analytic">
        <xsl:with-param name="genre" select="$biblio-genre" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:choose>
        <xsl:when test="$biblio-genre eq 'BookSection'">
          <book issuance="monographic">
            <xsl:apply-templates select="monogr">
              <xsl:with-param name="genre" select="$biblio-genre" tunnel="yes"/>
            </xsl:apply-templates>
          </book>
        </xsl:when>
        <xsl:when test="$biblio-genre eq 'ConferencePaper'">
          <!-- TODO -->
        </xsl:when>
        <xsl:when test="$biblio-genre eq 'JournalArticle'">
          <journal issuance="continuing">
            <xsl:apply-templates select="monogr">
              <xsl:with-param name="genre" select="$biblio-genre" tunnel="yes"/>
            </xsl:apply-templates>
          </journal>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="monogr">
            <xsl:with-param name="genre" select="$biblio-genre" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <!-- TODO: URLs, DOIs, notes... -->
      <url>
        <xsl:value-of select="@corresp"/>
      </url>
      <xsl:if test="$biblio-genre = 'BiblioItem'">
        <note>
          <xsl:text>Could not determine Biblio genre. Zotero type is </xsl:text>
          <q><xsl:value-of select="@type"/></q>
          <xsl:text>.</xsl:text>
        </note>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="analytic | monogr | imprint">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="biblStruct//title[@level]">
    <!-- There should only be one <title> per group of children. -->
    <xsl:variable name="gi" 
      select="if ( preceding-sibling::title[@level] ) then 'additionalTitle' 
              else 'title'"/>
    <xsl:element name="{$gi}">
      <xsl:call-template name="proceed-allowing-text"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="author | editor">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="biblScope[@unit eq 'issue']">
    <issue>
      <xsl:call-template name="proceed-allowing-text"/>
    </issue>
  </xsl:template>
  <xsl:template match="biblScope[@unit eq 'page']">
    <xsl:variable name="pageSeq" select="tokenize(normalize-space(), ' ?(- ?|, )')"/>
    <startingPage>
      <xsl:value-of select="$pageSeq[1]"/>
    </startingPage>
    <xsl:if test="count($pageSeq) gt 1">
      <endingPage>
        <xsl:value-of select="$pageSeq[last()]"/>
      </endingPage>
    </xsl:if>
  </xsl:template>
  <xsl:template match="biblScope[@unit eq 'volume']">
    <volume>
      <xsl:call-template name="proceed-allowing-text"/>
    </volume>
  </xsl:template>
  
  <xsl:template match="date">
    <xsl:variable name="content" select="normalize-space()"/>
    <date>
      <xsl:if test="$content castable as xs:dateTime or $content castable as xs:date 
                    or $content castable as xs:gYear or $content castable as xs:gYearMonth">
        <xsl:attribute name="when" select="$content"/>
      </xsl:if>
      <xsl:call-template name="proceed-allowing-text"/>
    </date>
  </xsl:template>
  
  <xsl:template match="forename">
    <givenName>
      <xsl:call-template name="proceed-allowing-text"/>
    </givenName>
  </xsl:template>
  
  <xsl:template match="idno">
    <formalID type="{@type}">
      <xsl:call-template name="proceed-allowing-text"/>
    </formalID>
  </xsl:template>
  
  <xsl:template match="name">
    <corporateName>
      <xsl:call-template name="proceed-allowing-text"/>
    </corporateName>
  </xsl:template>
  
  <xsl:template match="respStmt">
    <xsl:param name="genre" as="xs:string?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$genre = ('Artwork', 'Other', 'VideoGame')">
        <creator>
          <xsl:apply-templates/>
        </creator>
      </xsl:when>
      <xsl:when test="$genre = 'BiblioItem'">
        <author>
          <xsl:apply-templates/>
        </author>
      </xsl:when>
      <xsl:otherwise>
        <note>
          <xsl:text>Could not decide on a contribution type for </xsl:text>
          <q><xsl:value-of select="string-join(persName/*, ' ')"/></q>
          <xsl:text>. Responsibility was listed as </xsl:text>
          <q><xsl:value-of select="resp/normalize-space()"/></q>
          <xsl:text>.</xsl:text>
        </note>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="respStmt/persName">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="surname">
    <familyName>
      <xsl:call-template name="proceed-allowing-text"/>
    </familyName>
  </xsl:template>
  
  
 <!--  NAMED TEMPLATES  -->
  
  <xsl:template name="proceed-allowing-text">
    <xsl:apply-templates>
      <xsl:with-param name="copy-text" select="true()" as="xs:boolean" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
 <!--  FUNCTIONS  -->
  
  <xsl:function name="dbib:get-corresponding-biblio-genre" as="xs:string">
    <xsl:param name="zotero-genre" as="xs:string"/>
    <xsl:variable name="mapping" select="$genre-map[?zoteroType = $zotero-genre][1]"/>
    <xsl:variable name="biblioGenre" select="$mapping?biblioGenre"/>
    <xsl:value-of
      select="if ( exists($biblioGenre) ) then $biblioGenre
              else 'BiblioItem'"/>
  </xsl:function>
  
</xsl:stylesheet>