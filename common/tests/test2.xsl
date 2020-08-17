<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="test.xsl"/>

  <xsl:template name="datestamp">
    <xsl:text>This file was generated on </xsl:text>
    <xsl:value-of select="format-dateTime(current-dateTime(),
      '[FNn], [MNn] [D1], [Y], at [h]:[m01] [Pn]')"/>
  </xsl:template>
  
  <xsl:template match="whee">
    <big style="color:darkred;font-style:italic">
      <xsl:apply-templates/>
    </big>
  </xsl:template>
  
</xsl:stylesheet>