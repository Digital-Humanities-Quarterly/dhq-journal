<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xhtml" version="1.0">     
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@id='bios']">
        <h1>
            <xsl:text>Author Biographies</xsl:text>
        </h1>
        <xsl:for-each select="xhtml:div[@id]">
            <xsl:sort select="@id"/> 
            <xsl:choose>
                <xsl:when test="@id = (following::*/@id)"></xsl:when>
                <xsl:otherwise>
                    <div class="ptext">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
