<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xs mods" xmlns="http://digitalhumanities/dhq/ns/biblio"
  xpath-default-namespace="http://digitalhumanities/dhq/ns/biblio" version="2.0">

  <xsl:template match="/*/*">
    <Biblio genre="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </Biblio>
  </xsl:template>

  <xsl:template match="book | journal | publication | series | source">
    <source type="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </source>
  </xsl:template>
  
  <xsl:template match="author | editor | creator | translator | contributor | etal">
    <contributor type="{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </contributor>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
