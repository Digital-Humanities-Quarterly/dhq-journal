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
    
    <!-- suppressed elements -->
    <xsl:template match="dhq:authorInfo/dhq:address"/>
    <xsl:template match="dhq:authorInfo/tei:email"/>
    <xsl:template match="dhq:authorInfo/dhq:bio"/>
    <xsl:template match="dhq:authorInfo/dhq:affiliation"/>
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    <!-- dropped to pull just the first name in dhq:author_name [CRB] -->
    <xsl:template match="dhq:family"/>
    
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
    
    <xsl:template name="index_main_body">
        <div id="authorIndex">
            <div id="authors">
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
        <xsl:param name="title"><xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/></xsl:param>
        <xsl:param name="issueTitle"><xsl:apply-templates select="document('../../toc/toc.xml')//journal[@vol=$vol_no_zeroes and @issue=$issue]/title"/></xsl:param>
        <!-- Stopwords filter from Jeni Tennison, http://www.stylusstudio.com/xsllist/200112/post10410.html -->
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="coauthor"><xsl:if test="count(tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo) > 1"><xsl:text>, [co-authored]</xsl:text></xsl:if></xsl:variable>
        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
            <xsl:variable name="string"><xsl:value-of select="translate(concat(normalize-space(dhq:author_name/dhq:family),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/></xsl:variable>
            <p>
                <xsl:attribute name="id">
                    <xsl:value-of select="translate($string,(translate($string,$lower,'')),'')"/>
                </xsl:attribute>
                <xsl:call-template name="author"/>
                <span class="title">
                    <xsl:for-each select="../tei:title">
                        <xsl:if test="position() > 1"><br/></xsl:if>
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
                    </xsl:for-each>
                    <xsl:text>, </xsl:text><xsl:value-of select="$issueTitle"/><xsl:text>: v</xsl:text><xsl:value-of select="$vol_no_zeroes"/><xsl:text> n</xsl:text><xsl:value-of select="$issue"/><xsl:value-of select="$coauthor"/></span>
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="author">
        <xsl:variable name="name">
            <xsl:apply-templates select="dhq:author_name"/>
        </xsl:variable>
        <span class="author"><strong><xsl:value-of select="normalize-space(concat(dhq:author_name/dhq:family,', ',normalize-space($name)))"/></strong></span>
        <xsl:if test="dhq:affiliation"><span class="affiliation"><xsl:text>, </xsl:text><xsl:value-of select="normalize-space(dhq:affiliation)"/></span></xsl:if>
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
