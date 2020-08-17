<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio"
   xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
   xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
   version="2.0">
   
   <!-- Run this XSLT on itself, or use the 'current-to-new' template as your entry point.
        
      -->
   <xsl:strip-space elements="*"/>
   
   <!-- elements that can have mixed content -->
   <xsl:preserve-space elements="title q i"/>

   <xsl:param name="target-dir" as="xs:string" select="concat( format-date(current-date(),'[Y][M01][D01]'), '-new' )"/>
   
   <xsl:variable name="allBiblioItems" select="collection('../data/current?select=*.xml;recurse=yes;on-error=ignore')/*/*"/>
   
   <xsl:template match="/" name="current-to-new">
      <xsl:for-each-group select="$allBiblioItems[dhq:uniqueID(.,$allBiblioItems)]" group-by="dhq:file-group(.)">
         <xsl:result-document href="../data/{$target-dir}/Biblio-{current-grouping-key()}.xml" indent="yes">
            <xsl:call-template name="fileHeader"/>
            <BiblioSet>            
               <xsl:apply-templates select="current-group()">
                  <xsl:sort select="@ID"/>
               </xsl:apply-templates>
            </BiblioSet>
         </xsl:result-document>
      </xsl:for-each-group>
      <xsl:for-each-group select="$allBiblioItems[not(dhq:uniqueID(.,$allBiblioItems))]" group-by="true()">
         <xsl:result-document href="../data/{$target-dir}/Biblio-dupes.xml" indent="yes">
            <xsl:call-template name="fileHeader"/>
            <BiblioSet>            
               <xsl:apply-templates select="current-group()">
                  <xsl:sort select="@ID/lower-case(.)"/>
               </xsl:apply-templates>
            </BiblioSet>
         </xsl:result-document>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="BiblioSet/*">
      <xsl:copy-of select="."/>
   </xsl:template>
   
   <xsl:function name="dhq:file-group" as="xs:string">
      <xsl:param name="biblio" as="element()"/>
      <!--  Returns a grouping key for any Biblio. This function provides whatever sorting
         is needed in the output. Currently:
           1. Any *problemGenres.xml file is left alone
           2. Duplicate listings (by the uniqueID function) are grouped as dupes
           3. Others are assigned the initial letter of the ID (generally also of the lead author surname)
      -->
      <xsl:choose>
         <xsl:when test="not(dhq:uniqueID($biblio,$allBiblioItems))">dupes</xsl:when>
         <xsl:when test="matches(document-uri($biblio/root()),'problemGenres\.xml$')">problemGenres</xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="upper-case(substring($biblio/@ID/normalize-space(.),1,1))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   
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
   
   <xsl:function name="dhq:uniqueID" as="xs:boolean">
      <xsl:param name="item" as="element()"/>
      <xsl:param name="set"  as="element()*"/>
      <xsl:sequence select="not($item/@ID/lower-case(.) = ($set except $item)/@ID/lower-case(.))"/>
   </xsl:function>
</xsl:stylesheet>