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
  
  <!--  PARAMETERS  -->
  
  <!-- The relative path from the webpage to the DHQ home directory. The path must not end with a slash. 
    This value is used by this and other stylesheets to construct links relative, if not directly to the 
    current page, then to the DHQ home directory. Because this stylesheet is used for pages throughout 
    DHQ, the value of $path_to_home should be provided by an stylesheet which imports this one. -->
  <xsl:param name="path_to_home" select="''" as="xs:string"/>
  
  
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
  
  <!-- Create a version of the article title suitable for XHTML display. The title is wrapped in an <a> 
    if a link URL is passed in, or if it can be generated from the article metadata. Languages are 
    marked visually and with the appropriate attributes.
    This template is intended to be run from `//titleStmt/title`; for example, as part of a 
    <xsl:for-each>. If called from elsewhere, you should pass in the $title-element manually.
  -->
  <!-- This template (and those in "dhq-article-title" mode) were taken from the revised author_index.xsl -->
  <xsl:template name="get-article-title">
    <xsl:param name="title-element" select=".[self::tei:title]" as="node()"/>
    <!-- The URL to use for this article. -->
    <xsl:param name="link-url" as="xs:string?"/>
    <!-- Whether the article has any title that isn't in English. A default value is set here, but we 
      can save a bit of processing by using a value calculated once at the <TEI> level, instead of 
      calculating per `//fileDesc/titleStmt/title`. -->
    <xsl:param name="article-has-non-english-title" as="xs:boolean" 
      select="exists($title-element/../tei:title/@xml:lang[. ne 'en'])"/>
    <xsl:if test="empty($title-element[self::tei:title[parent::tei:titleStmt]])">
      <xsl:message terminate="yes"
        select="'Template get-article-title should have access to a `//titleStmt/title`!'"/>
    </xsl:if>
    <xsl:variable name="titleLang" select="data($title-element/@xml:lang)"/>
    <xsl:variable name="thisTitleIsInEnglish" as="xs:boolean" 
      select="$titleLang eq 'en' or string-length($titleLang) eq 0"/>
    <!-- Add any language indicators for this <title>. If this title is in English, we only say so if 
      the article also has a title that is NOT in English. -->
    <xsl:choose>
      <xsl:when test="$thisTitleIsInEnglish and $article-has-non-english-title">
        <span class="monospace">[en]</span>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="$thisTitleIsInEnglish">
        <!--<span class="monospace">[en]</span>-->
      </xsl:when>
      <xsl:otherwise>
        <span class="monospace">[<xsl:value-of select="$titleLang"/>]</span>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <!-- If there's no value for $link-url and this <title> is in English, process the element as 
        plaintext. -->
      <xsl:when test="empty($link-url) and $thisTitleIsInEnglish">
        <xsl:apply-templates select="." mode="dhq-article-title"/>
      </xsl:when>
      <!-- If there's no value for $link-url and this <title> is NOT in English, we wrap the article 
        title in <span> so we can mark the language in use. We can't, however, link to the article.  -->
      <xsl:when test="empty($link-url)">
        <span>
          <xsl:call-template name="mark-used-language">
            <xsl:with-param name="language-code" select="$titleLang"/>
          </xsl:call-template>
          <xsl:apply-templates select="$title-element" mode="dhq-article-title"/>
        </span>
      </xsl:when>
      <!-- If there's a URL we can use, output an HTML <a> for navigation. -->
      <xsl:otherwise>
        <a href="{$link-url}">
          <!-- If there is a non-English language title in this article, include some Javascript to 
            set the user's page language in localStorage on click (?) -->
          <xsl:if test="$article-has-non-english-title">
            <xsl:attribute name="onclick">
              <xsl:text>localStorage.setItem('pagelang', '</xsl:text>
              <xsl:value-of select="$titleLang"/>
              <xsl:text>');</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <!-- If this <title> is not in English, we need to mark which language is in use, for 
            accessibility. -->
          <xsl:if test="not($thisTitleIsInEnglish)">
            <xsl:call-template name="mark-used-language">
              <xsl:with-param name="language-code" select="$titleLang"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:apply-templates select="$title-element" mode="dhq-article-title"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
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
  
  <!-- Given a volume, issue, and article number, generate a link to an article. This function uses the 
    value of the $path_to_home parameter to return to the DHQ home directory. -->
  <xsl:function name="dhqf:link-to-article" as="xs:string?">
    <!-- The article ID is placed first because there could be a use for a 1-parameter version of this 
      function which generates a link using information from the TOC. -->
    <xsl:param name="article-id" as="xs:string"/>
    <xsl:param name="volume" as="xs:string?"/>
    <xsl:param name="issue" as="xs:string?"/>
    <xsl:choose>
      <!-- If we don't have a usable volume or issue number, output a debugging message and do NOT 
        generate a link. -->
      <xsl:when test="empty($volume) or normalize-space($volume) eq ''
                    or empty($issue) or normalize-space($issue) eq ''">
        <xsl:message terminate="no">
          <xsl:text>Article </xsl:text>
          <xsl:value-of select="$article-id"/>
          <xsl:text> has a volume of '</xsl:text>
          <xsl:value-of select="$volume"/>
          <xsl:text>' and an issue of '</xsl:text>
          <xsl:value-of select="$issue"/>
          <xsl:text>'</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="vol_no_zeroes" select="dhqf:remove-leading-zeroes($volume)"/>
        <xsl:sequence 
          select="concat($path_to_home,'/vol/',$vol_no_zeroes,'/',$issue,'/',$article-id,'/',$article-id,'.html')"/>
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
  
  
  
  <!--
      SUPPORT TEMPLATES
    -->
  

  <xsl:template match="tei:titleStmt/tei:title | tei:titleStmt/tei:title//*" mode="dhq-article-title">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- Output quotation marks inside an article title. -->
  <xsl:template match="tei:titleStmt/tei:title//tei:q 
                     | tei:titleStmt/tei:title//tei:*[@rend eq 'quotes']" priority="2" mode="dhq-article-title">
    <xsl:variable name="quotePair" select="dhqf:get-quotes(.)"/>
    <xsl:value-of select="$quotePair[1]"/>
    <xsl:apply-templates mode="#current"/>
    <xsl:value-of select="$quotePair[2]"/>
  </xsl:template>
  
  <!-- Mark a change of language within an article title. -->
  <xsl:template match="tei:titleStmt/tei:title//tei:*[@xml:lang]" priority="3" mode="dhq-article-title">
    <span>
      <xsl:call-template name="mark-used-language">
        <xsl:with-param name="language-code" select="@xml:lang"/>
      </xsl:call-template>
      <!-- When an element triggers both quotation marks and a language change, we want this template 
        to trigger first, then the template that will introduce quotation marks. -->
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <!-- Output text nodes within an article title. Any whitespace at the end of the last descendant 
    text node is removed. -->
  <xsl:template match="tei:titleStmt/tei:title//text()" mode="dhq-article-title">
    <xsl:choose>
      <!-- If this text node has a following sibling text node, we don't need to do any calculations. 
        We can just output the node as-is. -->
      <xsl:when test="following-sibling::text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <!-- If there is no following sibling text node, we need to check if this text node is the last 
        one inside the article's <title>. If so, we remove whitespace from the end of the node. (If 
        this text node is all whitespace, <xsl:value-of> will output an empty string.) -->
      <xsl:otherwise>
        <xsl:variable name="titleTextNodes" 
          select="ancestor::tei:title[parent::tei:titleStmt]//text()"/>
        <xsl:value-of select="if ( . is $titleTextNodes[last()] ) then
                                replace(., '\s+$', '')
                              else ."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
</xsl:stylesheet>