<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  exclude-result-prefixes="#all" 
  version="3.0">
  
  <!--
      This stylesheet generates a webpage containing a table of all DHQ articles in 
      the TOC, sorted by ID, volume+issue, or title. It includes the preview and 
      internal (unpublished) articles, as well as test/example articles. It is 
      intended for proofing by DHQ editors.
    -->
  
  <xsl:import href="sidenavigation.xsl"/>
  <xsl:import href="topnavigation.xsl"/>
  <xsl:import href="footer.xsl"/>
  <xsl:import href="head.xsl"/>
  <xsl:import href="dhq2html.xsl"/>
  
  <xsl:output method="xhtml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
  
  <xsl:param name="fpath"/>
  <xsl:param name="sort" select="'id'" as="xs:string"/>
  <xsl:param name="direction" select="'asc'" as="xs:string"/>
  
  
  <xsl:template match="/">
    <html>
      <!-- code to retrieve document title from the html file and pass it to the template -->
      <xsl:call-template name="head">
        <xsl:with-param name="title" select="'Article List'"/>
      </xsl:call-template>
      <body>
        <!-- Call different templates to put the banner, footer, top and side navigation elements -->
        <xsl:call-template name="topnavigation"/>
        <div id="main">
          <div id="leftsidebar">
            <xsl:call-template name="sidenavigation"/>
            <!-- moved tapor toolbar to the article level toolbar in dhq2html xslt -->
          </div>
          <div id="mainContent">
            <p>&lt;&lt; <a href="index.html">Back to Editorial Table of Contents</a></p>
            <h1>Article List</h1>
            <table summary="article list" id="article_list">
              <tr id="heading">
                <th><xsl:choose><xsl:when test="$sort='id'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles.html">&#9650;</a><br/>Article Number</xsl:when><xsl:otherwise>Article Number<br/><a href="/dhq/editorial/articles_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles.html">Article Number</a></xsl:otherwise></xsl:choose></th>
                <th><xsl:choose><xsl:when test="$sort='issue'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles_issue.html">&#9650;</a><br/>Vol/Issue</xsl:when><xsl:otherwise>Vol/Issue<br/><a href="/dhq/editorial/articles_issue_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles_issue.html">Vol/Issue</a></xsl:otherwise></xsl:choose></th>
                <th><xsl:choose><xsl:when test="$sort='title'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles_title.html">&#9650;</a><br/>Title</xsl:when><xsl:otherwise>Title<br/><a href="/dhq/editorial/articles_title_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles_title.html">Title</a></xsl:otherwise></xsl:choose></th>
                <th>Authors</th>
              </tr>
              <xsl:call-template name="make-rows-for-all-articles"/>
            </table>
            <p>&lt;&lt; <a href="index.html">Back to Editorial Table of Contents</a></p>
            <!-- Use the URL generated to pass to the footer -->
            <xsl:call-template name="footer">
              <xsl:with-param name="docurl" select="$fpath"/>
            </xsl:call-template>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- Generate a sorted sequence of rows for all DHQ articles in the TOC. -->
  <xsl:template name="make-rows-for-all-articles">
    <!-- Sort the articles by ID, or by volume and issue. Rather than sort by title 
      here, we sort again after the rows have been created, drawing in data from the 
      articles' XML. -->
    <xsl:variable name="allRows" as="node()*">
      <xsl:choose>
        <xsl:when test="$sort eq 'id'">
          <xsl:for-each select="//item">
            <xsl:sort select="@id"/>
            <xsl:call-template name="make-row-for-article"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="//item">
            <xsl:sort select="ancestor::journal/@vol/xs:integer(.)"/>
            <xsl:sort select="ancestor::journal/@issue/xs:integer(.)"/>
            <xsl:call-template name="make-row-for-article"/>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Now that we've got a sequence of rows, we can sort by title if that was 
      requested. Otherwise, we just use the existing sequence from $allRows. -->
    <xsl:variable name="allRows" as="node()*">
      <xsl:choose>
        <xsl:when test="$sort eq 'title'">
          <!-- Construct a regular expression to remove stopwords from the beginning 
            of the title. -->
          <xsl:variable name="stopwordsRegex">
            <xsl:variable name="stoplist" 
              select="doc('../../toc/stoplist.xml')/stoplist/ignore/xs:string(.)"/>
            <xsl:sequence select="'^('||string-join($stoplist, '|')||')'"/>
          </xsl:variable>
          <xsl:variable name="punctuationToRemove"
            >[/\].,+-=*~@#$%^(){}`"'!?&amp;&lt;&gt;</xsl:variable>
          <!-- The sort key of each row will be the contents of its "Title" cell: 
            lower-cased, with whitespace normalized, punctuation removed, and 
            stopwords removed from the beginning of the title. -->
          <xsl:sequence select="sort($allRows, (), function ($row) {
              $row//*:td[3]/lower-case(.)
                => normalize-space()
                => translate($punctuationToRemove, '')
                => replace($stopwordsRegex, '')
            })"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$allRows"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Now, if the request was for rows in "descending" order, we can just reverse 
      the sequence. Otherwise, we return the sequence of rows as-is. -->
    <xsl:choose>
      <xsl:when test="$direction eq 'desc'">
        <xsl:sequence select="reverse($allRows)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$allRows"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Create a row representing one DHQ article. -->
  <xsl:template name="make-row-for-article">
    <xsl:variable name="id" select="@id/data(.)"/>
    <xsl:variable name="vol" select="ancestor::journal/@vol/data(.)"/>
    <xsl:variable name="issue" select="ancestor::journal/@issue/data(.)"/>
    <xsl:variable name="path" select="concat('../../articles/',$id,'/',$id,'.xml')"/>
    <xsl:variable name="isInternalArticle" as="xs:boolean"
      select="exists(ancestor::journal/@editorial)"/>
    <xsl:variable name="isPreviewArticle" as="xs:boolean"
      select="exists(ancestor::journal/@preview)"/>
    <tr>
      <xsl:choose>
        <!-- When the article is not available on the expected path, we can fill in 
          the ID but nothing else. -->
        <xsl:when test="not(doc-available($path))">
          <!-- 2024: Ash changed these from @class="center" to inline CSS, because 
            the "center" class includes a `display: block;` rule that was causing 
            the cells to group up vertically. -->
          <td style="text-align:center;"><xsl:value-of select="@id"/></td>
          <td style="text-align:center;">[N/A]</td>
          <td>[N/A]</td>
          <td>[N/A]</td>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="article" select="doc($path)"/>
          <!-- ID column -->
          <td style="text-align:center;">
            <xsl:value-of select="@id"/>
          </td>
          <!-- Volume / issue column -->
          <td style="text-align:center;">
            <xsl:choose>
              <xsl:when test="$isInternalArticle">
                <a href="/dhq/editorial/index.html">Editorial</a>
              </xsl:when>
              <xsl:when test="$isPreviewArticle">
                <a href="/dhq/preview/index.html">
                  <xsl:value-of select="'v'||$vol||'n'||$issue"/>
                </a>
                <br/>
                <xsl:text>(Preview)</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <a href="{concat('/dhq/vol/',$vol,'/',$issue,'/index.html')}">
                  <xsl:value-of select="'v'||$vol||'n'||$issue"/>
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <!-- Title column (with article link) -->
          <td>
            <xsl:variable name="articleUrl" 
              select="if ( $isInternalArticle ) then
                        concat('/dhq/editorial/',$id,'.html')
                      else
                        concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/>
            <xsl:variable name="title" 
              select="$article//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
            <xsl:choose>
              <xsl:when test="exists($title)">
                <a href="{$articleUrl}">
                  <xsl:value-of select="$title"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>[No title]</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <!-- Authors column -->
          <td>
            <xsl:variable name="authorInfoSeq" 
              select="$article//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo"/>
            <xsl:choose>
              <xsl:when test="exists($authorInfoSeq)">
                <ul>
                  <xsl:for-each select="$authorInfoSeq">
                    <xsl:variable name="thisAuthor" select="."/>
                    <li>
                      <xsl:apply-templates select="dhq:author_name"/>
                    </li>
                  </xsl:for-each>
                </ul>
                <!--<table summary="author list">
                  <xsl:for-each select="doc(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                    <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                  </xsl:for-each>
                </table>-->
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>[No author]</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>
