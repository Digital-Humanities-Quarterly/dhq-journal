<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="#all"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio"
   xmlns:biblio="http://digitalhumanities.org/dhq/ns/biblio/util"
   xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
   version="2.0">
   
   <!-- Run this XSLT on itself, or use the 'current-to-new' template as your entry point.
      
      This is the @ready sensitive merge.
      
      This stylesheet merges all entries inside the source direectory, into a target directory,
      allocating any "ready" entries to the alphabetic files and rewriting (reproducing)
      files for entries not marked as ready, preserving their organization etc.
      
      Note that old "alphabetic" files must be marked as @ready='true' for their listings to be included.
      
      -->
   
   <xsl:strip-space elements="*"/>
   
   <!-- elements that can have mixed content -->
   <xsl:preserve-space elements="title q i"/>

   <!-- Paths relative to main XSLT file. -->
   <xsl:param name="source-dir" as="xs:string" select="'../data/current'"/>
   <xsl:param name="target-dir" as="xs:string" select="concat('../data/', format-date(current-date(),'[Y][M01][D01]'), '-new' )"/>
   
   <xsl:variable name="source-path" select="concat($source-dir,'?select=*.xml;recurse=yes;on-error=ignore')"/>
   <xsl:variable name="allBiblioItems" select="collection($source-path)//BiblioSet/*[not(self::BiblioSet)]"/>
   
<!-- Add Schematron rules to validate alphabetic files set to @ready='true'
     Add error if (/BiblioSet/@ready='true') but also (//@ready='false') (somewhere in the file)
     Add error if everything is ready but not(/*/@ready='true')

Runtime messaging -
       When alphabetic files are run (with old/new counts?)
       For files being rewritten since they are not(@ready='true') at the top.
         When //BiblioSet/@ready='true', report the (re)allocation. -->
   
   
   <xsl:template match="/" name="current-to-new">
<!-- two mappings are needed: one from all 'ready' listings into their serialized results,
         grouping by target (alphabetic) categories;
      the other, over all files, copying through when when things are not 'ready'), or
      (when the entire thing is ready) nothing at all (just a message). -->
      
      <xsl:for-each select="$allBiblioItems/root()">
         <xsl:variable name="filename" select="replace(document-uri(/),'.*/','')"/>
         <xsl:choose>
            <!-- We skip a file anytime we can determine it is all ready -->
            <xsl:when test="empty(//(* except BiblioSet)[not(biblio:ready(.))])">
               <xsl:if test="not(matches($filename,'Biblio\-[A-Z]\.xml$'))">
                  <xsl:message>
                     <xsl:text>Not producing a file for </xsl:text>
                     <xsl:value-of select="$filename"/>
                     <xsl:text> as its listings are all grouped as 'ready'.</xsl:text>
                  </xsl:message>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <!-- Make a fresh file for this one -->
               <xsl:call-template name="make-result-file">
                  <xsl:with-param name="target-file" select="concat($target-dir,'/',$filename)"/>
                  <xsl:with-param name="file-contents">
                     <xsl:apply-templates mode="copy-unready"/>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:otherwise>
            
         </xsl:choose>
      </xsl:for-each>
      
      <!-- Next, writing out the alphabetic files with all the ready stuff -->
      <!-- Note that duplicates are merged together and will appear together; we
             want a separate filter to deduplicate (and/or Schematron) -->
      <xsl:for-each-group select="$allBiblioItems[biblio:ready(.)]" group-by="biblio:target-file(.)">
         <xsl:call-template name="make-result-file">
            <xsl:with-param name="target-file" select="concat($target-dir,'/',current-grouping-key())"/>
            <xsl:with-param name="file-contents">
               <!-- Just copying the group, not processing. -->
               <BiblioSet ready="true">
                 <xsl:copy-of select="current-group()" copy-namespaces="no"/>
               </BiblioSet>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:for-each-group>
      
   </xsl:template>
   
   <xsl:template name="make-result-file">
      <xsl:param name="target-file"/>
      <xsl:param name="file-contents"/>
      <xsl:message>
         <xsl:text>Making file '</xsl:text>
         <xsl:value-of select="$target-file"/>
      </xsl:message>
      <xsl:result-document href="{$target-file}" indent="yes">
         <xsl:call-template name="fileHeader"/>
         <xsl:copy-of select="$file-contents"/>
      </xsl:result-document>
   </xsl:template>
   
   <xsl:template match="node() | @*" mode="#all">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="BiblioSet" priority="2" mode="copy-unready">
      <xsl:copy copy-namespaces="no">
         <xsl:apply-templates select="node() | @*" mode="copy-unready"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- Things not marked as ready (by virtue of containment) don't match. -->
   <xsl:template match="BiblioSet/*[biblio:ready(.)]" mode="copy-unready"/>
   
   <xsl:function name="biblio:target-file" as="xs:string">
      <xsl:param name="biblio" as="element()"/>
      <xsl:value-of select="concat('Biblio-',upper-case(substring($biblio/@ID/normalize-space(.),1,1)),'.xml')"/>
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
   
   <xsl:function name="biblio:uniqueID" as="xs:boolean">
      <xsl:param name="item" as="element()"/>
      <xsl:param name="set"  as="element()*"/>
      <xsl:sequence select="not($item/@ID/lower-case(.) = ($set except $item)/@ID/lower-case(.))"/>
   </xsl:function>
   
   <xsl:function name="biblio:ready" as="xs:boolean">
      <xsl:param name="item" as="element()"/>
      <xsl:sequence select="$item/ancestor-or-self::*[exists(@ready)][1]/@ready = 'true'"/>
   </xsl:function>
   
</xsl:stylesheet>