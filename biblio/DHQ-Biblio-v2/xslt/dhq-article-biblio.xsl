<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://digitalhumanities.org/dhq/ns/biblio"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
   exclude-result-prefixes="#all"
   version="2.0">
   
<!-- Not standalone - called from DHQ-extract-biblio.xsl  -->
   
   <xsl:template match="TEI" mode="make-biblio-for">
      <xsl:param name="toc-code" tunnel="yes" required="yes"/>
      <xsl:variable name="author-year" select="concat(
         teiHeader/fileDesc/titleStmt/dhq:authorInfo[1]/dhq:author_name/dhq:family[1]/normalize-space(.),
         teiHeader/fileDesc/publicationStmt/date/@when/replace(.,'^(\d{4}).*$','$1')
         )"/>
      <JournalArticle dhqID="{$toc-code}" issuance="monographic"
        ID="{$author-year}">
        <xsl:apply-templates mode="#current" select="teiHeader/fileDesc/titleStmt/dhq:authorInfo"/>
        <xsl:apply-templates mode="#current" select="teiHeader/fileDesc/titleStmt/title"/>
        <journal issuance="continuing">
           <title>Digital Humanities Quarterly</title>
           <xsl:apply-templates mode="#current" select="teiHeader/fileDesc/publicationStmt/idno[@type='volume']"/>
           <xsl:apply-templates mode="#current" select="teiHeader/fileDesc/publicationStmt/idno[@type='issue']"/>
           <xsl:apply-templates mode="#current" select="teiHeader/fileDesc/publicationStmt/date"/>
        </journal>
        <url>
           <xsl:text>http://www.digitalhumanities.org/dhq/vol/</xsl:text>
           <xsl:value-of select="string-join(
              (teiHeader/fileDesc/publicationStmt/idno[@type='volume'],
               teiHeader/fileDesc/publicationStmt/idno[@type='issue'],
               $toc-code,$toc-code
              ),'/')"/>
              <xsl:text>.html</xsl:text>
           <!-- http://www.digitalhumanities.org/dhq/vol/8/3/000184/000184.html          -->
        </url>
     </JournalArticle>   
   </xsl:template>
   
   <xsl:template match="dhq:authorInfo" mode="make-biblio-for">
      <author>
         <xsl:apply-templates select="dhq:author_name" mode="#current"/>
      </author>
   </xsl:template>

   <xsl:template match="dhq:author_name" mode="make-biblio-for">
      <xsl:for-each-group select="text()|* except dhq:family" group-by="true()">
         <givenName>
            <xsl:value-of select="normalize-space(string-join(current-group(),''))"/>
         </givenName>
      </xsl:for-each-group>
      <xsl:for-each select="dhq:family">
         <familyName>
            <xsl:value-of select="."/>
         </familyName>
      </xsl:for-each>
   </xsl:template>
   
   <xsl:template match="titleStmt/title" mode="make-biblio-for">
      <title>
         <xsl:apply-templates mode="#current"/>
      </title>
   </xsl:template>
   
   <xsl:template match="title/title" mode="make-biblio-for">
      <i>
         <xsl:apply-templates mode="#current"/>
      </i>
   </xsl:template>
   
   <xsl:template match="title/quote | title/q" mode="make-biblio-for">
      <xsl:text>“</xsl:text>
      <xsl:apply-templates mode="#current"/>
      <xsl:text>”</xsl:text>
   </xsl:template>
   
   <xsl:template match="idno[@type='volume']" mode="make-biblio-for">
      <volume>
         <xsl:apply-templates mode="#current"/>
      </volume>
   </xsl:template>
   
   <xsl:template match="idno[@type='issue']" mode="make-biblio-for">
      <issue>
         <xsl:apply-templates mode="#current"/>
      </issue>
   </xsl:template>
   
   <xsl:template match="date" mode="make-biblio-for">
      <date>
         <xsl:copy-of select="@when"/>
         <xsl:apply-templates mode="#current"/>
      </date>
   </xsl:template>
   
   
   
</xsl:stylesheet>