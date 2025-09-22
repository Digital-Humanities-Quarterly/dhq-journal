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
    <xsl:include href="decode_uri.xsl"/>
    
    <!-- OAI identifiers are constructed this way: 
           schema ':' base-web-address ':' unique-record-ID
         DHQ's unique-record-IDs are constructed:
           'dhq/' article-number
    -->
    <xsl:param name="schema">oai</xsl:param>
    <xsl:param name="base-web-address">digitalhumanities.org</xsl:param>
    <xsl:variable name="base-identifier">
        <xsl:value-of select="$schema"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$base-web-address"/>
        <xsl:text>:dhq/</xsl:text>
    </xsl:variable>
    <!-- Take the user's request query -->
    <xsl:param name="query" required="yes" as="xs:string"/>
    <!-- Path to the articles folder from the XSLT folder -->
    <xsl:param name="pathToArticles">../../articles/</xsl:param>
    
    <xsl:variable name="decodedQuery">
        <xsl:value-of select="dhq:decodeURL($query)"/>
    </xsl:variable>
    <xsl:variable name="setID">
        <xsl:if test="contains($decodedQuery,'cql.resultSetId')">
            <xsl:value-of 
                select="substring-after($decodedQuery,'=')"/>
        </xsl:if>
    </xsl:variable>
    <!-- Remove unnecessary parts of the query -->
    <xsl:variable name="cleanQuery">
        <xsl:value-of 
            select="
            replace(
                replace(
                    replace(
                        replace(
                            replace(
                                $decodedQuery,' ?(\+|\\|\(|\)|&quot;) ?',''
                            ),
                            'oai.identifierexact', 'id_'
                        ),
                        'oai.datestamp&gt;=','from'
                    ),
                    'cql.resultSetId=',''
                ),
                'oai.datestamp&lt;=','to'
            )
            "/>
    </xsl:variable>
    <!-- A date token can be "fromYYYY-MM-DD" or "toYYYY-MM-DD" -->
    <xsl:variable name="dateTokens" select="tokenize($cleanQuery,'[and | _]')"/>
    <!-- Set start date for set -->
    <xsl:variable name="from">
        <!-- Grab only the date with "from" attached -->
        <xsl:variable name="fromDate">
            <xsl:for-each select="$dateTokens">
                <xsl:if test="contains(.,'from')">
                    <xsl:value-of select="substring-after(.,'from')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$fromDate castable as xs:date">
                <xsl:value-of select="$fromDate"/>
            </xsl:when>
            <!-- If the specified start date is invalid, use default date. -->
            <xsl:otherwise>
                <xsl:text>0001-01-01</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Set end date for set -->
    <xsl:variable name="until">
        <!-- Grab only the date with "to" attached -->
        <xsl:variable name="untilDate">
            <xsl:for-each select="$dateTokens">
                <xsl:if test="contains(.,'to')">
                    <xsl:value-of select="substring-after(.,'to')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$untilDate castable as xs:date">
                <xsl:value-of select="$untilDate"/>
            </xsl:when>
            <!-- If there is no specified end date or the specified end date is 
              erroneous, use default date -->
            <xsl:otherwise>
                <xsl:text>9999-12-31</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Generate requested set -->
    <xsl:template match="/">
        <set>
            <!--<xsl:attribute name="query" select="$query"/>-->
            <xsl:choose>
                <!-- If the request is for records with a certain identifier. -->
                <xsl:when test="contains($cleanQuery,'id')">
                    <xsl:variable name="articleID">
                        <xsl:choose>
                            <xsl:when test="contains($cleanQuery, 'id')">
                                <xsl:value-of select="substring-after($cleanQuery,'/')"/>
                            </xsl:when>
                            <xsl:when test="contains($setID,'id')">
                                <xsl:value-of select="substring-after($setID,'id')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Example resultSetID: "id000001" -->
                    <xsl:attribute name="resultSetId">
                        <xsl:text>id</xsl:text>
                        <xsl:value-of select="$articleID"/>
                    </xsl:attribute>
                    <xsl:apply-templates mode="oai.identifier">
                        <xsl:with-param name="queryID" select="$articleID" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- If the request is for records within two dates. -->
                <xsl:when test="contains($decodedQuery,'oai.datestamp') or contains($setID,'from')">
                    <!-- Example resultSetID: "from0001-01-01_to9999-12-31" -->
                    <xsl:attribute name="resultSetId">
                        <xsl:text>from</xsl:text>
                        <xsl:value-of select="$from"/>
                        <xsl:text>_</xsl:text>
                        <xsl:text>to</xsl:text>
                        <xsl:value-of select="$until"/>
                    </xsl:attribute>
                    <xsl:apply-templates mode="oai.datestamp"/>
                </xsl:when>
            </xsl:choose>
        </set>
    </xsl:template>
    
    <!-- Suppress any indexed articles without a valid datestamp. -->
    <xsl:template match="list/item[not(@latestDatestamp castable as xs:date)]" mode="oai.datestamp oai.identifier"/>
    
    <!-- Test whether the file in question meets requested parameters. -->
    <xsl:template match="list/item" mode="oai.identifier">
        <xsl:param name="queryID" tunnel="yes"/>
        <xsl:if test="contains(@id,$queryID)">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <!-- Only pull the records within the specified time period. -->
    <xsl:template match="list/item" mode="oai.datestamp">
        <xsl:if test="xs:date(@latestDatestamp) ge xs:date($from)">
            <xsl:if test="xs:date(@latestDatestamp) le xs:date($until)">
                <xsl:copy-of select="."/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>