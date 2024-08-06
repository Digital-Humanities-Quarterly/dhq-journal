<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:dhqf="https://dhq.digitalhumanities.org/ns/functions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!--
        This stylesheet generates a webpage containing an alphabetically-sorted list 
        of all DHQ authors and the (published) articles they've written. It should 
        be run on the DHQ table of contents, toc.xml .
        
        The other index-generating stylesheet is title_index.xsl .
        
        CHANGES:
          2024-07, Ash: Updated to XSLT 3.0 from 1.0, and refactored the stylesheet 
            for readability and maintainability. The navigation bar was changed from
            a table to a list inside <nav>, with ARIA labels for accessibility. 
            Article titles' languages are now marked with @xml:lang and @lang. 
            Authors are now sorted with the Unicode Collation Algorithm at primary 
            strength, which means that characters with diacritics will sort 
            alongside characters that don't have diacritics (e.g. "o" = "ö" = "ŏ").
            The work previously done in author_sort.xsl has been folded into this 
            stylesheet.
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
    <xsl:template match="dhq:authorInfo/dhq:address"/>
    <xsl:template match="dhq:authorInfo/tei:email"/>
    <xsl:template match="dhq:authorInfo/dhq:bio"/>
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    
    <!-- XHTML outer page structure -->
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
      <!-- First, generate a <p> for each author in each DHQ article. -->
      <xsl:variable name="individualAuthors" as="node()*">
        <xsl:apply-templates select="//journal"/>
      </xsl:variable>
      <!-- Next, consolidate all authors so that there is only one per sort key. -->
      <xsl:variable name="consolidatedAuthors" as="node()*">
        <xsl:for-each-group select="$individualAuthors" group-by="@data-sort-key">
          <!-- While we're here, do an initial sort of the authors by their keys. With the Unicode 
            Collation Algorithm at primary strength, characters with diacritics will sort alongside 
            their base characters. -->
          <xsl:sort select="current-grouping-key()" collation="{$sort-collation}"/>
          <!-- Transform only the first <p> for this author, tunneling in all of the article titles 
            with which they're associated. Note that because the TOC is ordered from most recent issue 
            to the earliest issue, titles will appear in reverse chronological order, and the author's 
            most recent affiliation will be shown. -->
          <xsl:variable name="articleTitles" as="node()*"
            select="current-group()//xhtml:span[@class eq 'title']"/>
          <xsl:apply-templates select="current-group()[1]" mode="compilation">
            <xsl:with-param name="all-titles" select="$articleTitles" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
      </xsl:variable>
      <!-- Start generating XHTML for the main page content. -->
      <div id="authorIndex" class="index">
        <h1>Author Index</h1>
        <!-- Create a navigation bar to skip directly to authors whose names start with a given letter. -->
        <nav id="a2zNavigation" class="index-navbar" role="navigation" aria-label="Authors Navigation">
          <ul>
            <!-- For each letter, make sure there are authors associated with that letter. If so, wrap 
              the letter in an <a>; if not, output the letter as plaintext. As of 2024-07, DHQ has 
              authors represented in every letter, but there's no harm in covering the fallback behavior. -->
            <xsl:for-each select="1 to 26">
              <xsl:variable name="alphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
              <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
              <li>
                <xsl:choose>
                  <xsl:when test="exists($consolidatedAuthors[matches(@data-sort-key, '^'||$letter)])">
                    <a id="{$letter}_nav" href="#{$letter}_authors" 
                       aria-label="Names starting with {$letter}">
                      <xsl:value-of select="upper-case($letter)"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="upper-case($letter)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </xsl:for-each>
          </ul>
        </nav>
        <div id="authors">
          <!-- Now, group authors so the index can be navigated alphabetically by letter. -->
          <xsl:for-each-group select="$consolidatedAuthors" group-by="substring(@data-sort-key, 1, 1)" 
             collation="{$sort-collation}">
            <xsl:variable name="letter" select="current-grouping-key()"/>
            <!-- This group only gets a heading if $letter is actually a letter, and NOT, say, an 
              underscore. -->
            <xsl:if test="matches($letter, '\p{L}')">
              <!-- The link needs an ARIA label because the letter alone isn't descriptive of where the 
                link goes. However, the link's ARIA label will be used as the heading's label as well, 
                so we have to provide that as well. 
                There's probably a more accessible way of linking back to the top. Move the link before 
                the <h2>, perhaps? -->
              <h2 id="{$letter}_authors" class="index-group" aria-label="{upper-case($letter)}">
                <a href="#{$letter}_nav" aria-label="Author navigation, letter {$letter}">
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
    
    <!-- This template is run on a singular DHQ article. It produces one <p> for every author who 
      contributed to the article, and includes the article title (represented in all languages 
      available). These <p>s will later be consolidated such that every author has only one entry for 
      their presence throughout DHQ. -->
    <xsl:template match="tei:TEI">
        <xsl:param name="issueTitle" as="xs:string?" tunnel="yes"/>
        <xsl:variable name="fileDesc" select="tei:teiHeader/tei:fileDesc"/>
        <xsl:variable name="vol"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='volume'])"/>
        <xsl:variable name="vol_no_zeroes" 
          select="dhqf:remove-leading-zeroes($vol) => normalize-space()"/>
        <xsl:variable name="issue"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='issue'])"/>
        <xsl:variable name="articleId"
          select="normalize-space($fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        <!-- Try to generate a URL to use for this article. -->
        <xsl:variable name="linkUrl" as="xs:string?">
          <xsl:choose>
            <xsl:when test="not($vol_no_zeroes = '') and not($issue = '')">
              <xsl:sequence 
                select="concat($path_to_home,'/vol/',$vol_no_zeroes,'/',$issue,'/',$articleId,'/',$articleId,'.html')"/>
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
        <xsl:variable name="isCoauthor" as="xs:boolean"
          select="count($fileDesc/tei:titleStmt/dhq:authorInfo) > 1"/>
        <xsl:for-each select="$fileDesc/tei:titleStmt/dhq:authorInfo">
            <!-- Generate a sort key for this author. -->
            <xsl:variable name="sortableAuthorKey" as="xs:string?">
              <xsl:variable name="nameParts" as="xs:string*">
                <xsl:variable name="name" select="dhq:author_name"/>
                <xsl:choose>
                  <!-- If this author has a family name, their sort key will be their family name and 
                    first initial. -->
                  <xsl:when test="exists($name/dhq:family)">
                    <xsl:variable name="familyName" select="$name/dhq:family/normalize-space(.)"/>
                    <xsl:variable name="initial" select="substring($name,1,1)"/>
                    <xsl:sequence select="($familyName, $initial)"/>
                  </xsl:when>
                  <!-- If this author doesn't have a family name, their sort key will be the first word 
                    (bounded by whitespace) in their name. -->
                  <xsl:otherwise>
                    <xsl:sequence select="tokenize(normalize-space($name), ' ')[1]"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:sequence select="dhqf:make-sortable-key($nameParts)"/>
            </xsl:variable>
            <xsl:if test="empty($sortableAuthorKey) or $sortableAuthorKey eq ''">
              <xsl:message select="'Could not create an ID for a DHQ author in '||$articleId"/>
            </xsl:if>
            <p data-sort-key="{$sortableAuthorKey}">
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
    
    <!-- For each <dhq:authorInfo>, we want to mark the author's name and affiliation. -->
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
      <xsl:for-each select="text()">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dhq:family">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text>, </xsl:text>
    </xsl:template>
    
    <xsl:template match="dhq:affiliation">
      <!-- Only include the author's affiliation if there's content in the element. -->
      <xsl:if test="normalize-space(.) ne ''">
        <span class="affiliation">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </span>
      </xsl:if>
    </xsl:template>
    
    
    <!--
        TEMPLATES, "compilation" MODE
        
        Used when combining multiple entries for a single author.
      -->
    
    <!-- Generally we want to keep the XHTML we've already generated as-is. -->
    <xsl:template match="xhtml:*" mode="compilation">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:template>
    
    <!-- Each author's <p> is replaced with a <div class="index_top">. The data attribute is copied 
      forward, for debugging purposes. -->
    <xsl:template match="xhtml:p[@data-sort-key]" mode="compilation">
      <div class="index_top">
        <xsl:copy-of select="@* except @class"/>
        <xsl:apply-templates mode="#current"/>
      </div>
    </xsl:template>
    
    <!-- In the place of this entry's singular article title, we place all titles for every article by 
      this author. -->
    <xsl:template match="xhtml:span[@class eq 'title']" mode="compilation">
      <xsl:param name="all-titles" as="node()*" tunnel="yes"/>
      <!-- Using <xsl:for-each-group> ensures that articles aren't listed twice when they appear in more 
        than one issue (e.g. 000289). -->
      <xsl:for-each-group select="$all-titles" group-by="tokenize(xhtml:a[1]/@href, '/')[last()]">
        <xsl:variable name="uniqueTitle" select="current-group()[1]"/>
        <xsl:text> </xsl:text>
        <!-- The last title should get the "index_bottom" class, which provides extra whitespace between 
          author entries. -->
        <p class="index_{ if ( position() eq count($all-titles) ) then
                            'bottom' 
                          else 'item' }">
          <xsl:copy-of select="$uniqueTitle/(@* except @class)"/>
          <xsl:apply-templates select="$uniqueTitle/node()" mode="#current"/>
        </p>
      </xsl:for-each-group>
    </xsl:template>
    
</xsl:stylesheet>
