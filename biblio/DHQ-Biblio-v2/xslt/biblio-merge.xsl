<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio"
   xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
   version="2.0">

<!-- Use this to run a merge marking provenance of merged items,
     not for routine Biblio updates (for which use biblio-rearrange.xsl).
   
   -->

   <xsl:strip-space elements="*"/>
   
   <!--<xsl:variable name="filePath" select="''"/>-->
   
   <xsl:variable name="allBiblioItems" select="collection('../data/current?select=*.xml;recurse=yes;on-error=ignore')/*/*"/>
   
   <xsl:template match="/">
      <xsl:for-each-group select="$allBiblioItems" group-by="upper-case(substring(@ID,1,1))">
         <xsl:result-document href="../data/current/Biblio-{current-grouping-key()}.xml" indent="yes">
            <xsl:call-template name="fileHeader"/>
            <BiblioSet>            
               <xsl:apply-templates select="current-group()">
                  <xsl:sort select="@ID"/>
               </xsl:apply-templates>
            </BiblioSet>
         </xsl:result-document>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="BiblioSet/*">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:call-template name="mark-provenance"/>
         <xsl:copy-of select="*"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template name="mark-provenance">
      <xsl:attribute name="provenance">
         <xsl:apply-templates select="/*" mode="provenance-value"/>
      </xsl:attribute>
   </xsl:template>
   
   <xsl:template mode="provenance-value" match="/">???</xsl:template>
   
   <xsl:template mode="provenance-value" match="/*[matches(document-uri(/),'/legacy/')]">legacy</xsl:template>
   
   <xsl:template mode="provenance-value" match="/*[matches(document-uri(/),'/merging/')]">jm2014</xsl:template>
   
   <xsl:template name="fileHeader">
      <xsl:variable name="PIs" as="element()+">
         <PI name="xml-model">href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax"</PI>
         <PI name="xml-model">href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</PI>
         <PI name="xml-stylesheet">type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"</PI>
      </xsl:variable>
      <xsl:for-each select="$PIs">
         <xsl:text>&#xA;</xsl:text>
         <xsl:processing-instruction name="{@name}">
            <xsl:value-of select="."/>
         </xsl:processing-instruction>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>
   </xsl:template>
   
</xsl:stylesheet>