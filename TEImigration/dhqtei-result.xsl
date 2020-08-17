<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- A shell for TEI-migrate.xsl
  
     When the input file is in a '/dhq/' branch of the filesystem,
     the result is written to the corresponding location in
     the '/dhq/' branch. -->


  <xsl:import href="TEI-migrate.xsl"/>
  
  <xsl:template name="header-pis">
    <xsl:processing-instruction name="oxygen">
      <xsl:text>RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
    <xsl:processing-instruction name="oxygen">
      <xsl:text>SCHSchema="../../common/schema/dhqTEI-ready.sch"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>
  
  <xsl:variable name="source-file"
    select="document-uri(/)[matches(.,'/dhq/articles/.+\.xml')]"/>
  <xsl:variable name="result-file"
    select="replace($source-file,'/dhq/','/dhq/')"/>

  <xsl:template match="/" name="start">
    <xsl:choose>
      <xsl:when test="string($source-file) and string($result-file)">
        <!--<xsl:message>
          <xsl:text>Transforming </xsl:text>
          <xsl:value-of select="$source-file"/>
          <xsl:text> to </xsl:text>
          <xsl:value-of select="$result-file"/>
        </xsl:message>-->

        <xsl:result-document href="{$result-file}" indent="yes" encoding="utf-8">
          <xsl:apply-imports/>
          <!--<xsl:copy-of select="."/>-->
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Sorry, source file not given properly (may not be in
          /dhq/articles branch)</xsl:message>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
