<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dir="http://apache.org/cocoon/directory/2.0"
    xmlns:srw="http://www.loc.gov/zing/srw/"
    exclude-result-prefixes="xsl xs tei dhq cc rdf dir oai oai_dc srw"
    version="2.0">
    <!-- IF USING OXYGEN: doc-available() requires use of Saxon version 9.5.1.2 or higher. -->
    
    <xsl:param name="schema">oai</xsl:param>
    <xsl:param name="base-web-address">digitalhumanities.org</xsl:param>
    <xsl:param name="base-identifier">
        <xsl:value-of select="$schema"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$base-web-address"/>
        <xsl:text>:dhq/</xsl:text>
    </xsl:param>
    <!-- Currently set as the path relative to this stylesheet. -->
    <xsl:param name="pathToArticles">../../articles/</xsl:param>
    
    <!-- Tests a path for document availability and well-formedness. 
        Only errors are returned. -->
    <xsl:function name="dhq:usableRecord">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="doc-available($path) eq false()">
                <xsl:choose>
                    <xsl:when test="unparsed-text-available($path)">
                        <xsl:text>document is malformed</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>document not found</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="doc($path)//tei:publicationStmt/tei:date[not(@when[. castable as xs:date])]">
              <xsl:text>no usable publication date</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>none</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/">
        <list>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    
    <xsl:template match="journal[not(@editorial eq 'true')][not(@preview eq 'true')]//item">
        <xsl:variable name="src">
            <xsl:value-of select="concat($pathToArticles,@id,'/',@id,'.xml')"/>
        </xsl:variable>
        <item>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="src" select="$src"/>
            <xsl:call-template name="getRecord">
                <xsl:with-param name="id" select="@id"/>
                <xsl:with-param name="src" select="$src"/>
            </xsl:call-template>
        </item>
    </xsl:template>
    
    <xsl:template name="getRecord">
        <xsl:param name="id"/>
        <xsl:param name="src"/>
        <xsl:variable name="errors">
            <xsl:value-of select="dhq:usableRecord($src)"/>
        </xsl:variable>
        <xsl:choose>
            <!-- If the file is not malformed/unavailable, retrieve the 
                TEI metadata and create a "latestDatestamp" attribute. -->
            <xsl:when test="matches($errors,'none')">
                <xsl:variable name="latestDatestamp">
                    <xsl:call-template name="latestDatestamp">
                        <xsl:with-param name="path" select="$src"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="latestDatestamp" select="$latestDatestamp"/>
                <xsl:copy-of select="doc($src)//tei:teiHeader"/>
                <xsl:copy-of select="doc($src)//dhq:abstract"/>
            </xsl:when>
            <!-- If there are errors, create an attribute to identify 
                the problem. -->
            <xsl:otherwise>
                <xsl:attribute name="error">
                    <xsl:value-of select="$errors"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="latestDatestamp">
        <xsl:param name="path"/>
        <!-- The OAI record datestamp is taken from the latest date 
            in each article's change log. -->
        <xsl:variable name="latestDatestamp">
            <xsl:for-each select="doc($path)//tei:change[@when castable as xs:date]
                | doc($path)//tei:publicationStmt/tei:date[@when castable as xs:date]">
                <xsl:sort select="@when" order="descending" />
                <xsl:if test="position() = 1">
                    <xsl:value-of select="@when"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$latestDatestamp"/>
    </xsl:template>
    
</xsl:stylesheet>