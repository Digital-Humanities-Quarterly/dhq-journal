<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0">
  
  <xsl:param name="including">xml only</xsl:param>
  
  <xsl:variable name="path-to-articles">../articles/</xsl:variable>
  
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="journal[@editorial='true']"/>
  
  <xsl:template match="item">
    <xsl:variable name="itemcode" select="@id"/>
    <xsl:variable name="filelocation" select="concat($itemcode, '/', $itemcode, '.xml')"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:value-of select="$filelocation"/>
    <xsl:if test="$including='everything'">
      <xsl:variable name="filepath" select="concat($path-to-articles,$filelocation)"/>
      <!-- Doing it ye olde-fashioned way for ye ancyente processores -->
      <xsl:for-each select="document($filepath, /)">
        <xsl:for-each select=".//tei:graphic/@url | .//tei:media/@url">
          <xsl:text>&#xA;</xsl:text>
          <xsl:value-of select="concat($itemcode, '/', .)"/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>