<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/2005/Atom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"  
    exclude-result-prefixes="tei dhq" version="1.0">
    <xsl:output method="xml"/>
    <xsl:param name="staticPublishingPathPrefix">
        <xsl:value-of select="'../articles/'"/>
    </xsl:param>
    <xsl:param name="vol">
        <xsl:value-of select="toc/journal[@current]/@vol"/>
    </xsl:param>
    <xsl:param name="issue">
        <xsl:value-of select="toc/journal[@current]/@issue"/>
    </xsl:param>
    <xsl:param name="vol_preview">
        <xsl:value-of select="toc/journal[@preview]/@vol"/>
    </xsl:param>
    <xsl:param name="issue_preview">
        <xsl:value-of select="toc/journal[@preview]/@issue"/>
    </xsl:param>

    <!-- Parameters to store actual weblink of the atom feed -->
    <xsl:param name="pathfull">
        <xsl:value-of select="'http://www.digitalhumanities.org/dhq/vol/'"/>
    </xsl:param>
    <xsl:param name="pathfulllink">
        <xsl:value-of select="concat($pathfull,$vol,'/',$issue,'/')"/>
    </xsl:param>
    <xsl:param name="pathfulllink_preview">
        <xsl:value-of select="concat($pathfull,$vol_preview,'/',$issue_preview,'/')"/>
    </xsl:param>
    <xsl:param name="channellink">
        <xsl:value-of select="concat($pathfulllink, 'index.html')"/>
    </xsl:param>
    <xsl:variable name="tocdate">
        <xsl:value-of select="toc/journal[@current]/title/@value"/> 
    </xsl:variable>
    <xsl:variable name="toctimestamp">
        <xsl:value-of select="concat($tocdate,'T00:00:00Z')"/>
    </xsl:variable>
    <xsl:variable name="previewdate">
        <xsl:value-of select="toc/journal[@preview]/title/@value"/>
    </xsl:variable>
    <xsl:variable name="previewtimestamp">
        <xsl:value-of select="concat($previewdate,'T00:00:00Z')"/>
    </xsl:variable>


    <xsl:template match="/">      
        
        <feed xmlns="http://www.w3.org/2005/Atom">
            <!--feed metadata-->

            <title>Digital Humanities Quarterly</title>
            <id>
                <xsl:value-of select="$channellink"/>
            </id>
            <!--manipulate the feed level toc timestamp - and use it for entry of new issue and author biography-->
            <updated>
                <!-- Use the timestamp created from table of contents-->
                <xsl:value-of select="$toctimestamp"/>
            </updated>


            <!-- add the actual link of this feed here -->
            <link rel="self" href="http://www.digitalhumanities.org/dhq/feed/news.xml" type="application/atom+xml"/>
            <!-- added for small logo of rss appear in the browser link -->
            <!--<link rel="SHORTCUT icon" href="rss.ico"/>-->


            <category term="Digital Humanities"/>
            <rights type="xhtml" xml:lang="en">
                <div xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
                    <b>&amp; copy; The Alliance of Digital Humanities Organizations</b>
                </div>
                <!-- remove this line if earlier works-->
                <!--                The Alliance of Digital Humanities Organizations-->
            </rights>
            <!-- the name of the pic file that you want to upload to represent the feed on the page-->
            <!--<icon>rsspic.gif</icon>-->
            <author>
                <name>Digital Humanities Quarterly</name>
            </author>
            <subtitle>Digital Humanities Quarterly</subtitle>

            <xsl:if test="toc/journal[@preview]">
                <!--    Preview items      -->
                <entry>
                    <title>
                        Preview
                    </title>
                    <id>
                        <xsl:value-of select="'http://www.digitalhumanities.org/dhq/preview/index.html'"/>
                    </id>
                    <updated>
                        <!-- Use the timestamp created from table of contents-->
                        <xsl:value-of select="$previewtimestamp"/>
                    </updated>
                    <summary>Digital Humanities Quarterly - Preview</summary>
                    <link rel="alternate">
                        <xsl:attribute name="href">
                            <xsl:value-of select="'http://www.digitalhumanities.org/dhq/preview/index.html'"/>
                        </xsl:attribute>
                    </link>
                </entry>
                
                <!--    cluster items      -->
                <xsl:for-each select="toc/journal[@preview]//item">
                    <entry>
                        <xsl:apply-templates select="document(concat($staticPublishingPathPrefix,@id,'/',@id,'.xml'))//tei:TEI" mode="preview"/>
                        <xsl:message>
                            <xsl:value-of select="concat('file: ',$staticPublishingPathPrefix,@id,'/',@id,'.xml')"/>
                        </xsl:message>
                        <updated>
                            <!-- Use the timestamp created from table of contents-->
                            <xsl:value-of select="$previewtimestamp"/>
                        </updated>
                    </entry>
                </xsl:for-each>
                
                <!--    author biography items -->
                <entry>
                    <id>
                        <xsl:value-of select="'http://www.digitalhumanities.org/dhq/preview/bios.html'"/>
                    </id>
                    <link rel="alternate">
                        <xsl:attribute name="href">
                            <xsl:value-of select="'http://www.digitalhumanities.org/dhq/preview/bios.html'"/>
                        </xsl:attribute>
                    </link>
                    <title>
                        <xsl:value-of select="'Author Biographies'"/>
                    </title>
                    <updated>
                        <!-- Use the timestamp created from table of contents-->
                        <xsl:value-of select="$previewtimestamp"/>
                    </updated>
                </entry>
                
            </xsl:if>
            
            <!-- item to describe new issue -->
            <entry>
                <title>
                    <xsl:value-of select="toc/journal[@current]/title"/>
                </title>
                <id>
                    <xsl:value-of select="$channellink"/>
                </id>
                
                <updated>
                    <!-- Use the timestamp created from table of contents-->
                    <xsl:value-of select="$toctimestamp"/>
                </updated>
                <summary>Digital Humanities Quarterly - New Issue</summary>
                
                <link rel="alternate">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$channellink"/>
                    </xsl:attribute>
                </link>
            </entry>
            
            
            <!--    cluster items      -->
            <xsl:for-each select="toc/journal[@current]//item">
                <entry>
                    <xsl:apply-templates select="document(concat($staticPublishingPathPrefix,@id,'/',@id,'.xml'))//tei:TEI"/>
                    <xsl:message>
                        <xsl:value-of select="concat('file: ',$staticPublishingPathPrefix,@id,'/',@id,'.xml')"/>
                    </xsl:message>
                    <updated>
                        <!-- Use the timestamp created from table of contents-->
                        <xsl:value-of select="$toctimestamp"/>
                    </updated>
                </entry>
            </xsl:for-each>
            
            
            <!--    author biography items -->
            <entry>
                <id>
                    <xsl:value-of select="concat($pathfulllink,'bios.html')"/>
                </id>
                <link rel="alternate">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($pathfulllink,'bios.html')"/>
                    </xsl:attribute>
                </link>
                <title>
                    <xsl:value-of select="'Author Biographies'"/>
                </title>
                <updated>
                    <!-- Use the timestamp created from table of contents-->
                    <xsl:value-of select="$toctimestamp"/>
                </updated>
            </entry>

        </feed>
    </xsl:template>

    <xsl:template match="tei:TEI">
        <xsl:param name="id">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id']"/>
        </xsl:param>
        <xsl:variable name="apos">'</xsl:variable>
        <id>
            <xsl:value-of select="concat($pathfulllink,$id,'.html')"/>
        </id>
        <link rel="alternate">
            <xsl:attribute name="href">
                <xsl:value-of select="concat($pathfulllink,$id,'.html')"/>
            </xsl:attribute>
        </link>


        <title>
            <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </title>

        <!--<description>-->
        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
            <author>
                <name>
                    <xsl:value-of select="normalize-space(dhq:author_name)"/>
                    <xsl:if test="dhq:affiliation">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(dhq:affiliation)"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="'; '"/>
                    </xsl:if>
                </name>
            
            </author>
        </xsl:for-each>

        <!--  </description> -->


        <!-- replacing abstract with teaser -->
        <xsl:if test="//dhq:teaser">
            <summary>
                <xsl:apply-templates select="//dhq:teaser"/>
            </summary>
        </xsl:if>

    </xsl:template>
    
    <xsl:template match="tei:TEI" mode="preview">
        
        <xsl:param name="id">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id']"/>
        </xsl:param>
        <xsl:variable name="apos">'</xsl:variable>
        <id>
            <xsl:value-of select="concat($pathfulllink_preview,$id,'.html')"/>
        </id>
        <link rel="alternate">
            <xsl:attribute name="href">
                <xsl:value-of select="concat($pathfulllink_preview,$id,'.html')"/>
            </xsl:attribute>
        </link>
        
        
        <title>
            <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </title>
        
        <!--<description>-->
        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
            <author>
                <name>
                    <xsl:value-of select="normalize-space(dhq:author_name)"/>
                    <xsl:if test="dhq:affiliation">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(dhq:affiliation)"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="'; '"/>
                    </xsl:if>
                </name>
                
            </author>
        </xsl:for-each>
        <!--  </description> -->
        
        
        <!-- replacing abstract with teaser -->
        <xsl:if test="//dhq:teaser">
            <summary>
                <xsl:apply-templates select="//dhq:teaser"/>
            </summary>
        </xsl:if>
        
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

</xsl:stylesheet>
