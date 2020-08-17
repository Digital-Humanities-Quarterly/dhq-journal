<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs tei dhq cc rdf"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8"></xsl:output>
    <!-- The base web address expected for DHQ articles -->
    <xsl:param name="baseAddress">http://www.digitalhumanities.org/dhq/vol</xsl:param>
    <!-- The assumed language of the TEI record -->
    <xsl:param name="language">
        <xsl:value-of select="//tei:langUsage/tei:language/@ident"/>
    </xsl:param>
    
    <xsl:template match="processing-instruction()|comment()|text()"/>
    
    <!-- If used with oai_3_return-sru.xsl, this template will not match 
        anything. The result sets return only the teiHeader and 
        dhq:abstract, not the TEI root element. -->
    <xsl:template match="/TEI">
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
            <xsl:apply-templates/>
            <xsl:call-template name="basicInfo"/>
        </oai_dc:dc>
    </xsl:template>
    
    <!-- variableText mode is for those fields which could contain text 
        and/or child elements, and all text must be represented. -->
    <xsl:template match="*" mode="variableText">
        <xsl:apply-templates mode="variableText"/>
    </xsl:template>    
    <xsl:template match="text()" mode="variableText">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template name="basicInfo">
        <oai_dc:publisher xml:lang="en">Digital Humanities Quarterly</oai_dc:publisher>
        <oai_dc:format>application/xml</oai_dc:format>
    </xsl:template>
        
    <xsl:template match="tei:titleStmt/tei:title">
        <oai_dc:title>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$language"/>
            </xsl:attribute>
            <xsl:apply-templates mode="variableText"/>
        </oai_dc:title>
    </xsl:template>
    
    <xsl:template match="dhq:authorInfo">
        <oai_dc:creator>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$language"/>
            </xsl:attribute>
            <xsl:apply-templates select="dhq:author_name"/>
            <xsl:apply-templates select="dhq:affiliation"/>
        </oai_dc:creator>
    </xsl:template>
    <xsl:template match="dhq:author_name">
        <xsl:value-of select="text()"/><xsl:apply-templates select="dhq:family"/>
    </xsl:template>    
    <xsl:template match="dhq:family">
        <xsl:value-of select="text()"/>
    </xsl:template>
    <xsl:template match="dhq:affiliation">
        <xsl:text>, </xsl:text><xsl:value-of select="text()"/>
    </xsl:template>
    
    <xsl:template match="tei:publicationStmt">
        <oai_dc:identifier>
            <xsl:value-of select="$baseAddress"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="replace(tei:idno[@type='volume'],'^0+','')"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='issue']"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='DHQarticle-id']"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='DHQarticle-id']"/>
            <xsl:text>.xml</xsl:text>
        </oai_dc:identifier>
        <oai_dc:source xml:lang="en">
            <xsl:text>Digital Humanities Quarterly; Vol </xsl:text>
            <xsl:value-of select="replace(tei:idno[@type='volume'],'^0+','')"/>
            <xsl:text>, No </xsl:text>
            <xsl:value-of select="tei:idno[@type='issue']"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="tei:date"/>
            <xsl:text>)</xsl:text>
        </oai_dc:source>
        <oai_dc:relation>
            <xsl:value-of select="$baseAddress"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="replace(tei:idno[@type='volume'],'^0+','')"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='issue']"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='DHQarticle-id']"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="tei:idno[@type='DHQarticle-id']"/>
            <xsl:text>.html</xsl:text>
        </oai_dc:relation>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:publicationStmt/tei:date">
      <xsl:if test="@when[. castable as xs:date]">
        <oai_dc:date><xsl:value-of select="@when"/></oai_dc:date>
      </xsl:if>
    </xsl:template>
    
    <xsl:template match="dhq:articleType">
        <oai_dc:type xml:lang="en"><xsl:value-of select="text()"/></oai_dc:type>
    </xsl:template>
    
    <!-- maybe include availability in variableText mode? -->
    <xsl:template match="tei:availability">
        <oai_dc:rights><xsl:value-of select="text()"/><xsl:apply-templates/></oai_dc:rights>
    </xsl:template>    
    <xsl:template match="cc:License">
        <xsl:value-of select="@rdf:about"/>
    </xsl:template>
    
    <xsl:template match="tei:langUsage/tei:language">
        <oai_dc:language><xsl:value-of select="@ident"/></oai_dc:language>
    </xsl:template>
    
    <xsl:template match="tei:keywords/list/item">
        <oai_dc:subject><xsl:value-of select="text()"/></oai_dc:subject>
    </xsl:template>
    
    <xsl:template match="dhq:abstract">
        <oai_dc:description>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$language"/>
            </xsl:attribute>
            <xsl:apply-templates mode="variableText"/>
        </oai_dc:description>
    </xsl:template>
        
</xsl:stylesheet>