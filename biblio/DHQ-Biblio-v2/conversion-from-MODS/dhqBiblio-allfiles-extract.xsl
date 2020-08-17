<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xs mods"
  version="2.0"
  >

  <xsl:import href="dhqBiblio-extract.xsl"/>
  
  
  <xsl:variable name="files" select="collection('file:/F:/DHQ/Biblio-data-20130508')
    [true() or position() = (1 to 50)]"/>
  
  <xsl:param name="runtime-scope" select="'fileset'"/>
  
  <xsl:template match="/">
    <BiblioSet>
      <xsl:apply-templates select="$files/*"/>
    </BiblioSet>
  </xsl:template>
  
  <xsl:template match="xsl:*"/>
 
</xsl:stylesheet>