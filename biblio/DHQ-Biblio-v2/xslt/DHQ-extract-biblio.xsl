<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="#all"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio"
   xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
   version="2.0">

<!-- Extracts Biblio listings describing DHQ articles. That is, for each of a set of DHQ articles
     provided as input, a Biblio listing is generated. -->

   <!-- Run this on the toc.xml document as source!
        (The debugger works well, as long as this only needs to be run once.)
   -->
   
   <xsl:output indent="yes"/>
   
   <xsl:strip-space elements="*"/>
   
   <!--<xsl:variable name="filePath" select="''"/>-->
   
   <xsl:variable name="toc" select="/"/>
   
   <xsl:function name="dhq:uri-for-article">
      <!-- generates a lookup table for dhq articles by their id no. -->
      <xsl:param name="article-no" as="xs:string"/>
      <xsl:variable name="article-path" select="string-join((
         '../articles',$article-no,concat($article-no,'.xml')),'/')"/>
      <xsl:value-of select="resolve-uri($article-path,document-uri($toc))"/>
   </xsl:function>
   
   <xsl:template match="/">
      <xsl:call-template name="fileHeader"/>
      <xsl:variable name="biblio-set">
         <xsl:for-each-group select="//item" group-by="@id" xpath-default-namespace="">
            <xsl:variable name="dhq-article"
               select="document(dhq:uri-for-article(current-grouping-key()))"/>
            <xsl:apply-templates mode="make-biblio-for" select="$dhq-article">
               <xsl:with-param name="toc-code" select="current-grouping-key()" tunnel="yes"/>
            </xsl:apply-templates>
         </xsl:for-each-group>
      </xsl:variable>
      <BiblioSet>
         <xsl:for-each select="$biblio-set/*">
            <xsl:sort select="author[1]/familyName" xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"/>
            <xsl:copy-of select="."/>
         </xsl:for-each>
      </BiblioSet>
   </xsl:template>
   
   <xsl:template match="/*" mode="make-biblio-for">
      <!-- In the included stylesheet -->
      <xsl:next-match/>
   </xsl:template>
   
   <xsl:include href="dhq-article-biblio.xsl"/>
   
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