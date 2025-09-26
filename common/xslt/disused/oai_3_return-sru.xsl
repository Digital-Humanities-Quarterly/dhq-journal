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
    exclude-result-prefixes="xsl xs tei dhq cc rdf dir oai oai_dc"
    version="2.0">
    <xsl:import href="dhq2oaidc.xsl"/>
    <xsl:include href="decode_uri.xsl"/>
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <!-- OAI identifiers are constructed this way: 
           schema ':' base-web-address ':' unique-record-ID
         DHQ's unique-record-IDs are constructed:
           'dhq/' article-number
    -->
    <xsl:param name="schema">oai</xsl:param>
    <xsl:param name="base-web-address">digitalhumanities.org</xsl:param>
    <xsl:param name="base-identifier">
        <xsl:value-of select="$schema"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$base-web-address"/>
        <xsl:text>:dhq/</xsl:text>
    </xsl:param>
    <xsl:param name="recordSchema" required="yes" as="xs:string"/>
    <xsl:param name="recordPacking">xml</xsl:param>
    
    <xsl:variable name="decodedSchema">
        <xsl:value-of select="dhq:decodeURL($recordSchema)"/>
    </xsl:variable>
    
    <!-- Turn the narrowed result set into SRU -->
    <xsl:template match="/set">
        <srw:searchRetrieveResponse xmlns:srw="http://www.loc.gov/zing/srw/">
            <srw:version>1.1</srw:version>
            <srw:numberOfRecords>
                <xsl:value-of select="@totalRecords"/>
            </srw:numberOfRecords>
            <srw:records>
                <!-- Individual metadata records go here -->
                <xsl:apply-templates/>
            </srw:records>
            <!-- If there's need for a resumption token, include one -->
            <xsl:choose>
                <xsl:when test="matches(@nextRecordPosition,'none')"/>
                <xsl:when test="xs:integer(@nextRecordPosition)">
                    <srw:nextRecordPosition>
                        <xsl:value-of select="@nextRecordPosition"/>
                    </srw:nextRecordPosition>
                </xsl:when>
            </xsl:choose>
            <srw:resultSetId>
                <xsl:value-of select="@resultSetId"/>
            </srw:resultSetId>
        </srw:searchRetrieveResponse>
    </xsl:template>
    
    <!-- OAIcat makes 2 requests for the same set - first for the OAIheader, 
        then for the metadata record. It then merges the records for 
        individual articles. -->
    <xsl:template match="item">
        <xsl:choose>
            <!-- If OAIcat is looking for the OAI header -->
            <xsl:when test="$decodedSchema = ('http://www.openarchives.org/OAI/2.0/#header', 
                                              'http://www.openarchives.org/OAI/2.0/')">
                <xsl:call-template name="headerShell"/>
            </xsl:when>
            <!-- If OAIcat is looking for the OAI_DC metadata record -->
            <xsl:when test="$decodedSchema eq 'http://www.openarchives.org/OAI/2.0/oai_dc/'">
                <xsl:call-template name="recordShell"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- Generate the SRU shell for an OAIheader -->
    <xsl:template name="headerShell">
        <srw:record>
            <srw:recordSchema>http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd</srw:recordSchema>
            <srw:recordPacking>xml</srw:recordPacking>
            <srw:recordData>
                <oai:header xmlns:oai="http://www.openarchives.org/OAI/2.0/">
                    <xsl:call-template name="oaiheader"/>
                </oai:header>
            </srw:recordData>
        </srw:record>
    </xsl:template>
    
    <!-- Create the OAI header -->
    <xsl:template name="oaiheader">
        <!-- OAI identifier -->
        <oai:identifier>
            <xsl:value-of select="$base-identifier"/>
            <xsl:value-of select="@id"/>
        </oai:identifier>
        <oai:datestamp>
            <xsl:value-of select="@latestDatestamp"/>
        </oai:datestamp>
    </xsl:template>
    
    <!-- Generate the SRU shell for a metadata record. dhq2oaidc.xsl takes 
        over creating the Dublin Core record itself -->
    <xsl:template name="recordShell">
        <srw:record>
            <srw:recordSchema>http://www.openarchives.org/OAI/2.0/oai_dc/</srw:recordSchema>
            <srw:recordPacking>xml</srw:recordPacking>
            <srw:recordData>
                <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
                    <xsl:apply-templates>
                        <xsl:with-param name="articleLang" select="descendant::tei:language/@ident"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="basicInfo"/>
                </oai_dc:dc>
            </srw:recordData>
        </srw:record>
    </xsl:template>
    
    <!-- The next three templates are duplicates of those in 
        dhq2oaidc.xsl. These take into account that the language 
        for certain fields may differ depending on the article. -->    
    <xsl:template match="tei:titleStmt/tei:title">
        <xsl:param name="articleLang"/>
        <oai_dc:title>
            <xsl:if test="$articleLang">
                <xsl:attribute name="xml:lang" select="$articleLang"/>
            </xsl:if>
            <xsl:apply-templates mode="variableText"/>
        </oai_dc:title>
    </xsl:template>    
    <xsl:template match="dhq:authorInfo">
        <xsl:param name="articleLang"/>
        <oai_dc:creator>
            <xsl:if test="$articleLang">
                <xsl:attribute name="xml:lang" select="$articleLang"/>
            </xsl:if>
            <xsl:apply-templates select="dhq:author_name"/>
            <xsl:apply-templates select="dhq:affiliation"/>
        </oai_dc:creator>
    </xsl:template>    
    <xsl:template match="dhq:abstract">
        <xsl:param name="articleLang"/>
        <oai_dc:description>
            <xsl:if test="$articleLang">
                <xsl:attribute name="xml:lang" select="$articleLang"/>
            </xsl:if>
            <xsl:apply-templates mode="variableText"/>
        </oai_dc:description>
    </xsl:template>
    
</xsl:stylesheet>