<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio" version="2.0">

   <!-- Creates   -->

   <xsl:import href="extract-biblio.xsl"/>

   <xsl:variable name="filePath" select="'../../DHQ-Biblio-v2/data/current'"/>
   <xsl:variable name="allBiblio"
      select="collection(concat($filePath, '?select=*.xml;recurse=yes;on-error=ignore'))/*/*"/>

   <xsl:template match="listBibl">
      <BiblioSet>
         <xsl:apply-templates select="*[not(@key = ('[unlisted]', $allBiblio/@ID))]"/>
      </BiblioSet>
   </xsl:template>

   <xsl:template match="listBibl/*[not(@key = ('[unlisted]', $allBiblio/@ID))]" priority="2">
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment>
         <xsl:choose>
            <xsl:when test="empty(@key)"> No key is given </xsl:when>
            <xsl:otherwise>
               <xsl:text> @key '</xsl:text>
               <xsl:value-of select="@key"/>
               <xsl:text>' is not in Biblio </xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:comment>
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-imports/>
   </xsl:template>

</xsl:stylesheet>
