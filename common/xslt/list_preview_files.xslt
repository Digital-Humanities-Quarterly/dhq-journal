<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">

  <!--
      list_preview_files.xslt
      Copyleft 2024 Syd Bauman
      Input file: ignored
      Input directory: Specified by the parameters; default is
                       ../../../dhq-static/dhq/vol?select=*html;recurse=yes;on-error=ignore
      Output: A text file that lists every HTML file in the input
              directory whose <title> element contains the string
              “[PREVIEW] DHQ: Digital Humanities Quarterly”.
  -->
  
  <xsl:param name="dataDir" select="'../../../dhq-static/dhq/vol'"/>
  <xsl:param name="dataSel" select="'select=*html;'"/>
  <xsl:param name="dataParams" select="'recurse=yes;on-error=ignore'"/>
  <xsl:param name="collectUs" select="escape-html-uri( concat($dataDir,'?',$dataSel,$dataParams) )"/>
  
  <xsl:output method="text"/>
  
  <xsl:template name="xsl:initial-template" match="/">
    <xsl:variable name="testSet" select="collection( $collectUs )" as="document-node()*"/>
    <xsl:for-each select="$testSet/html:*/html:head[html:title[ contains(.,'[PREVIEW] DHQ: Digital Humanities Quarterly')]]">
      <xsl:value-of select="base-uri(.)||'&#x0A;'"/>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
