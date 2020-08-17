<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:dhqBiblio="http://digitalhumanities.org/dhq/ns/biblio"
   xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
   exclude-result-prefixes="#all"
   version="2.0">
   
   <xsl:import href="dhqBiblio-ChicagoLoose-html.xsl"/>

<!--   <xsl:import href="xpath-write.xsl"/>-->
   
   <xsl:output indent="no"/>
   
   <xsl:strip-space elements="*"/>
   
   <xsl:preserve-space elements="title additionalTitle"/>
   
   <xsl:variable name="biblioListings" select="/*/*"/>
   
   <xsl:template match="/">
      <html>
         <head>
            <title>DHQ Biblio display</title>
         <style type="text/css">
            div.bibl { margin-top: 0.5em; border-left: medium solid grey; padding-left: 0.5em }
            
            div.dhqBiblioArtwork         { border-color: gold }
            div.dhqBiblioBlogEntry       { border-color: grey }
            div.dhqBiblioBook            { border-color: blue }
            div.dhqBiblioBookInSeries    { border-color: slateblue }
            div.dhqBiblioBookSection     { border-color: midnightblue }
            div.dhqBiblioConferencePaper { border-color: darkgreen }
            div.dhqBiblioJournalArticle  { border-color: green }
            div.dhqBiblioThesis          { border-color: olivedrab }
            div.dhqBiblioVideoGame       { border-color: darkred }
            div.dhqBiblioWebSite         { border-color: rosybrown }
            
            td { border-top: thin solid black; padding-top: 0.5ex }
            
         </style>
         </head>
      <body>
         <table width="100%">
            <xsl:for-each select="$biblioListings">
            <tr>
               <td style="text-align: right; width: 40%">
                  <span style="font-size: 80%; font-family: sans-serif; font-weight: bold" >
                  <xsl:value-of select="local-name()"/>
                  </span>
                  <br class="br"/>
                  <span  style="font-family: monospace">
                  <xsl:apply-templates select="." mode="xpath"/>
                  </span>
               </td>
               <td>
                  <xsl:apply-templates select="." mode="dhqBiblio:ChicagoLoose"/>
               </td>
            </tr>
            </xsl:for-each>
         </table>
      </body>
      </html>
   </xsl:template>
   
   <xsl:template mode="xpath" match="*">
      <xsl:text>//</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>[@ID='</xsl:text>
      <xsl:value-of select="@ID"/>
      <xsl:text>']</xsl:text>
   </xsl:template>
   
</xsl:stylesheet>