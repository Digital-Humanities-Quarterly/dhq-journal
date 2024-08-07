<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:dhqf="https://dhq.digitalhumanities.org/ns/functions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" 
    version="3.0">
    
    <!--
        This stylesheet generates a webpage containing a list of all (public) 
        articles in DHQ, sorted alphabetically by title. The stylesheet should be 
        run on the DHQ table of contents, toc.xml .
        
        The other index-generating stylesheet is author_index.xsl .
      -->
    
    
    <xsl:output method="xhtml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <!--  IMPORTED STYLESHEETS  -->
    <xsl:import href="common-components.xsl"/>
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    
    <!--  PARAMETERS  -->
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:param name="staticPublishingPath" select="'../../articles/'"/>
    
    <!--  GLOBAL VARIABLES  -->
    <!-- Lower-cased words which, for sorting purposes, should be removed from the beginning of titles. 
      If the stopword is a full word, add a space after it. Articles like "l'" should have no space 
      after. -->
    <xsl:variable name="stopword-map" as="map(*)">
      <xsl:variable name="apos" as="xs:string">'</xsl:variable>
      <xsl:sequence select="map {
                              'de': ( 'der ', 'die ', 'das ', 'ein ', 'eine ' ),
                              'en': ( 'the ', 'an ', 'a ' ),
                              'es': ( 'el ', 'la ', 'los ', 'las ', 
                                      'un ', 'una ', 'unos ', 'unas ' ),
                              'fr': ( 'le ', 'la ', 'l'||$apos, 'les ', 
                                      'un ', 'une ', 'des ' ),
                              'pt': ( 'o ', 'a ', 'os ', 'as ',
                                      'um ', 'uma ', 'uns', 'umas ' )
                            }"/>
    </xsl:variable>
    
    
    <!--
      TEMPLATES, #default MODE
      
      Most of the stylesheet occurs in default mode. From the articles listed in the TOC, the articles' 
      XML is used to generate a sequence of author entries. These entries are then made unique and 
      comprehensive, and sorted to create the full XHTML index.
      -->
    
    <!-- Suppressed elements. This stylesheet is mostly intentional in processing the specific elements 
      desired, in the order we expect ("pull" processing). However, it is sometimes useful to process 
      things in a "push" manner, where elements are processed in document order. When we switch to 
      fall-through behavior, suppressing elements ensures we only get the content we really want. -->
    <xsl:template match="journal//*" priority="-1"/>
    <xsl:template match="dhq:authorInfo/dhq:address
                        |dhq:authorInfo/tei:email
                        |tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    
    <!-- XHTML outer page structure -->
    <xsl:template match="/">
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="'Title Index'"/>
            </xsl:call-template>
            <body>
                <!-- Call different templates to put the banner, footer, top and side navigation elements -->
                <xsl:call-template name="topnavigation"/>
                <div id="main">
                    <div id="leftsidebar">
                        <xsl:call-template name="sidenavigation"/>
                    </div>
                    <div id="mainContent">
                        <xsl:call-template name="sitetitle"/>
                        <!-- Rest of the document/article is covered in this template, defined in this stylesheet -->
                        <xsl:call-template name="index_main_body"/>
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- Generate the title index page's contents. -->
    <xsl:template name="index_main_body">
      <!-- First, generate a <p> for each DHQ article's title(s). -->
      <xsl:variable name="individualTitles" as="node()*">
        <xsl:apply-templates select="//journal"/>
      </xsl:variable>
      <!-- Next, make sure that each title is only represented once, and sort them. -->
      <xsl:variable name="uniqueTitles" as="node()*">
        <xsl:for-each-group select="$individualTitles" group-by="@data-sort-key" 
           collation="{$sort-collation}">
          <!-- While we're here, do an initial sort of the titles by their keys. With the Unicode 
            Collation Algorithm at primary strength, characters with diacritics will sort alongside 
            their base characters. -->
          <xsl:sort select="current-grouping-key()" collation="{$sort-collation}"/>
          <xsl:sequence select="current-group()[1]"/>
        </xsl:for-each-group>
      </xsl:variable>
      <!-- Start generating XHTML for the main page content. -->
      <div id="titleIndex">
        <h1>Title Index</h1>
        <!-- Create a navigation bar to skip directly to authors whose names start with a given letter. -->
        <nav id="a2zNavigation" class="index-navbar" role="navigation" aria-label="Titles Navigation">
          
        </nav>
        <div id="titles">
          <!-- Now, group and sort the XHTML $individualTitles so the index can be navigated 
            alphabetically by letter. -->
          <xsl:for-each-group select="$uniqueTitles" group-by="substring(@data-sort-key, 1, 1)" 
             collation="{$sort-collation}">
            <!-- Make sure that articles starting with letters that aren't the Latin A to Z appear at 
              the top, before any headings. -->
            <xsl:sort select="matches(current-grouping-key(), '[a-z]')" collation="{$sort-collation}"/>
            <xsl:variable name="letter" select="current-grouping-key()"/>
            <!-- This group only gets a heading if $letter is actually a letter, and NOT, say, an 
              underscore. -->
            <xsl:if test="matches($letter, '[a-z]')">
              <!-- The link needs an ARIA label because the letter alone isn't descriptive of where the 
                link goes. However, the link's ARIA label will be used as the heading's label as well, 
                so we have to provide that as well. 
                There's probably a more accessible way of linking back to the top. Move the link before 
                the <h2>, perhaps? -->
              <h2 id="{$letter}_titles" class="index-group" aria-label="{upper-case($letter)}">
                <a href="#{$letter}_nav" aria-label="Title navigation, letter {$letter}">
                  <xsl:value-of select="upper-case($letter)"/>
                </a>
              </h2>
            </xsl:if>
            <xsl:sequence select="current-group()"/>
          </xsl:for-each-group>
        </div>
      </div>
    </xsl:template>
    
    <!-- Apply templates on the contents of <journal>, but pass on a tunneled parameter with the title 
      of the issue, if one exists. -->
    <xsl:template match="journal">
      <xsl:apply-templates>
        <xsl:with-param name="issueTitle" select="title/normalize-space(.)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:template>
    
    <!-- Skip any items in the Internal Preview area of the TOC. -->
    <xsl:template match="journal[@editorial]" priority="5"/>
    
    <!-- Open a listed article's XML and use the metadata in its <teiHeader> to generate HTML. -->
    <xsl:template match="item">
      <xsl:variable name="articlePath" select="concat($staticPublishingPath,@id,'/',@id,'.xml')"/>
      <xsl:choose>
        <xsl:when test="doc-available($articlePath)">
          <xsl:apply-templates select="doc($articlePath)/tei:TEI"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="'Could not find article '||@id||' at '||$articlePath"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <!-- Continue to apply templates on the content of <list>s and <cluster>s. -->
    <xsl:template match="list | cluster">
      <xsl:apply-templates/>
    </xsl:template>
    
    <!-- This template is run on a singular DHQ article. -->
    <xsl:template match="tei:TEI">
        <xsl:param name="issueTitle" as="xs:string?" tunnel="yes">
          <!--<xsl:apply-templates select="document('../../toc/toc.xml')//journal[@vol=$vol_no_zeroes and @issue=$issue]/title"/>-->
        </xsl:param>
        <xsl:variable name="fileDesc" select="tei:teiHeader/tei:fileDesc"/>
        <xsl:variable name="vol" 
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='volume'])"/>
        <xsl:variable name="issue"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='issue'])"/>
        <xsl:variable name="articleId" 
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        <xsl:variable name="vol_no_zeroes" 
          select="dhqf:remove-leading-zeroes($vol) => normalize-space()"/>
        <!-- Try to generate a URL to use for this article. -->
        <xsl:variable name="linkUrl" as="xs:string?" 
          select="dhqf:link-to-article($articleId, $vol, $issue)"/>
        
        <xsl:for-each select="$fileDesc/tei:titleStmt/tei:title">
          <xsl:variable name="title" as="node()*">
            <xsl:variable name="hasTitleNotInEnglish" as="xs:boolean" 
              select="exists($fileDesc/tei:titleStmt/tei:title[@xml:lang ne 'en'])"/>
            <xsl:call-template name="get-article-title">
              <xsl:with-param name="link-url" select="$linkUrl"/>
              <xsl:with-param name="article-has-non-english-title" select="$hasTitleNotInEnglish"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="sortTitle" 
            select="dhqf:remove-leading-stopwords(., ancestor-or-self::*[@xml:lang][1]/@xml:lang/data(.))
                    => dhqf:make-sortable-key()"/>
          <xsl:variable name="apos">'</xsl:variable>
          <div class="ptext" data-sort-key="{$sortTitle}">
            <span>
              <xsl:sequence select="$title"/>
              <xsl:text>, </xsl:text>
              <xsl:value-of select="$issueTitle"/>
              <xsl:text>: v</xsl:text>
              <xsl:value-of select="$vol_no_zeroes"/>
              <xsl:text> n</xsl:text>
              <xsl:value-of select="$issue"/>
            </span>
            <div class="authors">
              <xsl:for-each select="../dhq:authorInfo">
                <xsl:value-of select="normalize-space(dhq:author_name)"/>
                <xsl:if test="dhq:affiliation">
                  <xsl:value-of select="', '"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(dhq:affiliation)"/>
                <xsl:if test="not(position() = last())">
                  <xsl:value-of select="'; '"/>
                </xsl:if>
              </xsl:for-each>
            </div>
          </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dhq:authorInfo/dhq:author_name">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::dhq:affiliation">
            <xsl:value-of select="', '"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dhq:authorInfo/dhq:affiliation">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    
  <!--
      FUNCTIONS
    -->
    
    <!-- Given an element and a language code, produce a version of the string suitable for sorting, by
      lower-casing it, normalizing its whitespace, and finally, removing its leading stopwords. -->
    <xsl:function name="dhqf:remove-leading-stopwords" as="xs:string">
      <xsl:param name="element" as="node()"/>
      <xsl:param name="language-code" as="xs:string?"/>
      <!-- If $language-code isn't provided, fallback on any @xml:lang on $element, then on English. -->
      <xsl:variable name="useLang" select="($language-code, $element/@xml:lang, 'en')[1]" as="xs:string"/>
      <!-- If $element's first child with non-whitespace content is an element with @xml:lang on it, 
        we'll need to run this function on that element instead. -->
      <xsl:variable name="childWithLang" 
        select="$element/node()[normalize-space(.) ne ''][1][self::*][@xml:lang]"/>
      <xsl:variable name="string" select="xs:string($element)" as="xs:string"/>
      <xsl:choose>
        <!-- If $childWithLang exists, run this function on that element, and concatenate the result 
          with the rest of $element. -->
        <xsl:when test="exists($childWithLang)">
          <xsl:sequence 
              select="dhqf:remove-leading-stopwords($childWithLang, $childWithLang/@xml:lang/data(.))
                      || string-join($childWithLang/following-sibling::node(), '')"/>
        </xsl:when>
        <!-- If the provided language code matches one of those in $stopword-map, we have stopwords that 
          may be removed from the beginning of the input string. -->
        <xsl:when test="$useLang = map:keys($stopword-map)">
          <xsl:variable name="cleanerStr" select="lower-case(normalize-space($string))"/>
          <xsl:variable name="langStopwordSeq" select="map:get($stopword-map, $useLang)"/>
          <xsl:variable name="regex" select="'^('||string-join($langStopwordSeq, '|')||')'"/>
          <xsl:sequence select="replace($cleanerStr, $regex, '')"/>
        </xsl:when>
        <!-- By default, simply return the input string as-is. -->
        <xsl:otherwise>
          <xsl:sequence select="$string"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
  
</xsl:stylesheet>
