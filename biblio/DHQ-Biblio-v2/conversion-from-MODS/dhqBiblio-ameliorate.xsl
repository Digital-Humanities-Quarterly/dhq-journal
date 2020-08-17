<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xs mods"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  version="2.0"
  >


  <xsl:template mode="contents" match="*">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template mode="contents" match="source | journal | publication | book | series">
    <xsl:variable name="first" select="author, editor, creator, translator, contributor, etal,
      title, additionalTitle, publisher, place"/>
    <xsl:variable name="last" select="date"/>
    <xsl:apply-templates select="$first"/>
    <xsl:apply-templates select="* except ($first,$last)"/>
    <xsl:apply-templates select="$last"/>
  </xsl:template>

  <xsl:template mode="contents" match="/*/*">
    <xsl:variable name="contents" select="    
    (creator, author, editor, translator, contributor, etal),
    (title, additionalTitle),
    conference,
    (journal | book | publication | series),
    place,
    publisher,
    date"/>
    <xsl:apply-templates select="$contents"/>
    <xsl:apply-templates select="*/startingPage | */endingPage" mode="copy"/>
    <xsl:apply-templates select="* except $contents"/>
  </xsl:template>
  
  <xsl:template mode="contents" match="journal | book | publication | series | source">
      <xsl:variable name="contents" select="
        (author, editor, contributor, etal),
        (title, additionalTitle),
        volume, issue, place, publisher, date"/>
      <xsl:apply-templates select="$contents"/>
      <xsl:apply-templates select="* except $contents"/>
  </xsl:template>

  <xsl:template match="/" mode="contents">
    <xsl:processing-instruction name="xml-model"> href="dhqBiblio-all.rnc" type="application/relax-ng-compact-syntax"</xsl:processing-instruction>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="JournalArticle/*/startingPage | BookSection/*/startingPage |
                       ConferencePaper/*/startingPage | BookInSeries/*/startingPage"/>
  
  <xsl:template match="JournalArticle/*/endingPage | BookSection/*/endingPage |
                       ConferencePaper/*/endingPage | BookInSeries/*/endingPage"/>
  
  <xsl:template match="BookSection/contributor | JournalArticle/contributor |
    WebSite/contributor | ConferencePaper/contributor" priority="3">
    <author>
      <xsl:call-template name="personalName"/>
    </author>
  </xsl:template>
  
  <xsl:template match="VideoGame/contributor" priority="3">
    <creator>
      <xsl:call-template name="personalName"/>
    </creator>
  </xsl:template>
  
  <xsl:template match="contributor[exists(../author)]" priority="2">
    <author>
      <xsl:call-template name="personalName"/>
    </author>
  </xsl:template>
  
  <xsl:template match="series/contributor" priority="3">
    <editor>
      <xsl:call-template name="personalName"/>
    </editor>
  </xsl:template>
  
  <xsl:template match="author | editor | translator | creator | contributor">
    <xsl:copy>
      <xsl:call-template name="personalName"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="personalName">
    <xsl:apply-templates select="fullName, givenName, familyName"/>
  </xsl:template>
  
  <xsl:template match="/ | * | @*" mode="#default copy">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="." mode="contents"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>