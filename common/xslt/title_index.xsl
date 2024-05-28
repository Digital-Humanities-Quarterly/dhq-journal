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
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:param name="staticPublishingPath">
        <xsl:value-of select="'../../articles/'"/>
    </xsl:param>
    
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
                        <!-- Rest of the document/article is coverd in this template - this is a call to dhq2html.xsl -->
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
    
    <xsl:template name="index_main_body">
        <div id="titleIndex">
            <div id="titles">
                <xsl:apply-templates select="//list|//cluster"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="list|cluster">
        <xsl:for-each select="item[not(ancestor::journal/attribute::editorial)]">
            <xsl:apply-templates select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            <!--<xsl:message>
                <xsl:value-of select="concat('file: ',$staticPublishingPath,@id,'/',@id,'.xml')"/>
            </xsl:message>-->
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:param name="vol"><xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='volume'])"/></xsl:param>
        <xsl:param name="vol_no_zeroes">
            <xsl:variable name="use_vol">
              <xsl:call-template name="get-vol">
                  <xsl:with-param name="vol" select="$vol"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="normalize-space($use_vol)"/>
        </xsl:param>
        <xsl:param name="issue"><xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='issue'])"/></xsl:param>
        <xsl:param name="id">
            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        </xsl:param>
        <xsl:param name="issueTitle"><xsl:apply-templates select="document('../../toc/toc.xml')//journal[@vol=$vol_no_zeroes and @issue=$issue]/title"/></xsl:param>
        
        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
            <xsl:variable name="title">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:variable>
            <!-- Stopwords filter from Jeni Tennison, http://www.stylusstudio.com/xsllist/200112/post10410.html -->
            <xsl:variable name="lower">0123456789abcdefghijklmnopqrstuvwxyz</xsl:variable>
            <xsl:variable name="upper">0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
            <xsl:variable name="punctuation">[/\].,+-=*~@#$%^(){}`"“”'!?&amp;&lt;&gt;</xsl:variable>
            <xsl:variable name="stoplist" select="document('../../toc/stoplist.xml')/stoplist/ignore" />
            <xsl:variable name="string"><xsl:value-of select="substring(translate($title, $punctuation, ''),
                string-length(
                $stoplist[starts-with(
                translate($title,
                concat($lower, $punctuation),
                $upper),
                translate(., $lower, $upper))]) + 1)"/></xsl:variable>
            <xsl:variable name="apos">'</xsl:variable>
            <p>
                <xsl:attribute name="class">title</xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:value-of select="translate($string,$upper,$lower)"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="@xml:lang='en' or string-length(@xml:lang)=0">
                        
                        <xsl:if test="//tei:title/@xml:lang != 'en'">
                            <span class="monospace">[en]</span>
                        </xsl:if>
                        <!--
                        <span class="monospace">[en]</span>
                        -->
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="monospace">[<xsl:value-of select="@xml:lang"/>]</span>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:element name="a">
                    <xsl:choose>
                      <!-- If the article has no volume or issue information, do not include @href. -->
                      <xsl:when test="$vol_no_zeroes = '' or $issue = ''">
                        <xsl:message terminate="no">
                          <xsl:text>Article </xsl:text>
                          <xsl:value-of select="$id"/>
                          <xsl:text> has a volume of '</xsl:text>
                          <xsl:value-of select="$vol"/>
                          <xsl:text>' and an issue of '</xsl:text>
                          <xsl:value-of select="$issue"/>
                          <xsl:text>'</xsl:text>
                        </xsl:message>
                        <!-- The attributes below are an inelegant hack to make sure that this link 
                          appears not to be actionable. A better solution would be to just display the 
                          text of the title instead, sans <a>. However, XSLT 1 and the need to 
                          accommodate different languages makes this difficult to do at this time.
                          See https://css-tricks.com/how-to-disable-links/ for more on "disabling" links. -->
                        <xsl:attribute name="aria-disabled">true</xsl:attribute>
                        <xsl:attribute name="style">color:currentColor;text-decoration:none;</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="href">
                          <xsl:value-of select="concat('/',$context,'/vol/',$vol_no_zeroes,'/',$issue,'/',$id,'/',$id,'.html')"/>
                        </xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <xsl:attribute name="onclick">
                            <xsl:value-of select="concat('localStorage.setItem(', $apos, 'pagelang', $apos, ', ', $apos, @xml:lang, $apos, ');')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="."/>
                </xsl:element>
                <xsl:text>, </xsl:text><xsl:value-of select="$issueTitle"/><xsl:text>: v</xsl:text><xsl:value-of select="$vol_no_zeroes"/><xsl:text> n</xsl:text><xsl:value-of select="$issue"/>
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
            </p>
            <xsl:if test="tei:text/tei:front/dhq:abstract/child::tei:p != ''">
                <div class="viewAbstract">
                    <div style="display:inline">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('abstractExpanderabstract',$id)"/>
                        </xsl:attribute>
                        <a title="View Abstract" class="expandCollapse">
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$apos,')')"/>
                            </xsl:attribute>
                            <xsl:value-of select="'[+] '"/>
                        </a>
                        <xsl:text>View Abstract</xsl:text>
                        
                    </div>
                    
                </div>
                <div style="display:none" class="abstract">
                    <xsl:attribute name="id">
                        <xsl:value-of select="concat('abstract',$id)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="tei:text/tei:front/dhq:abstract"/>
                </div>
            </xsl:if>
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
    
    <xsl:template match="dhq:authorInfo/dhq:address|dhq:authorInfo/tei:email|tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    
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
