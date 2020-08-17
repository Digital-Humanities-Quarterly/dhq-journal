<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:dhq="http://www.digitalhumanities.org/ns/dhq">
    
    <xsl:output encoding="UTF-8" method="text"/>
    
    <xsl:template match="/">
        <!-- article id -->
        <xsl:value-of select="concat(//idno[@type = 'DHQarticle-id'],'&#x0009;')"/>
        <!-- author(s) -->
        <xsl:apply-templates select="//dhq:author_name"/>
        <!-- year -->
        <xsl:value-of select="concat(substring-before(/TEI/teiHeader/fileDesc/publicationStmt/date/@when, '-'), '&#x0009;')"/>
        <!-- get title -->
        <xsl:value-of select="concat(normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title),'&#x0009;')"/>
        <!-- get journal -->
        <xsl:value-of select="concat('Digital Humanities Quarterly','&#x0009;')"/>
        <!-- get abstract -->
        <xsl:call-template name="abstract"/>
        <!-- get references -->
        <xsl:choose>
          <xsl:when test="/TEI/text/back/listBibl/bibl">
            <xsl:apply-templates select="/TEI/text/back/listBibl/bibl"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'&#x0009;'"/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- set isDHQ booean -->
        <xsl:value-of select="concat('1','&#x0009;')"/>
        <xsl:value-of select="'&#x000a;'"/>
        
    </xsl:template>
    
    <xsl:template name="column_labels">
        <xsl:value-of select="'article id&#x0009;author&#x0009;year&#x0009;title&#x0009;journal/conference/collection&#x0009;abstract&#x0009;reference IDs&#x0009;isDHQ&#x000a;'"/>
    </xsl:template>
    
    <xsl:template match="//dhq:author_name">
        <xsl:param name="text_content">
            <xsl:apply-templates select="./text()"/>
        </xsl:param>
        <xsl:value-of select="normalize-space(dhq:family)"/>
        <xsl:if test="normalize-space($text_content) != ''">
            <xsl:value-of select="', '"/>
        </xsl:if>
        <xsl:value-of select="normalize-space($text_content)"/>
        <xsl:choose>
            <xsl:when test="position() != last()">
                <xsl:value-of select="' | '"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'&#x0009;'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="abstract">
        <xsl:param name="abstract">
            <xsl:apply-templates select="//dhq:abstract"/>
        </xsl:param>
        <xsl:value-of select="concat(normalize-space($abstract),'&#x0009;')"/>
    </xsl:template>
    
    <xsl:template match="dhq:author_name/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="bibl">
        <xsl:value-of select="@xml:id"/>
        <xsl:choose>
            <xsl:when test="position() != last()">
                <xsl:value-of select="' | '"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'&#x0009;'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>