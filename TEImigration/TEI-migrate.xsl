<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:d="http://www.digitalhumanities.org/ns/util"
  exclude-result-prefixes="xs d"
  xpath-default-namespace="http://digitalhumanities.org/DHQ/namespace">

  <xsl:output indent="yes"/>

  <xsl:param name="silent" select="false()"/>
  
  <xsl:strip-space elements="DHQarticle DHQheader publicationStmt
    availability cc:License langUsage language keywords history
    revisionDesc abstract text div listBibl address bio epigraph 
    example figure sp xtext list ptr graphic table row cit lg"/>

  <xsl:template match="/">
    <xsl:call-template name="header-pis"/>
    <xsl:apply-templates/>
  </xsl:template>

  <!--<xsl:template name="header-pis"/>-->

  <xsl:template name="header-pis">
    <xsl:processing-instruction name="oxygen">
      <xsl:text>RNGSchema="../common/schema/DHQauthor-TEI.rng" type="xml"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
    <xsl:processing-instruction name="oxygen">
      <xsl:text>SCHSchema="../common/schema/dhqTEI-ready.sch"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="cc:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
        
  <xsl:template match="@*">
    <xsl:if test="normalize-space(.)">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@lang">
    <xsl:attribute name="xml:lang" select="."/>
  </xsl:template>

  <xsl:template match="@id">
    <xsl:if test="exists(parent::note |
      parent::bibl | parent::div | parent::table |
      parent::figure | parent::example)">
      <xsl:attribute name="xml:id" select="lower-case(.)"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="language/@id">
    <xsl:attribute name="ident" select="."/>
  </xsl:template>
  
  <xsl:template match="language/@role"/>
  
  <xsl:template match="graphic/@type"/>
  
  <xsl:template match="div/@type"/>
  
  <xsl:template match="@when">
    <xsl:if test="normalize-space(.)">
      <xsl:attribute name="when">
        <xsl:choose>
          <xsl:when
            test=". castable as xs:date">
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:when test="matches(.,'^(\d{4})[/-](\d\d?)[/-](\d\d?)$')">
            <xsl:analyze-string select="."
              regex="^(\d{{4}})[/-](\d\d?)[/-](\d\d?)$">
              <xsl:matching-substring>
                <xsl:variable name="yyyy" select="regex-group(1)"/>
                <xsl:variable name="mm"
                  select="format-number(number(regex-group(2)),'00')"/>
                <xsl:variable name="dd"
                  select="format-number(number(regex-group(3)),'00')"/>
                <xsl:value-of select="string-join(($yyyy,$mm,$dd),'-')"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="r"
              >^(\d\d?)[-/](\d\d?)[-/](\d{2}|\d{4})$</xsl:variable>
            <xsl:analyze-string select="." regex="{$r}">
              <xsl:matching-substring>
                <xsl:variable name="mm"
                  select="format-number(number(regex-group(1)),'00')"/>
                <xsl:variable name="dd"
                  select="format-number(number(regex-group(2)),'00')"/>
                <xsl:variable name="yyyy"
                  select="if (string-length(regex-group(3)) = 4)
                then regex-group(3) else concat('20',regex-group(3))"/>
                <xsl:value-of select="string-join(($yyyy,$mm,$dd),'-')"/>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:value-of select="."/>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@target">
    <xsl:attribute name="target">
      <xsl:value-of select="lower-case(.)"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="DHQarticle">
    <TEI>
      <xsl:apply-templates select="DHQheader"/>
      <text>
        <front>
          <xsl:apply-templates select="DHQheader/(abstract|teaser)"/>
        </front>
        <xsl:apply-templates select="* except DHQheader"/>
      </text>
    </TEI>
  </xsl:template>

  <xsl:template match="DHQheader">
    <teiHeader>
      <fileDesc>
        <titleStmt>
          <xsl:apply-templates select="/*/DHQheader/title"/>
          <xsl:apply-templates select="/*/DHQheader/author"/>
          <xsl:apply-templates mode="titleStmt"
            select="/*/DHQheader/(issueTitle | specialTitle)"/>
        </titleStmt>
        <xsl:apply-templates select="/*/DHQheader/publicationStmt"/>
        <sourceDesc><p>Authored for DHQ; migrated from original DHQauthor format</p></sourceDesc>
      </fileDesc>
      <encodingDesc>
        <classDecl>
          <taxonomy xml:id="dhq_keywords">
            <bibl><xsl:text>DHQ classification scheme; full list available in the </xsl:text>
              <ref target="http://www.digitalhumanities.org/dhq/taxonomy.xml">DHQ keyword taxonomy</ref></bibl>
          </taxonomy>
          <taxonomy xml:id="authorial_keywords">
            <bibl>Keywords supplied by author; no controlled vocabulary</bibl>
          </taxonomy>
        </classDecl>
      </encodingDesc>
      <profileDesc>
      <xsl:apply-templates select="/*/DHQheader/langUsage"/>
      <xsl:apply-templates select="/*/DHQheader/keywords"/>
      </profileDesc>
      <xsl:apply-templates select="/*/DHQheader/history"/>
      
    </teiHeader>
  </xsl:template>
  
  <xsl:template match="DHQheader/author">
    <author>
      <xsl:value-of select="normalize-space(name)"/>
    </author>
    <dhq:authorInfo>
      <xsl:apply-templates/>
    </dhq:authorInfo>
  </xsl:template>
  
  <xsl:template match="specialTitle | issueTitle" mode="titleStmt">
    <xsl:comment>
      <xsl:text> </xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates/>
    </xsl:comment>
  </xsl:template>
  
  <xsl:template match="DHQheader/author/name">
    <dhq:author_name>
      <xsl:apply-templates/>
    </dhq:author_name>
  </xsl:template>
  
  <xsl:template match="family">
    <dhq:family>
      <xsl:apply-templates/>
    </dhq:family>
  </xsl:template>
  
  <xsl:template match="affiliation">
    <dhq:affiliation>
      <xsl:apply-templates/>
    </dhq:affiliation>
  </xsl:template>
  
  <xsl:template match="address"/>
  
  <xsl:template match="bio">
    <dhq:bio>
      <xsl:apply-templates/>
    </dhq:bio>
  </xsl:template>

  <xsl:template match="articleType">
    <dhq:articleType>
      <xsl:apply-templates/>
    </dhq:articleType>
  </xsl:template>
  
  <xsl:template match="specialTitle | issueTitle"/>
  
  <xsl:template match="history">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="language">
    <language ident="en">
      <xsl:apply-templates select="@*"/>
    </language>
  </xsl:template>
  
  <xsl:template match="keywords">
    <!--<xsl:comment>
      <xsl:text> Keywords in original: </xsl:text>
      <xsl:value-of select="term" separator="; "/>
      <xsl:apply-templates select="@*"/>
    </xsl:comment>-->
    <textClass>
      <keywords scheme="#authorial_keywords">
        <list>
          <xsl:apply-templates/>
        </list>
      </keywords>
    </textClass>
    
  </xsl:template>
  
  <xsl:template match="keywords/term">
    <item>
      <xsl:apply-templates/>
    </item>
  </xsl:template>
  
  <xsl:template match="abstract">
    <dhq:abstract>
      <xsl:apply-templates/>
    </dhq:abstract>
  </xsl:template>
  
  <xsl:template match="teaser">
    <dhq:teaser>
      <p>
        <xsl:apply-templates/>
      </p>
    </dhq:teaser>
  </xsl:template>
  

  <xsl:template match="text">
    <body>
        <xsl:apply-templates/>
    </body>
  </xsl:template>
  
 <!-- <xsl:template match="ref">
    <ref>
      <xsl:copy-of select="@target"/>
      <xsl:apply-templates/>
    </ref>
  </xsl:template>
    
  <xsl:template match="foreign">
    <foreign>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </foreign>
    </xsl:template>-->
    
  
  <xsl:template match="called">
    <q>
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  
  <xsl:template match="listBibl">
    <back>
      <listBibl>
        <xsl:apply-templates/>
      </listBibl>
    </back>
  </xsl:template>
  
  <xsl:template match="listBibl/bibl">
    <bibl>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="label"/>
      <xsl:apply-templates select="node() except label"/>
    </bibl>
  </xsl:template>
  
  <xsl:template match="bibl/label">
    <xsl:attribute name="label" select="."/>
  </xsl:template>
  
  <xsl:template match="figure/label | example/label | table/label">
    <head>
      <xsl:apply-templates/>
    </head>
  </xsl:template>
  
  <xsl:template match="example">
    <dhq:example>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </dhq:example>
  </xsl:template>
  
  <xsl:template match="caption">
    <dhq:caption>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </dhq:caption>    
  </xsl:template>
  
  <xsl:template match="epigraph">
    <epigraph>
      <xsl:apply-templates select="@*"/>
      <cit>
        <xsl:apply-templates/>
      </cit>
    </epigraph>
  </xsl:template>
  
  <xsl:template match="extent">
    <biblScope type="pages">      
      <xsl:apply-templates/>
    </biblScope>
  </xsl:template>
  
  <xsl:template match="vol">
    <biblScope type="vol">
      <xsl:apply-templates/>
    </biblScope>
  </xsl:template>
  
  <xsl:template match="xtext">
    <floatingText>
      <body>
        <xsl:apply-templates/>
      </body>
    </floatingText>
  </xsl:template>
  
  <xsl:template match="ptr[not(ancestor::bibl)][not(starts-with(@target,'#'))]">
    <ref>
      <xsl:apply-templates select="@target"/>
      <xsl:value-of select="@target"/>
    </ref>
  </xsl:template>

  <xsl:template match="ptr[exists(d:target(@target)[not(self::bibl)])]" priority="2">
    <ref type="auto">
      <xsl:apply-templates select="@target"/>
      <xsl:apply-templates select="d:target(@target)" mode="label"/>
    </ref>
  </xsl:template>
    
  <xsl:template match="*" mode="label">
    <xsl:value-of select="upper-case(substring(local-name(),1,1))"/>
    <xsl:value-of select="substring(local-name(),2)"/>
    <xsl:text> </xsl:text>
    <xsl:number level="any"/>
  </xsl:template>
  
  <xsl:key name="xref-target" match="*[exists(@id)]" use="@id"/>
  
  <xsl:function name="d:target" as="element()?">
    <xsl:param name="target" as="attribute(target)?"/>
    <xsl:if test="starts-with($target,'#')">
      <xsl:sequence select="key('xref-target',substring-after($target,'#'),root($target))"/>
    </xsl:if>
  </xsl:function>
  
      
</xsl:stylesheet>
