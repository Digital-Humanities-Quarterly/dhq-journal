<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

   <xsl:template match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="/* | /processing-instruction()">
      <xsl:text>&#xA;</xsl:text>
      <xsl:next-match/>
   </xsl:template>


   <xsl:template match="@dhqID">
      <xsl:attribute name="ID">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>

</xsl:stylesheet>
