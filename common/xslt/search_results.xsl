<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:search="http://apache.org/cocoon/search/1.0"
    exclude-result-prefixes="dhq tei search" version="1.0">
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="dhq2html.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:param name="fpath"/>
    <xsl:param name="context"/>
    
    <xsl:template match="search:results">
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="'Search Results'"/>
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
                        <h1>Search Results</h1>
                        <xsl:apply-templates select="search:hits"/>
                        <xsl:apply-templates select="search:hits" mode="navigation_only"/>
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="search:hits" mode="navigation_only">
        <xsl:if test="@total-count > 10">
            <p>
                <xsl:if test="/search:results/search:navigation/@has-previous">
                    <xsl:call-template name="navigation-paging-link">
                        <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                        <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                        <xsl:with-param name="has-previous" select="/search:results/search:navigation/@has-previous"/>
                        <xsl:with-param name="previous-index" select="/search:results/search:navigation/@previous-index"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:for-each select="/search:results/search:navigation/search:navigation-page">
                    <xsl:call-template name="navigation-link"> 
                        <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                        <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                        <xsl:with-param name="start-index" select="@start-index"/>
                        <xsl:with-param name="link-text" select="position()"/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <xsl:if test="/search:results/search:navigation/@has-next">
                    <xsl:call-template name="navigation-paging-link">
                        <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                        <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                        <xsl:with-param name="has-next" select="/search:results/search:navigation/@has-next"/>
                        <xsl:with-param name="next-index" select="/search:results/search:navigation/@next-index"/>
                    </xsl:call-template>
                </xsl:if>
            </p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="search:hits">
        <p id="search_hits"><span>Query: <em><xsl:value-of select="substring-before(/search:results/@query-string, ' AND idno@type:DHQarticle-id')"/></em></span>
            <span class="hit_count">
                Total Hits: <xsl:value-of select="@total-count"/>,
                Pages: <xsl:value-of select="@count-of-pages"/>
            </span>
        </p>
        <xsl:if test="@total-count > 0">
            <!-- Print navigation if results exceed one page [CRB] -->
            <xsl:if test="@total-count > 10">
                <p>
                    <xsl:if test="/search:results/search:navigation/@has-previous">
                        <xsl:call-template name="navigation-paging-link">
                            <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                            <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                            <xsl:with-param name="has-previous" select="/search:results/search:navigation/@has-previous"/>
                            <xsl:with-param name="previous-index" select="/search:results/search:navigation/@previous-index"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <xsl:for-each select="/search:results/search:navigation/search:navigation-page">
                        <xsl:call-template name="navigation-link"> 
                            <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                            <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                            <xsl:with-param name="start-index" select="@start-index"/>
                            <xsl:with-param name="link-text" select="position()"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    
                    <xsl:if test="/search:results/search:navigation/@has-next">
                        <xsl:call-template name="navigation-paging-link">
                            <xsl:with-param name="query-string" select="/search:results/@query-string"/>
                            <xsl:with-param name="page-length" select="/search:results/@page-length"/>
                            <xsl:with-param name="has-next" select="/search:results/search:navigation/@has-next"/>
                            <xsl:with-param name="next-index" select="/search:results/search:navigation/@next-index"/>
                        </xsl:call-template>
                    </xsl:if>
                </p>
            </xsl:if>
            
            <hr/>
            
            <table border="1" width="90%" cellpadding="4" class="search_results">
                <!--<tr>
                    <th class="center">Score</th><th class="center">Rank</th><th class="left">Title</th>
                    </tr>-->
                <xsl:apply-templates/>
            </table>
        </xsl:if>
        <xsl:if test="@total-count = 0">
            <p><br/></p>
            <p>Your search <em><xsl:value-of select="substring-before(/search:results/@query-string, ' AND idno@type:DHQarticle-id')"/></em> did not yield any results.</p>
            <p>Suggestions for revising your search:</p>
            <ul>
                <li>Check the spelling of your search terms</li>
                <li>Verify your search syntax -- make sure you have closed parenthesis and double quotes</li>
                <li>Broaden your search by using fewer search terms</li>
                <li>Broaden your search by using wildcard symbol (*) at the end of term(s)</li>
                <li>Broaden your search by conducting OR searches</li>
            </ul>
            <p>See: <a href="/dhq/about/search.html">Search Help</a></p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="search:navigation">
        <p>
            <xsl:call-template name="navigation-paging-form">
                <xsl:with-param name="query-string"><xsl:value-of select="/search:results/@query-string"/></xsl:with-param>
                <xsl:with-param name="page-length"><xsl:value-of select="/search:results/@page-length"/></xsl:with-param>
                <xsl:with-param name="has-previous"><xsl:value-of select="@has-previous"/></xsl:with-param>
                <xsl:with-param name="has-next"><xsl:value-of select="@has-next"/></xsl:with-param>
                <xsl:with-param name="previous-index"><xsl:value-of select="@previous-index"/></xsl:with-param>
                <xsl:with-param name="next-index"><xsl:value-of select="@next-index"/></xsl:with-param>
            </xsl:call-template>
        </p>
    </xsl:template>
    
    <xsl:template match="search:hit">
        <xsl:variable name="issue">
            <xsl:value-of select="substring(@uri, string-length(@uri)-10, 6)"/>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:value-of select="document('../../toc/toc.xml')//title[parent::journal[not(attribute::editorial)]/descendant::item/attribute::id=$issue]"/>
        </xsl:variable>
        <xsl:variable name="article_title">
            <xsl:value-of select="document(concat('../../articles/',$issue,'/',$issue,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </xsl:variable>
        <tr>
            <!--<td class="score">
                <xsl:value-of select="format-number( @score, '###%' )"/>
                </td>
                <td class="rank">
                <xsl:value-of select="@rank + 1"/>
                </td>-->
            <td>
                <a href="{@uri}">
                    <xsl:value-of select="$article_title"/>
                </a>
                <xsl:text>, </xsl:text><xsl:value-of select="$title"/>
                <div class="authors">
                    <xsl:for-each select="document(concat('../../articles/',$issue,'/',$issue,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                        <xsl:choose>
                            <xsl:when test="not(position() = last())">
                                <xsl:value-of select="normalize-space(dhq:author_name)"/><xsl:if test="dhq:affiliation"><xsl:text>, </xsl:text><xsl:value-of select="normalize-space(dhq:affiliation)"/></xsl:if><xsl:text>; </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(dhq:author_name)"/><xsl:if test="dhq:affiliation"><xsl:text>, </xsl:text><xsl:value-of select="normalize-space(dhq:affiliation)"/></xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template name="navigation-paging-form">
        <xsl:param name="query-string"/>
        <xsl:param name="page-length"/>
        <xsl:param name="has-previous"/>
        <xsl:param name="has-next"/>
        <xsl:param name="previous-index"/>
        <xsl:param name="next-index"/>
        
        <xsl:if test="$has-previous = 'true'">
            <form action="findIt">
                <input type="hidden" name="startIndex" value="{$previous-index}"/>
                <input type="hidden" name="queryString" value="{$query-string}"/>
                <input type="hidden" name="pageLength" value="{$page-length}"/>
                <input type="submit" name="previous" value="previous"/>
            </form>
        </xsl:if>
        
        <xsl:if test="$has-next = 'true'">
            <form action="findIt">
                <input type="hidden" name="startIndex" value="{$next-index}"/>
                <input type="hidden" name="queryString" value="{$query-string}"/>
                <input type="hidden" name="pageLength" value="{$page-length}"/>
                <input type="submit" name="next" value="next"/>
            </form>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="navigation-paging-link">
        <xsl:param name="query-string"/>
        <xsl:param name="page-length"/>
        <xsl:param name="has-previous"/>
        <xsl:param name="has-next"/>
        <xsl:param name="previous-index"/>
        <xsl:param name="next-index"/>
        
        <xsl:if test="$has-previous = 'true'">
            
            <xsl:call-template name="navigation-link">
                <xsl:with-param name="query-string"><xsl:value-of select="$query-string"/></xsl:with-param>
                <xsl:with-param name="page-length"><xsl:value-of select="$page-length"/></xsl:with-param>
                <xsl:with-param name="start-index"><xsl:value-of select="$previous-index"/></xsl:with-param>
                <xsl:with-param name="link-text">Previous</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        &#160;
        <xsl:if test="$has-next = 'true'">
            <a href="findIt?startIndex={$next-index}&amp;queryString={$query-string}&amp;pageLength={$page-length}">
                <xsl:text>Next</xsl:text>
            </a>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="navigation-link">
        <xsl:param name="query-string"/>
        <xsl:param name="page-length"/>
        <xsl:param name="start-index"/>
        <xsl:param name="link-text"/>
        
        <a href="findIt?startIndex={$start-index}&amp;queryString={$query-string}&amp;pageLength={$page-length}">
            <xsl:value-of select="$link-text"/>
        </a>
        &#160;
    </xsl:template>
    
    <xsl:template match="@*|node()" priority="-2"><xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy></xsl:template>
    <xsl:template match="text()" priority="-1"><xsl:value-of select="."/></xsl:template>
    
</xsl:stylesheet>
