<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    exclude-result-prefixes="tei dhq" version="1.0">
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="dhq2html.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xsl:param name="fpath"/>
    <xsl:param name="sort"><xsl:value-of select="'id'"/></xsl:param>
    <xsl:param name="direction"><xsl:value-of select="'asc'"/></xsl:param>
    
    
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
                        <p>&lt;&lt; <a href="/dhq/editorial/index.html">Back to Editorial Table of Contents</a></p>
                        <h1>Article List</h1>
                        <table summary="article list" id="article_list"><tr id="heading">
                            <th><xsl:choose><xsl:when test="$sort='id'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles.html">&#9650;</a><br/>Article Number</xsl:when><xsl:otherwise>Article Number<br/><a href="/dhq/editorial/articles_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles.html">Article Number</a></xsl:otherwise></xsl:choose></th>
                            <th><xsl:choose><xsl:when test="$sort='issue'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles_issue.html">&#9650;</a><br/>Vol/Issue</xsl:when><xsl:otherwise>Vol/Issue<br/><a href="/dhq/editorial/articles_issue_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles_issue.html">Vol/Issue</a></xsl:otherwise></xsl:choose></th>
                            <th><xsl:choose><xsl:when test="$sort='title'"><xsl:choose><xsl:when test="$direction='desc'"><a href="/dhq/editorial/articles_title.html">&#9650;</a><br/>Title</xsl:when><xsl:otherwise>Title<br/><a href="/dhq/editorial/articles_title_desc.html">&#9660;</a></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><a href="/dhq/editorial/articles_title.html">Title</a></xsl:otherwise></xsl:choose></th>
                            <th>Authors</th></tr>
                            <xsl:choose>
                                <xsl:when test="$sort='id'">
                                    <xsl:choose>
                                        <xsl:when test="$direction='asc'">
                                            <xsl:for-each select="//item">
                                                <xsl:sort select="@id"/>
                                                <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
                                                <xsl:variable name="vol"><xsl:value-of select="ancestor::journal/attribute::vol"/></xsl:variable>
                                                <xsl:variable name="issue"><xsl:value-of select="ancestor::journal/attribute::issue"/></xsl:variable>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))">
                                                            <td class="center"><xsl:value-of select="@id"/></td>
                                                            <td class="center">
                                                                <xsl:choose>
                                                                    <xsl:when test="ancestor::journal/attribute::editorial"><a href="/dhq/editorial/index.html">Editorial</a></xsl:when>
                                                                    <xsl:when test="ancestor::journal/attribute::preview"><a href="/dhq/preview/index.html">v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/></a><br/>(Preview)</xsl:when>
                                                                    <xsl:otherwise>
                                                                        <a>
                                                                            <xsl:attribute name="href">
                                                                                <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                                                                            </xsl:attribute>
                                                                            v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/>
                                                                        </a>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td><xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"><a><xsl:attribute name="href"><xsl:choose><xsl:when test="ancestor::journal/attribute::editorial"><xsl:value-of select="concat('/dhq/editorial/',$id,'.html')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></a></xsl:when><xsl:otherwise>[No title]</xsl:otherwise></xsl:choose></td>
                                                            <td>
                                                                <xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                    <table summary="author list">
                                                                        <xsl:for-each select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                            <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                                                                        </xsl:for-each>
                                                                    </table>
                                                                </xsl:when><xsl:otherwise>[No author]</xsl:otherwise></xsl:choose>
                                                            </td>
                                                        </xsl:when>
                                                        <xsl:otherwise><td class="center"><xsl:value-of select="@id"/></td><td class="center">[N/A]</td><td>[N/A]</td><td>[N/A]</td></xsl:otherwise>
                                                    </xsl:choose>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each select="//item">
                                                <xsl:sort select="@id" order="descending"/>
                                                <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
                                                <xsl:variable name="vol"><xsl:value-of select="ancestor::journal/attribute::vol"/></xsl:variable>
                                                <xsl:variable name="issue"><xsl:value-of select="ancestor::journal/attribute::issue"/></xsl:variable>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))">
                                                            <td class="center"><xsl:value-of select="@id"/></td>
                                                            <td class="center">
                                                                <xsl:choose>
                                                                    <xsl:when test="ancestor::journal/attribute::editorial"><a href="/dhq/editorial/index.html">Editorial</a></xsl:when>
                                                                    <xsl:when test="ancestor::journal/attribute::preview"><a href="/dhq/preview/index.html">v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/></a><br/>(Preview)</xsl:when>
                                                                    <xsl:otherwise>
                                                                        <a>
                                                                            <xsl:attribute name="href">
                                                                                <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                                                                            </xsl:attribute>
                                                                            v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/>
                                                                        </a>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td><xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"><a><xsl:attribute name="href"><xsl:choose><xsl:when test="ancestor::journal/attribute::editorial"><xsl:value-of select="concat('/dhq/editorial/',$id,'.html')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></a></xsl:when><xsl:otherwise>[No title]</xsl:otherwise></xsl:choose></td>
                                                            <td>
                                                                <xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                    <table summary="author list">
                                                                        <xsl:for-each select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                            <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                                                                        </xsl:for-each>
                                                                    </table>
                                                                </xsl:when><xsl:otherwise>[No author]</xsl:otherwise></xsl:choose>
                                                            </td>
                                                        </xsl:when>
                                                        <xsl:otherwise><td class="center"><xsl:value-of select="@id"/></td><td class="center">[N/A]</td><td>[N/A]</td><td>[N/A]</td></xsl:otherwise>
                                                    </xsl:choose>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$sort='id'">
                                    <xsl:choose>
                                        <xsl:when test="$direction='asc'">
                                            <xsl:for-each select="//item">
                                                <xsl:sort select="ancestor::journal/attribute::vol"/>
                                                <xsl:sort select="ancestor::journal/attribute::issue"/>
                                                <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
                                                <xsl:variable name="vol"><xsl:value-of select="ancestor::journal/attribute::vol"/></xsl:variable>
                                                <xsl:variable name="issue"><xsl:value-of select="ancestor::journal/attribute::issue"/></xsl:variable>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))">
                                                            <td class="center"><xsl:value-of select="@id"/></td>
                                                            <td class="center">
                                                                <xsl:choose>
                                                                    <xsl:when test="ancestor::journal/attribute::editorial"><a href="/dhq/editorial/index.html">Editorial</a></xsl:when>
                                                                    <xsl:when test="ancestor::journal/attribute::preview"><a href="/dhq/preview/index.html">v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/></a><br/>(Preview)</xsl:when>
                                                                    <xsl:otherwise>
                                                                        <a>
                                                                            <xsl:attribute name="href">
                                                                                <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                                                                            </xsl:attribute>
                                                                            v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/>
                                                                        </a>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td><xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"><a><xsl:attribute name="href"><xsl:choose><xsl:when test="ancestor::journal/attribute::editorial"><xsl:value-of select="concat('/dhq/editorial/',$id,'.html')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></a></xsl:when><xsl:otherwise>[No title]</xsl:otherwise></xsl:choose></td>
                                                            <td>
                                                                <xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                    <table summary="author list">
                                                                        <xsl:for-each select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                            <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                                                                        </xsl:for-each>
                                                                    </table>
                                                                </xsl:when><xsl:otherwise>[No author]</xsl:otherwise></xsl:choose>
                                                            </td>
                                                        </xsl:when>
                                                        <xsl:otherwise><td class="center"><xsl:value-of select="@id"/></td><td class="center">[N/A]</td><td>[N/A]</td><td>[N/A]</td></xsl:otherwise>
                                                    </xsl:choose>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each select="//item">
                                                <xsl:sort select="ancestor::journal/attribute::vol" order="descending"/>
                                                <xsl:sort select="ancestor::journal/attribute::issue" order="descending"/>
                                                <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
                                                <xsl:variable name="vol"><xsl:value-of select="ancestor::journal/attribute::vol"/></xsl:variable>
                                                <xsl:variable name="issue"><xsl:value-of select="ancestor::journal/attribute::issue"/></xsl:variable>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))">
                                                            <td class="center"><xsl:value-of select="@id"/></td>
                                                            <td class="center">
                                                                <xsl:choose>
                                                                    <xsl:when test="ancestor::journal/attribute::editorial"><a href="/dhq/editorial/index.html">Editorial</a></xsl:when>
                                                                    <xsl:when test="ancestor::journal/attribute::preview"><a href="/dhq/preview/index.html">v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/></a><br/>(Preview)</xsl:when>
                                                                    <xsl:otherwise>
                                                                        <a>
                                                                            <xsl:attribute name="href">
                                                                                <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                                                                            </xsl:attribute>
                                                                            v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/>
                                                                        </a>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td><xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"><a><xsl:attribute name="href"><xsl:choose><xsl:when test="ancestor::journal/attribute::editorial"><xsl:value-of select="concat('/dhq/editorial/',$id,'.html')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></a></xsl:when><xsl:otherwise>[No title]</xsl:otherwise></xsl:choose></td>
                                                            <td>
                                                                <xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                    <table summary="author list">
                                                                        <xsl:for-each select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                            <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                                                                        </xsl:for-each>
                                                                    </table>
                                                                </xsl:when><xsl:otherwise>[No author]</xsl:otherwise></xsl:choose>
                                                            </td>
                                                        </xsl:when>
                                                        <xsl:otherwise><td class="center"><xsl:value-of select="@id"/></td><td class="center">[N/A]</td><td>[N/A]</td><td>[N/A]</td></xsl:otherwise>
                                                    </xsl:choose>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="//item">
                                        <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
                                        <xsl:variable name="vol"><xsl:value-of select="ancestor::journal/attribute::vol"/></xsl:variable>
                                        <xsl:variable name="issue"><xsl:value-of select="ancestor::journal/attribute::issue"/></xsl:variable>
                                        <xsl:variable name="title"><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></xsl:variable>
                                        <xsl:variable name="lower">0123456789abcdefghijklmnopqrstuvwxyz</xsl:variable>
                                        <xsl:variable name="upper">0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
                                        <xsl:variable name="punctuation">[/\].,+-=*~@#$%^(){}`"'!?&amp;&lt;&gt;</xsl:variable>
                                        <xsl:variable name="stoplist" select="document('../../toc/stoplist.xml')/stoplist/ignore" />
                                        <xsl:variable name="string"><xsl:value-of select="substring(translate($title, $punctuation, ''),
                                            string-length(
                                            $stoplist[starts-with(
                                            translate($title,
                                            concat($lower, $punctuation),
                                            $upper),
                                            translate(., $lower, $upper))]) + 1)"/></xsl:variable>
                                        <xsl:variable name="apos">'</xsl:variable>
                                        <tr>
                                            <xsl:attribute name="title">
                                                <xsl:value-of select="translate($string,$upper,$lower)"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="id">
                                                <xsl:value-of select="@id"/>
                                            </xsl:attribute>
                                            <xsl:choose>
                                                <xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))">
                                                    <td class="center"><xsl:value-of select="@id"/></td>
                                                    <td class="center">
                                                        <xsl:choose>
                                                            <xsl:when test="ancestor::journal/attribute::editorial"><a href="/dhq/editorial/index.html">Editorial</a></xsl:when>
                                                            <xsl:when test="ancestor::journal/attribute::preview"><a href="/dhq/preview/index.html">v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/></a><br/>(Preview)</xsl:when>
                                                            <xsl:otherwise>
                                                                <a>
                                                                    <xsl:attribute name="href">
                                                                        <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                                                                    </xsl:attribute>
                                                                    v<xsl:value-of select="$vol"/>n<xsl:value-of select="$issue"/>
                                                                </a>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                    <td><xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"><a><xsl:attribute name="href"><xsl:choose><xsl:when test="ancestor::journal/attribute::editorial"><xsl:value-of select="concat('/dhq/editorial/',$id,'.html')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/></xsl:otherwise></xsl:choose></xsl:attribute><xsl:value-of select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></a></xsl:when><xsl:otherwise>[No title]</xsl:otherwise></xsl:choose></td>
                                                    <td>
                                                        <xsl:choose><xsl:when test="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                            <table summary="author list">
                                                                <xsl:for-each select="document(concat('../../articles/',$id,'/',$id,'.xml'))//tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                                                                    <tr><td class="author"><xsl:apply-templates select="dhq:author_name"/></td></tr>
                                                                </xsl:for-each>
                                                            </table>
                                                        </xsl:when><xsl:otherwise>[No author]</xsl:otherwise></xsl:choose>
                                                    </td>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <td class="center"><xsl:value-of select="@id"/></td><td class="center">[N/A]</td><td>[N/A]</td><td>[N/A]</td>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </tr>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                        <p>&lt;&lt; <a href="/dhq/editorial/index.html">Back to Editorial Table of Contents</a></p>
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
                
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>
