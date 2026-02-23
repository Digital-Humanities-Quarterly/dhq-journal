<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">

  <xsl:output method="text"/>
  
  <!--
    Read in the DHQ TOC file ([DHQbase]/toc/toc.xml), and write the
    relative path (from the articles/ directory) to each article file,
    one per line, *except* those in the "editorial" section of the
    TOC.  Articles are listed in issue order, and then by whatever
    order the <item> elements occur within the <journal> element.
    That is, do the equivalent of
    $ xmlstarlet sel -t -m "/toc/journal[ not( @editorial='true') ]//item" -s A:N:U "concat( ancestor::journal[1]/@vol, '.', ancestor::journal[1]/@issue)" -v "concat( @id, '/', @id, '.xml')" -n toc/toc.xml

    This program is currently called by the "validationPrep" target
    of the DHQ ant build file (../../build.xml).

    Written 2026-02-20 by Syd Bauman.
  -->
  <xsl:template match="/">
    <xsl:apply-templates select="/toc/journal[ not( @editorial eq 'true')]//item">
      <xsl:sort select="ancestor::journal[1] ! xs:float( concat( @vol, '.', @issue ) )"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="item">
    <xsl:variable name="id" select="normalize-space( @id )"/>
    <!--
      Use of <xsl:sequence> instead of <xsl:value-of>, below, causes
      an initial blank on all but 1st line, not sure why.
    -->
    <xsl:value-of select="$id||'/'||$id||'.xml&#x0A;'"/>
  </xsl:template>

</xsl:stylesheet>
