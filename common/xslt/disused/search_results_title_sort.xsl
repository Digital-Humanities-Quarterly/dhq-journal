<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:fn="http://www.w3.org/2003/11/xpath-functions"
    exclude-result-prefixes="xhtml" version="1.0">     
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:table[@id='article_list']">
        <table summary="article list" id="article_list">
            <xsl:for-each select="xhtml:tr[@id='heading']">
                <tr><xsl:apply-templates/></tr>
            </xsl:for-each>
            <xsl:for-each select="xhtml:tr[@title]">
                <xsl:sort select="@title"/>
                <tr><xsl:apply-templates/></tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    
</xsl:stylesheet>
