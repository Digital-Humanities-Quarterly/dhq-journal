<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns:http="http://expath.org/ns/http-client"
  version="2.0">
  
<!--  Extracts bibl listings from a DHQ article and converts them into a rough version of Biblio format,
      providing a rough start at data entry. -->
  
  <xsl:strip-space elements="TEI text front body back listBibl"/>
  
  <xsl:output indent="yes" method="xml"/>
  
  <xsl:template match="/">
    <!--<?xml-model href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax"?>
    <?xml-model href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    <?xml-stylesheet type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"?>-->
    <!--<xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.rnc" type="application/relax-ng-compact-syntax</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="../../schema/dhqBiblio.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../../css/dhqBiblio-formal.css" title="Formal" alternate="no"</xsl:processing-instruction>-->
    <xsl:apply-templates select="//back/listBibl"/>
  </xsl:template>
  
  <xsl:template match="listBibl">
    <BiblioSoup>
      <xsl:apply-templates/>
    </BiblioSoup>
  </xsl:template>
  
  <xsl:template match="listBibl/*">
    <BiblioItem dhqID="{@xml:id}">
       <xsl:for-each select="@key">
          <xsl:attribute name="ID" select="."/>
       </xsl:for-each>
       <xsl:text>&#xA;&#xA;</xsl:text>
       <bibl>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
       </bibl>
       
       <xsl:variable name="grobid-call" as="xs:string">
          <xsl:variable name="call-string">
             <xsl:apply-templates select="." mode="grobid-call"/>
          </xsl:variable>
          <xsl:value-of>
            <xsl:text>http://buteo:8984/Grobid/</xsl:text>
            <xsl:value-of select="encode-for-uri($call-string)"/>
          </xsl:value-of>
       </xsl:variable>
       <xsl:if test="doc-available($grobid-call)">
         <xsl:apply-templates mode="cast-ns" select="doc($grobid-call)/*/*:biblStruct"/>
       </xsl:if>
       <!--<xsl:value-of select="$grobid-call"/>-->
       
       <!-- curl -X POST -d "citations=Graff, Expert. Opin. Ther. Targets (2002) 6(1): 103-113" localhost:8070/api/processCitation -->
       <!--<xsl:variable name="request">
          <http:request href="http://192.168.0.172:8070/api/processCitation" method="post">
             <http:body content-type="text/plain">
                <xsl:text>citations=</xsl:text>
                <xsl:value-of select="."/>
             </http:body>
          </http:request>
       </xsl:variable>
       <xsl:sequence select="http:send-request($request)"/>-->
    </BiblioItem>
  </xsl:template>
  
  
   <!--https://api.crossref.org/funders/100000015/works?query.bibliographic=Losh 2009-->
  
  
  
  <!-- dropping URIs 'cause it confuses Grobid -->
  <xsl:template mode="grobid-call" match="ref[string(.) castable as xs:anyURI]"/>
   
  <xsl:template match="text()" mode="#default grobid-call">
     <xsl:value-of select="replace(.,'\s+',' ')"/>
  </xsl:template>
   
  <!-- ref becomes url -->
  <xsl:template match="ref">
    <url>
      <!-- Copying @target unless it is also given as the element contents -->
      <xsl:copy-of select="@target[not(normalize-space(.) = normalize-space(current()))]"/>
      <xsl:value-of select="normalize-space(.)"/>
    </url>
  </xsl:template>


   <xsl:template match="title">
      <!-- throwing away rendering information -->
      <title>
         <xsl:apply-templates/>
      </title>
   </xsl:template>
   
  <xsl:template match="pubPlace">
    <place>
      <xsl:apply-templates/>
    </place>
  </xsl:template>
  
   <xsl:template match="publisher">
      <publisher>
         <xsl:apply-templates/>
      </publisher>
   </xsl:template>
   
   
  
   <xsl:variable name="dateRegEx" as="xs:string">[12][0-9]{3}</xsl:variable>
   
   <!--<xsl:template match="text()[matches(.,$dateRegEx)]">
      <date>
         <xsl:value-of select="."/>
      </date>
   </xsl:template>-->
  
   <!--<xsl:template match="listBibl/*/text()">
    <xsl:if test="not(matches(.,'^[\s\p{P}]+$'))">
        <xsl:variable name="ws-collapsed" select="replace(.,'\s+',' ')"/>
        <xsl:analyze-string select="$ws-collapsed" regex="{$dateRegEx}">
          <xsl:matching-substring>
            <date>
              <xsl:value-of select="replace(.,'\s+',' ')"/>
            </date>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:if>
  </xsl:template>-->
  
  <!-- Anything not mapped is copied in the Biblio namespace. -->
  <xsl:template match="*">
    <xsl:element name="{local-name()}" namespace="http://digitalhumanities.org/dhq/ns/biblio">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template mode="cast-ns" match="*">
     <xsl:element name="{local-name()}" namespace="http://digitalhumanities.org/dhq/ns/biblio">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
     </xsl:element>
  </xsl:template>
 
  <xsl:template match="comment() | processing-instruction()" mode="cast-ns">
     <xsl:copy-of select="."/>
  </xsl:template>
     
</xsl:stylesheet>