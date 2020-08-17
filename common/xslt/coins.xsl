<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    version="1.0">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>

    <xsl:template name="coins" match="tei:TEI/tei:teiHeader">
      <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">Z3988</xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>url_ver=Z39.88-2004&amp;ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fzotero.org%3A2&amp;rft.genre=article&amp;</xsl:text>
                <xsl:apply-templates mode="coins-data" select="//tei:fileDesc"/>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:fileDesc" mode="coins-data">

        <xsl:param name="tei_title">
            <xsl:call-template name="clean_string">
                <xsl:with-param name="string" select="normalize-space(tei:titleStmt/tei:title)"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:text>rft.atitle=</xsl:text>
        <xsl:value-of select="$tei_title"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.jtitle=Digital%20Humanities%20Quarterly&amp;rft.stitle=DHQ&amp;rft.issn=1938-4122&amp;</xsl:text>
        <xsl:text>rft.date=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:date/@when"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.volume=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:idno[@type='volume']"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.issue=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:idno[@type='issue']"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.aulast=</xsl:text>
        <!-- First author's last name http://ocoins.info/cobg.html -->
        <xsl:value-of
            select="normalize-space(tei:titleStmt/dhq:authorInfo[1]/dhq:author_name/dhq:family)"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.aufirst=</xsl:text>
        <!-- First author's first name  -->
        <xsl:value-of
            select="normalize-space(tei:titleStmt/dhq:authorInfo[1]/dhq:author_name/text())"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:for-each select="tei:titleStmt/dhq:authorInfo">
            <!-- All Authors' names -->
            <xsl:text>rft.au=</xsl:text>
            <xsl:value-of select="normalize-space(dhq:author_name/text())"/>%20<xsl:value-of
                select="normalize-space(dhq:author_name/dhq:family)"/>
            <xsl:if test="not(position() = last())">
                <xsl:text>&amp;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
<!-- The search and replace code is borrowed from O'Reilly's XSLT cookbook -->
    <xsl:template name="search_and_replace">
        <xsl:param name="input"/>
        <xsl:param name="search-string"/>
        <xsl:param name="replace-string"/>
        <xsl:choose>
            <xsl:when test="$search-string and 
                contains($input,$search-string)">
                <xsl:value-of select="substring-before($input,$search-string)"/>
                <xsl:value-of select="$replace-string"/>
                <xsl:call-template name="search_and_replace">
                    <xsl:with-param name="input" select="substring-after($input,$search-string)"/>
                    <xsl:with-param name="search-string" select="$search-string"/>
                    <xsl:with-param name="replace-string" select="$replace-string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="clean_string">
        <xsl:param name="string"/>
        <xsl:choose>
           
            <xsl:when test="contains($string,' ')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="' '"/>
                            <xsl:with-param name="replace-string" select="'%20'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,':')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="':'"/>
                            <xsl:with-param name="replace-string" select="'%3A'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'’')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'’'"/>
                            <xsl:with-param name="replace-string" select="'%E2%80%99'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'#')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'#'"/>
                            <xsl:with-param name="replace-string" select="'%23'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="contains($string,'&amp;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&amp;'"/>
                            <xsl:with-param name="replace-string" select="'%26'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'+')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'+'"/>
                            <xsl:with-param name="replace-string" select="'%2B'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'/')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'/'"/>
                            <xsl:with-param name="replace-string" select="'%2F'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'&lt;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&lt;'"/>
                            <xsl:with-param name="replace-string" select="'%3C'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'=')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'='"/>
                            <xsl:with-param name="replace-string" select="'%3D'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'&gt;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&gt;'"/>
                            <xsl:with-param name="replace-string" select="'%3E'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'?')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'?'"/>
                            <xsl:with-param name="replace-string" select="'%3F'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
