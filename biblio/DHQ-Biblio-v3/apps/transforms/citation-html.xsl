<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- Create HTML citations from DHQ Biblio entries. -->
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml" omit-xml-declaration="yes"/>
  
<!--  PARAMETERS  -->
  
<!--  VARIABLES  -->
  
  <xsl:variable name="valid-items" 
    select="( 'ArchivalItem',
              'Artwork',
              'BlogEntry',
              'Book',
              'BookInSeries',
              'BookSection',
              'ConferencePaper',
              'JournalArticle',
              'Other',
              'PhysicalMedia',
              'Posting',
              'PublicGov',
              'Report',
              'Series',
              'Thesis',
              'VideoGame',
              'WebSite'
            )"/>
  
  
<!--  TEMPLATES  -->
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  
  <!-- Text nodes are not copied unless "text-allowed" mode is used. -->
  <xsl:template match="text()" mode="#default macro"/>
  <xsl:template match="text()" mode="text-allowed">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="*">[]</xsl:template>
  
  <xsl:template match="BiblioSet">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="*[local-name(.) = $valid-items]">
    <xsl:variable name="isFullEntry" select="exists(parent::BiblioSet)"/>
    <xsl:variable name="gi" select="if ( $isFullEntry ) then 'p' else 'span'"/>
    <xsl:variable name="authors" select="author | creator"/>
    <xsl:variable name="editors" select="editor"/>
    <xsl:variable name="translators" select="translator"/>
    <xsl:variable name="primaryContributors"
      select=" if ( $authors )      then $authors 
          else if ( $editors )      then $editors
          else if ( $translators )  then $translators
          else ()"/>
    <xsl:variable name="macroEntity" 
      select="book | bookSeries | conference | journal | publication"/>
    <xsl:element name="{$gi}">
      <xsl:attribute name="class" select="'citation'"/>
      <xsl:attribute name="data-bibid" select="@ID"/>
      <xsl:call-template name="attribution-primary">
        <xsl:with-param name="contributors" select="$primaryContributors"/>
      </xsl:call-template>
      <xsl:call-template name="title-primary"/>
      <xsl:call-template name="publication"/>
      <xsl:apply-templates select="$macroEntity" mode="macro"/>
      <xsl:if test="url">
        <xsl:variable name="linkTarget" select="url/normalize-space(.)"/>
        <a href="{ $linkTarget }" target="_blank">
          <xsl:value-of select="$linkTarget"/>
        </a>
        <xsl:text>.</xsl:text>
      </xsl:if>
      <!--<xsl:call-template name="link-to-biblio-item"/>-->
    </xsl:element>
    <xsl:if test="$isFullEntry">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  
<!-- TEMPLATES, "macro" mode -->
  
  <xsl:template match="book" mode="macro">
    <xsl:apply-templates select="title" mode="text-allowed"/>
    <xsl:choose>
      <xsl:when test="editor">
        <span>
          <xsl:call-template name="attribution-primary">
            <xsl:with-param name="is-macro-entity" select="true()"/>
            <xsl:with-param name="contributors" select="editor"/>
          </xsl:call-template>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="publication"/>
  </xsl:template>
  
  <xsl:template match="journal" mode="macro">
    <xsl:call-template name="title-primary">
      <xsl:with-param name="finishing-sentence" select="false()"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:if test="volume">
      <xsl:apply-templates select="volume" mode="text-allowed"/>
      <xsl:if test="issue">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="issue">
      <xsl:text>no. </xsl:text>
      <xsl:apply-templates select="issue" mode="text-allowed"/>
    </xsl:if>
    <xsl:text> (</xsl:text>
    <xsl:call-template name="publication">
      <xsl:with-param name="finishing-sentence" select="false()"/>
    </xsl:call-template>
    <xsl:text>). </xsl:text>
  </xsl:template>
  
  
<!--  TEMPLATES, named  -->
  
  <xsl:template name="attribution-primary">
    <xsl:param name="is-macro-entity" as="xs:boolean" select="false()"/>
    <xsl:param name="contributors" as="node()*"/>
    <xsl:variable name="countContributors" select="count($contributors)"/>
    <xsl:variable name="lastContributor" select="$contributors[last()]"/>
    <xsl:variable name="has-et-al" 
      select="exists($contributors[following-sibling::*[1][self::etal]])" as="xs:boolean"/>
    <xsl:if test="$contributors">
      <xsl:variable name="attributionStr">
        <xsl:choose>
          <xsl:when test="$is-macro-entity">
            <xsl:variable name="firstContributor" select="$contributors[1]"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="lower-case(dhq:get-contributor-phrase($firstContributor/local-name()))"/>
            <xsl:call-template name="name-contributor">
              <xsl:with-param name="leading-name" select="'given'"/>
              <xsl:with-param name="person" select="$firstContributor"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="name-contributor">
              <xsl:with-param name="leading-name" select="'family'"/>
              <xsl:with-param name="person" select="$contributors[1]"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$countContributors gt 1">
          <xsl:for-each select="subsequence($contributors, 2)">
            <xsl:variable name="thisContributor" select="."/>
            <xsl:text>, </xsl:text>
            <xsl:if test="$thisContributor eq $lastContributor and not($has-et-al)">
              <xsl:text>and </xsl:text>
            </xsl:if>
            <xsl:call-template name="name-contributor">
              <xsl:with-param name="leading-name" select="'given'"/>
              <xsl:with-param name="person" select="$thisContributor"/>
            </xsl:call-template>
            <xsl:if test="$thisContributor eq $lastContributor and $has-et-al">
              <xsl:text>et al</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="not($is-macro-entity) and $contributors[local-name(.) = ('editor', 'translator')]">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="dhq:get-contributor-abbreviation($contributors[1]/local-name())"/>
        </xsl:if>
      </xsl:variable>
      <xsl:value-of select="$attributionStr"/>
      <xsl:if test="not(matches($attributionStr, '\.\s*$'))">
        <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="attribution-secondary">
    <xsl:param name="is-macro-entity" as="xs:boolean" select="false()"/>
    <xsl:param name="contributors" as="node()*"/>
    <xsl:variable name="has-et-al" 
      select="exists($contributors[following-sibling::*[1][self::etal]])" as="xs:boolean"/>
    <xsl:if test="$contributors">
      
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="link-to-biblio-item">
    <xsl:variable name="identifier" select="@ID"/>
    <a href="/dhq/biblio/{$identifier}" target="_blank">
      <xsl:text>[Biblio item </xsl:text>
      <xsl:value-of select="$identifier"/>
      <xsl:text>]</xsl:text>
    </a>
  </xsl:template>
  
  <!-- Construct a name from a contributor element, using a given naming convention. -->
  <xsl:template name="name-contributor">
    <xsl:param name="leading-name" select="'given'" as="xs:string"/>
    <xsl:param name="person" as="node()?"/>
    <span class="contributor">
      <xsl:choose>
        <!-- Single name -->
        <xsl:when test="$person/(corporateName | fullName)">
          <xsl:apply-templates select="$person/*" mode="text-allowed"/>
        </xsl:when>
        <!-- Family name, given name -->
        <xsl:when test="$leading-name eq 'family'">
          <xsl:if test="$person/familyName">
            <xsl:apply-templates select="$person/familyName" mode="text-allowed"/>
            <xsl:if test="$person/givenName">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates select="$person/givenName" mode="text-allowed"/>
        </xsl:when>
        <!-- Given name, family name -->
        <xsl:when test="$leading-name eq 'given'">
          <xsl:apply-templates select="$person/givenName" mode="text-allowed"/>
          <xsl:if test="$person/familyName">
            <xsl:if test="$person/givenName">
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$person/familyName" mode="text-allowed"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Could not build a name from <xsl:value-of select="$person"/></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <xsl:template name="publication">
    <xsl:param name="finishing-sentence" as="xs:boolean" select="true()"/>
    <xsl:if test="place">
      <xsl:value-of select="place/normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="exists(date) or exists(publisher)">
          <xsl:text>: </xsl:text>
        </xsl:when>
        <xsl:when test="not($finishing-sentence)"/>
        <xsl:otherwise>
          <xsl:text>. </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="publisher">
      <xsl:value-of select="publisher/normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="date">
          <xsl:text>, </xsl:text>
        </xsl:when>
        <xsl:when test="not($finishing-sentence)"/>
        <xsl:otherwise>
          <xsl:text>. </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="date">
      <xsl:value-of select="date/normalize-space(.)"/>
      <xsl:if test="$finishing-sentence">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="title-primary">
    <xsl:param name="finishing-sentence" as="xs:boolean" select="true()"/>
    <xsl:variable name="hasMacroEntity" select="dhq:get-macro-entity(.)"/>
    <xsl:variable name="hasAdditionalTitle" select="exists(additionalTitle)"/>
    <xsl:variable name="titleStr">
      <xsl:apply-templates select="title" mode="text-allowed"/>
      <xsl:choose>
        <xsl:when test="$hasAdditionalTitle">
          <xsl:text>,</xsl:text>
        </xsl:when>
        <xsl:when test="not($finishing-sentence)"/>
        <xsl:otherwise>
          <xsl:text>.</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{  if ( $hasMacroEntity or $hasAdditionalTitle ) then 
                            'span'
                          else 'em' }">
      <xsl:attribute name="class" select="'title'"/>
      <xsl:choose>
        <xsl:when test="$hasMacroEntity or $hasAdditionalTitle">
          <xsl:text>“</xsl:text>
          <xsl:value-of select="$titleStr"/>
          <xsl:text>”</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$titleStr"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:if test="additionalTitle">
      <xsl:text> </xsl:text>
      <em class="title">
        <xsl:apply-templates select="additionalTitle" mode="text-allowed"/>
        <xsl:if test="$finishing-sentence">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </em>
    </xsl:if>
    <xsl:if test="$finishing-sentence">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  
<!--  FUNCTIONS  -->
  
  <xsl:function name="dhq:get-contributor-abbreviation">
    <xsl:param name="type" as="xs:string"/>
    <xsl:value-of select=" if ( $type eq 'editor' ) then 'ed' 
                      else if ( $type eq 'translator' ) then 'trans' 
                      else ()"/>
  </xsl:function>
  
  <xsl:function name="dhq:get-contributor-phrase">
    <xsl:param name="type" as="xs:string"/>
    <xsl:value-of select=" if ( $type eq 'editor' ) then 'Edited by ' 
                      else if ( $type eq 'translator' ) then 'Translated by ' 
                      else 'By '"/>
  </xsl:function>
  
  <xsl:function name="dhq:get-macro-entity">
    <xsl:param name="biblio-item" as="node()"/>
    <xsl:copy-of 
      select="$biblio-item/(book | bookSeries | conference | journal | publication)"/>
  </xsl:function>
  
</xsl:stylesheet>