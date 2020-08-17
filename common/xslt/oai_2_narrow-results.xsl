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
    <xsl:output method="xml" encoding="UTF-8"></xsl:output>
    
    <!-- Set which record (within the query result set) at which to start -->
    <xsl:param name="startRecord" required="yes" as="xs:integer"/>
    <!-- Set the maximum records to be returned -->
    <xsl:param name="maxRecords" as="xs:integer">50</xsl:param>
    <!-- Calculate a record position for the resumption token -->
    <xsl:variable name="endRecord" as="xs:integer">
        <xsl:value-of select="$startRecord + $maxRecords"/>
    </xsl:variable>
    
    <xsl:template match="/set">
        <!-- If the $endRecord exists, set it as the nextRecordPosition -->
        <xsl:variable name="nextRecordPosition">
            <xsl:choose>
                <xsl:when test="exists(item[position() = $endRecord])">
                    <xsl:value-of select="$endRecord"/>
                </xsl:when>
                <!-- If there is no record at the $endRecord position, set 
                    nextRecordPosition as "none" -->
                <xsl:otherwise>
                    <xsl:text>none</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <!--<xsl:attribute name="query" select="@query"/>-->
            <xsl:attribute name="resultSetId" select="@resultSetId"/>
            <xsl:attribute name="totalRecords" select="count(item)"/>
            <xsl:attribute name="nextRecordPosition" select="$nextRecordPosition"/>
            <!-- Only transform those records within the maximum allowed -->
            <xsl:apply-templates 
                select="item[(position() ge xs:integer($startRecord)) and (position() lt $endRecord)]"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Pass on individual record information -->
    <xsl:template match="item">
        <xsl:copy>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="src" select="@src"/>
            <xsl:attribute name="latestDatestamp" select="@latestDatestamp"/>
            <xsl:attribute name="recordPosition" select="position()"/>
            <xsl:copy-of select="doc(@src)//tei:teiHeader"/>
            <xsl:copy-of select="doc(@src)//dhq:abstract"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>