<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:dhqf="https://dhq.digitalhumanities.org/ns/functions"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!--
        This stylesheet generates a webpage containing a list of all DHQ authors and 
        the (public) articles they've written. The output of this transformation 
        should be processed with author_sort.xsl so that the authors appear in 
        alphabetical order.
        
        The other index-generating stylesheet is title_index.xsl .
      -->
    
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    
    <xsl:output method="xhtml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:param name="staticPublishingPath">
        <xsl:value-of select="'../../articles/'"/>
    </xsl:param>
    
    
    <!-- Suppressed elements. This stylesheet is mostly intentional in processing the specific elements 
      desired, in the order we expect. However, it is sometimes useful to process things in a 
      "fall-through" manner, where elements are processed in document order. When we switch to 
      fall-through behavior, suppressing elements ensures we only get the content we really want. -->
    <xsl:template match="journal//*" priority="-1"/>
    <xsl:template match="dhq:authorInfo/dhq:address"/>
    <xsl:template match="dhq:authorInfo/tei:email"/>
    <xsl:template match="dhq:authorInfo/dhq:bio"/>
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    
    <xsl:template match="/">
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="'Author Index'"/>
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
    
    <!-- Generate the author index page's contents. -->
    <xsl:template name="index_main_body">
      <!-- First, generate a <p> for each author in each DHQ article. The IDs of these elements will be 
        used to compile and sort the authors. -->
      <xsl:variable name="individualAuthors" as="node()*">
        <xsl:apply-templates select="//journal"/>
      </xsl:variable>
      <div id="authorIndex">
        <!--<h1>Author Index</h1>-->
        <!--<table id="a2zNavigation" summary="A to Z navigation bar">
          <tr><xsl:call-template name="index"/></tr>
        </table>-->
        <div id="authors">
          <!-- Compile the authors data in $individualAuthors: gather all articles each one is 
            associated with, and sort the authors alphabetically. -->
          <xsl:sequence select="$individualAuthors"/>
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
    
    <!-- Given 1+ string(s), create a single string that can be used as an HTML identifier as well as a 
      sort key. -->
    <xsl:function name="dhqf:make-sortable-id" as="xs:string?">
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
              <xsl:sequence select="dhqf:make-sortable-id(.)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:sequence select="string-join($useStrings, '_')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:function>
    
    <!--  -->
    <xsl:template match="tei:TEI">
        <xsl:param name="issueTitle" as="xs:string?" tunnel="yes"/>
        <xsl:variable name="fileDesc" select="tei:teiHeader/tei:fileDesc"/>
        <xsl:variable name="vol"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='volume'])"/>
        <xsl:variable name="vol_no_zeroes">
            <xsl:variable name="use_vol">
              <xsl:call-template name="get-vol">
                  <xsl:with-param name="vol" select="$vol"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="normalize-space($use_vol)"/>
        </xsl:variable>
        <xsl:variable name="issue"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='issue'])"/>
        <xsl:variable name="articleId"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        <!-- Try to generate a URL to use for this article. -->
        <xsl:variable name="linkUrl" as="xs:string?">
          <xsl:choose>
            <xsl:when test="not($vol_no_zeroes = '') and not($issue = '')">
              <xsl:sequence select="concat($path_to_home,'/vol/',$vol_no_zeroes,'/',$issue,'/',$articleId,'/',$articleId,'.html')"/>
            </xsl:when>
            <!-- If we don't have a usable volume or issue number, output a debugging message and do NOT 
              generate a link. -->
            <xsl:otherwise>
              <xsl:message terminate="no">
                <xsl:text>Article </xsl:text>
                <xsl:value-of select="$articleId"/>
                <xsl:text> has a volume of '</xsl:text>
                <xsl:value-of select="$vol"/>
                <xsl:text>' and an issue of '</xsl:text>
                <xsl:value-of select="$issue"/>
                <xsl:text>'</xsl:text>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Generate the text description of this article. It will be reproduced for each author. -->
        <xsl:variable name="articleTitles" as="node()*">
          <xsl:variable name="hasTitleNotInEnglish" as="xs:boolean" 
            select="exists($fileDesc/tei:titleStmt/tei:title[@xml:lang ne 'en'])"/>
          <xsl:for-each select="$fileDesc/tei:titleStmt/tei:title">
            <xsl:if test="position() > 1">
              <br />
            </xsl:if>
            <xsl:call-template name="get-article-title">
              <xsl:with-param name="link-url" select="$linkUrl"/>
              <xsl:with-param name="article-has-non-english-title" select="$hasTitleNotInEnglish"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        
        <!-- Stopwords filter from Jeni Tennison, http://www.stylusstudio.com/xsllist/200112/post10410.html -->
        <!--<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>-->
        <xsl:variable name="isCoauthor" as="xs:boolean"
          select="count($fileDesc/tei:titleStmt/dhq:authorInfo) > 1"/>
        <xsl:for-each select="$fileDesc/tei:titleStmt/dhq:authorInfo">
            <!--<xsl:variable name="string"
              select="translate(concat(normalize-space(dhq:author_name/dhq:family),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/>-->
            <!-- Generate an identifier for this author using their family name and their first initial. The ID will be used to sort this person. -->
            <xsl:variable name="sortableAuthorId" as="xs:string?">
              <xsl:variable name="familyName" select="dhq:author_name/dhq:family/xs:string(.)"/>
              <xsl:variable name="initial" select="substring(normalize-space(dhq:author_name),1,1)"/>
              <xsl:sequence select="dhqf:make-sortable-id(($familyName, $initial))"/>
            </xsl:variable>
            <xsl:if test="empty($sortableAuthorId) or $sortableAuthorId eq ''">
              <xsl:message select="'Could not create an ID for a DHQ author in '||$articleId"/>
            </xsl:if>
            <p id="{$sortableAuthorId}">
                <xsl:call-template name="author"/>
                <xsl:text> </xsl:text>
                <span class="title">
                  <xsl:copy-of select="$articleTitles"/>
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="$issueTitle"/>
                  <xsl:text>: v</xsl:text><xsl:value-of select="$vol_no_zeroes"/>
                  <xsl:text> n</xsl:text><xsl:value-of select="$issue"/>
                  <xsl:if test="$isCoauthor">
                    <xsl:text>, [co-authored]</xsl:text>
                  </xsl:if>
                </span>
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="author">
      <span class="author">
        <strong>
          <xsl:apply-templates select="dhq:author_name"/>
        </strong>
      </span>
      <xsl:apply-templates select="dhq:affiliation"/>
    </xsl:template>
    
    <!-- If the author name includes a family name, we want it to go first, in "Last, First" format. If 
      the author name doesn't include a family name (e.g. "DHQ editorial team"), the <dhq:family> 
      template won't trigger and the name will simply have its whitespace normalized. -->
    <xsl:template match="dhq:author_name">
      <xsl:apply-templates select="dhq:family"/>
      <xsl:value-of select="normalize-space(string-join(text(), ''))"/>
    </xsl:template>
    
    <xsl:template match="dhq:family">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text>, </xsl:text>
    </xsl:template>
    
    <xsl:template match="dhq:affiliation">
      <span class="affiliation">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
      </span>
    </xsl:template>
    
    <xsl:template match="tei:titleStmt/tei:title | tei:titleStmt/tei:title//*">
      <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template name="get-article-title">
      <!-- The URL to use for this article. -->
      <xsl:param name="link-url" as="xs:string?"/>
      <!-- Whether the article has any title that isn't in English. A default value is set here, but we 
        can save a bit of processing by using a value calculated once at the <TEI> level, instead of 
        calculating per `//fileDesc/titleStmt/title`. -->
      <xsl:param name="article-has-non-english-title" as="xs:boolean" 
        select="exists(../tei:title/@xml:lang != 'en')"/>
      <xsl:variable name="titleLang" select="data(@xml:lang)"/>
      <xsl:variable name="thisTitleIsInEnglish" as="xs:boolean" 
        select="@xml:lang='en' or string-length(@xml:lang)=0"/>
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
          <xsl:apply-templates select="."/>
        </xsl:when>
        <!-- If there's no value for $link-url and this <title> is NOT in English, we wrap the article 
          title in <span> so we can mark the language in use. We can't, however, link to the article.  -->
        <xsl:when test="empty($link-url)">
          <span xml:lang="{$titleLang}" lang="{$titleLang}">
            <xsl:apply-templates select="."/>
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
                <xsl:value-of select="@xml:lang"/>
                <xsl:text>');</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <!-- If this <title> is not in English, we need to mark which language is in use, for 
              accessibility. -->
            <xsl:if test="not($thisTitleIsInEnglish)">
              <xsl:attribute name="xml:lang" select="$titleLang"/>
              <xsl:attribute name="lang" select="$titleLang"/>
            </xsl:if>
            <xsl:apply-templates select="."/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="get-vol">
        <xsl:param name="vol"/>
        <xsl:choose>
            <xsl:when test="substring($vol,1,1) = '0'">
                <xsl:call-template name="get-vol">
                    <xsl:with-param name="vol">
                        <xsl:value-of select="substring($vol,2)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$vol"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
