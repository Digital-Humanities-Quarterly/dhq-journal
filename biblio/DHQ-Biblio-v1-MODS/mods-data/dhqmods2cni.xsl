<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xpath-default-namespace="http://www.loc.gov/mods/v3">
    <!-- questions:
        
        * 136 records lack mods:date element. See no_date.txt
        * Are these both authors:
         <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:saxon="http://saxon.sf.net/" version="3.2">
        <mods:name xmlns="http://www.loc.gov/mods/v3" type="personal">
            <mods:role>
                <mods:roleTerm type="text">author</mods:roleTerm>
            </mods:role>
            <mods:namePart type="given">F.</mods:namePart>
            <mods:namePart type="family">Thomas</mods:namePart>
        </mods:name>
        <mods:name xmlns="http://www.loc.gov/mods/v3" type="personal">
            <mods:namePart type="given">O.</mods:namePart>
            <mods:namePart type="family">Johnston</mods:namePart>
        </mods:name>
        
    -->        
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:call-template name="column_labels"/>
        <xsl:apply-templates select="//mods"/>
    </xsl:template>
    
    <xsl:template name="column_labels">
        <xsl:value-of select="'article id&#x0009;author&#x0009;year&#x0009;title&#x0009;journal/conference/collection&#x0009;abstract&#x0009;reference IDs&#x0009;isDHQ&#x000a;'"/>
    </xsl:template>
       
    
    <xsl:template match="Book|BookSection|ConferencePaper|JournalArticle|WebSite">
        <!-- get id -->
        <xsl:value-of select="concat(normalize-space(identifier[@type = 'dhq']),'&#x0009;')"/>
        <!-- get author names -->
        <xsl:apply-templates select="name"/>
        <!-- get publication year -->
        <!-- <xsl:call-template name="get-date"/> -->
        <xsl:value-of select="concat(normalize-space(date),'&#x0009;')"/>
        <!-- get title -->
        <xsl:value-of select="concat(normalize-space(titleInfo/title),'&#x0009;')"/>
        <!-- get journal title -->
        <xsl:value-of select="concat(normalize-space(relatedItem/titleInfo/title),'&#x0009;')"/>
        <!-- get abstract: currently no abstracts -->
        <xsl:value-of select="'&#x0009;'"/>
        <!-- get reference IDs: only for DHQ articles, not yet -->
        <xsl:value-of select="'&#x0009;'"/>
        <!-- isDHQ boolean -->
        <xsl:choose>
            <xsl:when test="normalize-space(relatedItem/titleInfo/title) = 'Digital Humanities Quarterly'">
                <xsl:value-of select="'1'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'0'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="'&#x0009;'"/>
        <!-- new line -->
        <xsl:value-of select="'&#x000a;'"/>
    </xsl:template>
    
    <!-- <xsl:template name="get-authors" match="//name[role/roleTerm = 'author'] or "> -->
    <xsl:template name="get-authors" match="author|editor|creator">
      <xsl:choose>
        <xsl:when test="corporateName">
          <xsl:value-of select="normalize-space(corporateName)"/>
          <xsl:choose>
            <xsl:when test="position() != last()">
              <xsl:value-of select="' | '"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'&#x0009;'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="normalize-space(familyName)"/>
            <xsl:if test="namePart[@type = 'given']">
                <xsl:value-of select="', '"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(givenName)"/>
            <xsl:choose>
                <xsl:when test="position() != last()">
                    <xsl:value-of select="' | '"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'&#x0009;'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template name="get-date">
        <xsl:choose>
            <xsl:when test="originInfo/dateIssued">
                <xsl:value-of select="normalize-space(originInfo/dateIssued)"/>
            </xsl:when>
            <xsl:when test=".//date">
                <xsl:value-of select="normalize-space(.//date)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'n.d.'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="'&#x0009;'"/>
    </xsl:template>
        
    
</xsl:stylesheet>