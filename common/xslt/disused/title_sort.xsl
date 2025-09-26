<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xhtml" version="2.0">     
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <!--
        THIS STYLESHEET IS NO LONGER USED.
        
        This stylesheet was originally intended to sort and compile the author data 
        generated from title_index.xsl . Sorting and compilation is now done as 
        part of the re-written title_index.xsl . 
        
        This stylesheet remains, in case it has use for historical purposes.
      -->
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="check">
        <xsl:param name="ltr"/>
        <xsl:if test="xhtml:p[substring(@id,1,1)=$ltr]"><xsl:value-of select="'true'"/></xsl:if>
    </xsl:template>
    
    <xsl:template name="listing">
        <xsl:param name="alphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:if test="$alphabet != ''">
            <xsl:variable name="letter" select="substring($alphabet, 1, 1)" />
            <xsl:variable name="flag">
                <xsl:call-template name="check">
                    <xsl:with-param name="ltr" select="$letter"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($flag,'true')">
                    <h3 id="{$letter}"><a href="#lb{$letter}"><xsl:value-of select="translate($letter, $lower, $upper)"/></a></h3>
                </xsl:when>
                <xsl:otherwise><h3 class="off"><xsl:value-of select="translate($letter, $lower, $upper)"/></h3></xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="xhtml:p[substring(@id,1,1)=$letter]">
                <xsl:sort select="@id"/> 
                <xsl:choose>
                    <xsl:when test="@id = (following::*/@id)"></xsl:when>
                    <xsl:otherwise>
                        <div class="ptext">
                            <!--<xsl:attribute name="id">
                                <xsl:value-of select="translate(@id,(translate(@id,$good,'')),'')"/>
                                </xsl:attribute>-->
                            <xsl:apply-templates/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>    
            </xsl:for-each>
            <xsl:call-template name="listing">
                <xsl:with-param name="alphabet" select="substring($alphabet, 2)" />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="index">
        <xsl:param name="alphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:if test="$alphabet != ''">
            <xsl:variable name="letter" select="substring($alphabet, 1, 1)" />
            <xsl:variable name="flag"><xsl:call-template name="check"><xsl:with-param name="ltr" select="$letter"/></xsl:call-template></xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($flag,'true')">
                    <td id="lb{$letter}"><a href="#{$letter}"><xsl:value-of select="translate($letter, $lower, $upper)"/></a></td>
                </xsl:when>
                <xsl:otherwise><td class="off"><xsl:value-of select="translate($letter, $lower, $upper)"/></td></xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="index">
                <xsl:with-param name="alphabet" select="substring($alphabet, 2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@id='titles']">
        <xsl:variable name="good">0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz</xsl:variable>
        <h1>
            <xsl:text>Title Index</xsl:text>
        </h1>
        <table id="a2zNavigation" summary="A to Z navigation bar"><tr><xsl:call-template name="index"></xsl:call-template></tr></table>
        <xsl:for-each select="xhtml:p[matches(substring(@id,1,1),'[^a-z]')]">
            <xsl:sort select="@id"/> 
            <xsl:choose>
                <xsl:when test="@id = (following::*/@id)"></xsl:when>
                <xsl:otherwise>
                    <div class="ptext">
                        <!--<xsl:attribute name="id">
                            <xsl:value-of select="translate(@id,(translate(@id,$good,'')),'')"/>
                            </xsl:attribute>-->
                        <xsl:apply-templates/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:for-each>
        <xsl:call-template name="listing"/>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@class='authors']">
        <div class="authors"><xsl:apply-templates/></div>
    </xsl:template>
</xsl:stylesheet>
