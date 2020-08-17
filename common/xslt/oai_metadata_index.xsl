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
    <!-- Runs oai_metadata_index_core.xsl and floats the erroneous 
        documents into a section at the top of the index. Returns 
        an index of TEI metadata. -->
    <!-- IF USING OXYGEN: imported stylesheet requires use of 
        Saxon version 9.5.1.2 or higher. -->
    <xsl:import href="oai_metadata_index_core.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="index">
            <xsl:apply-imports/>
        </xsl:variable>
        <index>
            <xsl:call-template name="floatErrors">
                <xsl:with-param name="index">
                    <xsl:perform-sort select="$index//item">
                        <xsl:sort select="@id"/>
                    </xsl:perform-sort>
                </xsl:with-param>
            </xsl:call-template>
        </index>
    </xsl:template>
    
    <xsl:template name="floatErrors">
        <xsl:param name="index"/>
        <errors>
            <xsl:copy-of select="$index//item[@error]"/>
        </errors>
        <list>
            <xsl:copy-of select="$index//item[@latestDatestamp]"/>
        </list>
    </xsl:template>
    
</xsl:stylesheet>