<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:biblio="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="xs dhq"
  version="2.0">
  
  <!-- This style sheets reads in the Biblio-A through Z .xml files. It also reads in a dhq_articles.xml file, a manually created, well-formed concatendation of all DHQ articles.
    
    For the output, it checks each biblio record to see if it is referenced by a bibl/@key attribute in the DHQ article corpus. If there is a reference in DHQ to the biblio record, the record is copied to the aggregated output. If there is no reference in DHQ to the biblio record, the item is excluded from the output.
    
    -->
    
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:variable name="biblioA">
    <xsl:copy-of select="document('file:../data/current/Biblio-A.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioB">
    <xsl:copy-of select="document('file:../data/current/Biblio-B.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioC">
    <xsl:copy-of select="document('file:../data/current/Biblio-C.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioD">
    <xsl:copy-of select="document('file:../data/current/Biblio-D.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioE">
    <xsl:copy-of select="document('file:../data/current/Biblio-E.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioF">
    <xsl:copy-of select="document('file:../data/current/Biblio-F.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioG">
    <xsl:copy-of select="document('file:../data/current/Biblio-G.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioH">
    <xsl:copy-of select="document('file:../data/current/Biblio-H.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioI">
    <xsl:copy-of select="document('file:../data/current/Biblio-I.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioJ">
    <xsl:copy-of select="document('file:../data/current/Biblio-J.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioK">
    <xsl:copy-of select="document('file:../data/current/Biblio-K.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioL">
    <xsl:copy-of select="document('file:../data/current/Biblio-L.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioM">
    <xsl:copy-of select="document('file:../data/current/Biblio-M.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioN">
    <xsl:copy-of select="document('file:../data/current/Biblio-N.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioO">
    <xsl:copy-of select="document('file:../data/current/Biblio-O.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioP">
    <xsl:copy-of select="document('file:../data/current/Biblio-P.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioQ">
    <xsl:copy-of select="document('file:../data/current/Biblio-Q.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioR">
    <xsl:copy-of select="document('file:../data/current/Biblio-R.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioS">
    <xsl:copy-of select="document('file:../data/current/Biblio-S.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioT">
    <xsl:copy-of select="document('file:../data/current/Biblio-T.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioU">
    <xsl:copy-of select="document('file:../data/current/Biblio-U.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioV">
    <xsl:copy-of select="document('file:../data/current/Biblio-V.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioW">
    <xsl:copy-of select="document('file:../data/current/Biblio-W.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioX">
    <xsl:copy-of select="document('file:../data/current/Biblio-X.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioY">
    <xsl:copy-of select="document('file:../data/current/Biblio-Y.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioZ">
    <xsl:copy-of select="document('file:../data/current/Biblio-Z.xml')"/>
  </xsl:variable>
  <xsl:variable name="biblioDHQ">
    <xsl:copy-of select="document('file:../data/current/DHQ-articles-Biblio.xml')"/>
  </xsl:variable>
  <xsl:variable name="articles">
    <xsl:copy-of select="document('file:dhq_articles.xml')"/>
  </xsl:variable>

  <xsl:template match="/">
    <BiblioSet xmlns="http://digitalhumanities.org/dhq/ns/biblio">
    <xsl:apply-templates select="$biblioA/biblio:BiblioSet/child::*"/>   
    <xsl:apply-templates select="$biblioB/biblio:BiblioSet/child::*"/>    
    <xsl:apply-templates select="$biblioC/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioD/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioE/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioF/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioG/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioH/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioI/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioJ/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioK/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioL/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioM/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioN/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioO/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioP/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioQ/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioR/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioS/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioT/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioU/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioV/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioW/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioX/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioY/biblio:BiblioSet/child::*"/>
    <xsl:apply-templates select="$biblioZ/biblio:BiblioSet/child::*"/> 
    <xsl:apply-templates select="$biblioDHQ/biblio:BiblioSet/child::*"/> 
    </BiblioSet>
  </xsl:template>
  
  <xsl:template match="Artwork|Book|BookInSeries|BookSection|BlogEntry|ConferencePaper|JournalArticle|Thesis|VideoGame|WebSite">
    <xsl:if test="$articles//tei:bibl/@key = @ID">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

