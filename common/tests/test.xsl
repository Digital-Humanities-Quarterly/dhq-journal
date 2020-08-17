<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head>
        <title>Cocoon 2.2 Test using XSLT <xsl:value-of select="system-property('xsl:version')"/></title>
      </head>
      <body>
        <xsl:call-template name="datestamp"/>
        <xsl:apply-templates select="/content"/>
        <div style="font-size:85%; border: thin solid black; padding:0.5em; margin:0.5em; background-color: lemonchiffon">
            <p style="margin:0em">
              <xsl:text>XSL version: </xsl:text>
              <xsl:value-of select="system-property('xsl:version')"/>
              <xsl:text>&#xA;</xsl:text>
            </p>
            <p style="margin:0em">
              <xsl:text>Vendor: </xsl:text>
              <xsl:value-of select="system-property('xsl:vendor')"/>
              <xsl:text>&#xA;</xsl:text>
            </p>
            <p style="margin:0em">
              <xsl:text>Vendor URL: </xsl:text>
              <xsl:value-of select="system-property('xsl:vendor-url')"/>
              <xsl:text>&#xA;</xsl:text>
            </p>
         </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="datestamp"/>
  
  <xsl:template match="content">
    <h4>
      <xsl:apply-templates/>
    </h4>
  </xsl:template>
  
  <xsl:template match="whee">
    <big style="color:darkgreen;font-style:italic">
      <xsl:apply-templates/>
    </big>
  </xsl:template>

</xsl:stylesheet>