<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Whether to put the Zotero JSON bibliography entries in the article's <xenoData>. -->
    <xsl:param name="show-zotero-json" select="false()" as="xs:boolean"/>
    
    <!-- Before doing anything else, check for Zotero inline citations (processing instructions which contain 
      JSON). The bibliographic data is compiled here so that it can be used elsewhere in the document.s -->
    <xsl:template match="/">
      <xsl:variable name="zoteroCitationPIs" as="item()*">
        <!-- Try to generate maps from the JSON contents of Zotero "CSL citation" processing instructions. -->
        <xsl:for-each select="//processing-instruction('biblio')[contains(., 'ZOTERO_ITEM CSL_CITATION')]">
          <xsl:sequence select="parse-json(substring-after(., 'CSL_CITATION'))"/>
        </xsl:for-each>
      </xsl:variable>
      <!-- Generate a series of map entries corresponding to each unique Zotero item (bibliography entry)s. -->
      <xsl:variable name="zoteroCitationItems" as="item()*">
        <!-- Each map corresponds to an inline citation (marking a reference in the article proper). The map does, 
          however, fully replicate each referenced Zotero item. In order to process each unique item only once, we 
          group the Zotero items by their ID. -->
        <xsl:for-each-group select="$zoteroCitationPIs?citationItems?*" group-by="?id">
          <xsl:map-entry key="current-grouping-key()">
            <xsl:call-template name="parse-bibliographic-json">
              <!-- Process only the first Zotero item matching this ID. -->
              <xsl:with-param name="citation-map" select="head(current-group())"/>
            </xsl:call-template>
          </xsl:map-entry>
        </xsl:for-each-group>
      </xsl:variable>
      <!-- Proceed to transform the DHQ article as expected, but tunnel the compiled Zotero data to the templates 
        that need them. -->
      <xsl:apply-templates>
        <xsl:with-param name="compiled-bibliography" select="map:merge($zoteroCitationItems)" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:template>
    
    <!-- DHQ Template Setup -->
    <xsl:template match="TEI">
        <xsl:processing-instruction name="oxygen">
            <xsl:text>RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"</xsl:text>
        </xsl:processing-instruction>
        <xsl:processing-instruction name="oxygen">
            <xsl:text>SCHSchema="../../common/schema/dhqTEI-ready.sch"</xsl:text>
        </xsl:processing-instruction>
        <TEI xmlns="http://www.tei-c.org/ns/1.0"
            xmlns:cc="http://web.resource.org/cc/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:dhq="http://www.digitalhumanities.org/ns/dhq">
            
            <xsl:apply-templates/>
            
        </TEI>
    </xsl:template>
    
    <xsl:template match="teiHeader">
        <xsl:param name="compiled-bibliography" as="map(*)?" tunnel="yes"/>
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <xsl:comment>Author should supply the title and personal information</xsl:comment>
                    <title type="article" xml:lang="en"><xsl:comment>article title in English</xsl:comment></title>
                    <xsl:comment>Add a &lt;title&gt; with appropriate @xml:lang for articles in languages other than English</xsl:comment>
                    <dhq:authorInfo>
                        <xsl:comment>Include a separate &lt;dhq:authorInfo&gt; element for each author</xsl:comment>
                        <dhq:author_name>first name(s) <dhq:family>family name</dhq:family></dhq:author_name>
                    <idno type="ORCID"><xsl:comment>if the author has an ORCID ID, include the full URI, e.g. https://orcid.org/0000-0000-0000-0000</xsl:comment></idno>
                        <dhq:affiliation></dhq:affiliation>
                        <email></email>
                        <dhq:bio><p></p></dhq:bio>
                    </dhq:authorInfo>
                </titleStmt>
                <publicationStmt>
                    <publisher>Alliance of Digital Humanities Organizations</publisher>
                    <publisher>Association for Computers and the Humanities</publisher>
                    <xsl:comment>This information will be completed at publication</xsl:comment>
                    <idno type="DHQarticle-id"><xsl:comment>including leading zeroes: e.g. 000110</xsl:comment></idno>
                    <idno type="volume"><xsl:comment>volume number, with leading zeroes as needed to make 3 digits: e.g. 006</xsl:comment></idno>
                    <idno type="issue"><xsl:comment>issue number, without leading zeroes: e.g. 2</xsl:comment></idno>
                    <date></date>
                    <dhq:articleType>article</dhq:articleType>
                    <availability status="CC-BY-ND">
                    <xsl:comment>If using a different license from the default, choose one of the following:
                  CC-BY-ND (DHQ default): <cc:License rdf:about="http://creativecommons.org/licenses/by-nd/2.5/"/>     
                  CC-BY:  <cc:License rdf:about="https://creativecommons.org/licenses/by/2.5/"/>
                  CC0: <cc:License rdf:about="https://creativecommons.org/publicdomain/zero/1.0/"/>
</xsl:comment>
                        <cc:License rdf:about="http://creativecommons.org/licenses/by-nd/2.5/"/>
                    </availability>
                </publicationStmt>
                
                <sourceDesc>
                    <p>This is the source</p>
                </sourceDesc>
            </fileDesc>
            <encodingDesc>
                <classDecl>
                    <taxonomy xml:id="dhq_keywords">
                        <bibl>DHQ classification scheme; full list available at <ref target="http://www.digitalhumanities.org/dhq/taxonomy.xml">http://www.digitalhumanities.org/dhq/taxonomy.xml</ref></bibl>
                    </taxonomy>
                    <taxonomy xml:id="authorial_keywords">
                        <bibl>Keywords supplied by author; no controlled vocabulary</bibl>
                    </taxonomy>
            		<taxonomy xml:id="project_keywords">
            			<bibl>DHQ project registry; full list available at <ref target="http://www.digitalhumanities.org/dhq/projects.xml">http://www.digitalhumanities.org/dhq/projects.xml</ref></bibl>
            		</taxonomy>
                </classDecl>
            </encodingDesc>
            <profileDesc>
                <langUsage>
                    <language ident="en" extent="original"/>
                    <xsl:comment>add &lt;language&gt; with appropriate @ident for any additional languages</xsl:comment>
                </langUsage>
                <textClass>
                    <keywords scheme="#dhq_keywords">
                        <xsl:comment>Authors may suggest one or more keywords from the DHQ keyword list, visible at http://www.digitalhumanities.org/dhq/taxonomy.xml; these may be supplemented or modified by DHQ editors</xsl:comment>
                        <list type="simple">
                            <item></item>
                        </list>
                    </keywords>
                    <keywords scheme="#authorial_keywords">
                        <xsl:comment>Authors may include one or more keywords of their choice</xsl:comment>
                        <list type="simple">
                            <item></item>
                        </list>
                    </keywords>
            		<keywords scheme="#project_keywords">
            			<list type="simple">
            				<item></item>
            			</list>
            		</keywords>
                </textClass>
            </profileDesc>
           <!-- Create a copy of the Zotero bibliographic data in <xenoData>. (Useful for debugging.) -->
           <xsl:if test="$show-zotero-json and exists($compiled-bibliography)">
              <xenoData>
                <xsl:text>[ </xsl:text>
                <xsl:sequence select="string-join($compiled-bibliography?*?jsonStr, ',  
')"/>
                <xsl:text> ]</xsl:text>
              </xenoData>
           </xsl:if>
           <revisionDesc>
             <xsl:comment> Replace "NNNNNN" in the @target of ref below with the appropriate DHQarticle-id value. </xsl:comment>
        	   <change>The version history for this file can be found on <ref target=
        		"https://github.com/Digital-Humanities-Quarterly/dhq-journal/commits/main/articles/NNNNNN/NNNNNN.xml">GitHub
        	   </ref></change>
   	       </revisionDesc>
        </teiHeader>
    </xsl:template>
    
    <xsl:template match="text">
        <xsl:copy>
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:attribute name="type">original</xsl:attribute>
            <front>
                <dhq:abstract>
                    <xsl:comment>Include a brief abstract of the article</xsl:comment>
                    <p></p>
                </dhq:abstract>
                <dhq:teaser>
                    <xsl:comment>Include a brief teaser, no more than a phrase or a single sentence</xsl:comment>
                    <p></p>
                </dhq:teaser>
            </front>
            <xsl:apply-templates/>
            <back>
                <listBibl>
                    <bibl></bibl>
                </listBibl>
            </back>
        </xsl:copy>
    </xsl:template>
    
    
     
    <!-- Transformations To Contents of <text> -->
    <xsl:template match="p/@* | note/@* | table/@*"/>
    <xsl:template match="anchor | graphic"/>
    
    <!-- Try to align Zotero's inserted bibliography with any JSON from the inline citations. -->
    <xsl:template match="p[@rend eq 'Bibliography']"/>
    <xsl:template match="p[@rend eq 'Bibliography'][1]" priority="2">
      <listBibl>
        <xsl:apply-templates select=". | following-sibling::p[@rend eq 'Bibliography']" mode="biblio"/>
      </listBibl>
    </xsl:template>
    
    <!-- Any <hi> is likely to be a title of some kind when it appears inside one of Zotero's generated 
      "Bibliography" paragraphs. -->
    <xsl:template match="p[@rend eq 'Bibliography']//hi[@rend eq 'italic']" priority="5">
      <title rend="italic">
        <xsl:apply-templates/>
      </title>
    </xsl:template>
    
    <!-- In "biblio" mode, "Bibliography" paragraphs are either:
        * replaced with <biblStruct>s (if an italicized string matches a title field in the Zotero maps), or
        * turned into <bibl>s.
      -->
    <xsl:template match="p[@rend eq 'Bibliography']" mode="biblio">
      <xsl:param name="compiled-bibliography" as="map(*)?" tunnel="yes"/>
      <xsl:variable name="italicizedField" select="descendant::hi[normalize-space(.) ne ''][1]"/>
      <xsl:variable name="biblMatches" as="map(*)*">
        <xsl:variable name="biblMatchTitle"
          select="$compiled-bibliography?*[?jsonMap?title eq $italicizedField]"/>
        <xsl:variable name="biblMatchContainerTitle"
          select="$compiled-bibliography?*[?jsonMap?container-title eq $italicizedField]"/>
        <xsl:choose>
          <xsl:when test="exists($biblMatchTitle)">
            <xsl:sequence select="$biblMatchTitle"/>
          </xsl:when>
          <xsl:when test="count($biblMatchContainerTitle) eq 1">
            <xsl:sequence select="$biblMatchContainerTitle"/>
          </xsl:when>
          <xsl:when test="count($biblMatchContainerTitle) gt 1">
            <xsl:variable name="firstToken" 
              select="(tokenize(normalize-space(.), ' ')[1]) => replace('\W', '')"/>
            <xsl:if test="exists($firstToken) and $firstToken ne ''">
              <xsl:sequence select="$biblMatchContainerTitle[exists(?jsonMap?author?*[?family eq $firstToken])]"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="count($biblMatches) eq 1">
          <xsl:sequence select="$biblMatches?teiBibEntry"/>
        </xsl:when>
        <xsl:when test="count($biblMatches) gt 1">
          <xsl:comment> More than one match!!! </xsl:comment>
          <xsl:sequence select="$biblMatches?teiBibEntry"/>
          <xsl:comment> End matches!!! </xsl:comment>
        </xsl:when>
        <xsl:otherwise>
          <bibl>
            <xsl:apply-templates mode="#default"/>
          </bibl>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="note/p">
            <xsl:apply-templates select="child::node()"/>
    </xsl:template>
    
    <!-- may need to uncomment following template for files initially converted from .rtf -->
    <!-- <xsl:template match="ref">
            <xsl:apply-templates select="child::node()"/>
    </xsl:template> -->
    
    <xsl:template match="ptr">
        <xsl:element name="ref">
            <xsl:apply-templates select="attribute::target | child::node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- add transformation for first row to have role="label" -->
    <xsl:template match="row">
        <xsl:element name="row">
            <xsl:attribute name="role">data</xsl:attribute>
            <xsl:apply-templates select="child::node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="cell">
        <xsl:element name="cell">
            <xsl:apply-templates select="child::node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="seg[@rend eq 'italic']">
        <xsl:element name="hi">
            <xsl:apply-templates select="attribute::rend | child::node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="seg[@rend eq 'bold']">
        <xsl:element name="hi">
            <xsl:apply-templates select="attribute::rend | child::node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="seg">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="hi[@rend eq 'italic']">
        <xsl:copy>
            <xsl:apply-templates select="attribute::rend | child::node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- Created below code for keeping bolded text, but removed for now because all headings are been sent out of OxGarage as <hi rend="bold"> -->
    <!--<xsl:template match="hi[@rend eq 'bold']">
        <xsl:copy>
            <xsl:apply-templates select="attribute::rend | child::node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="hi">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template name="replace" match="text()">
        <xsl:variable name="double_hyphen" select="replace( ., '--', '—')"/>
        <xsl:variable name="space_around" select="replace( $double_hyphen, '(\S)—(\S)', '$1 — $2')"/>
        <xsl:variable name="end_dash" select="replace($space_around, '(\S)—(\s)', '$1 —$2')"/>
        <xsl:variable name="begin_dash" select="replace($end_dash, '(\s)—(\S)', '$1— $2')"/>
        <xsl:value-of select="$begin_dash"/>
    </xsl:template>
    
    <!-- add quotation mark transformation? -->
    
    <!-- Transformations Re MathML -->
    <xsl:template match="mml:mi/@xml:space"/>
    <!-- fix mathml display issue? -->
    
    
  <!-- Compile Zotero's bibliographic data. -->
  <xsl:template name="parse-bibliographic-json" as="map(*)">
    <xsl:param name="citation-map" as="map(*)"/>
    <xsl:variable name="citeKey" select="$citation-map?itemData?citation-key"/>
    <xsl:variable name="bibData" select="$citation-map?itemData"/>
    <xsl:map>
      <xsl:map-entry key="'itemId'" select="$citation-map?id"/>
      <xsl:map-entry key="'citationKey'" select="$citeKey"/>
      <xsl:map-entry key="'textCitation'" select="$citation-map?properties?plainCitation"/>
      <xsl:map-entry key="'jsonMap'" select="$bibData"/>
      <xsl:map-entry key="'jsonStr'" select="serialize($citation-map, map { 'method': 'json', 'indent': true() })"/>
      <!-- Generate a <biblStruct> that can be used in the bibliography instead of a <p> or plain <bibl>. -->
      <xsl:map-entry key="'teiBibEntry'">
        <xsl:variable name="hasContainer" select="map:contains($bibData, 'container-title')"/>
        <xsl:variable name="basicInfo">
          <xsl:for-each select="$bibData?author?*">
            <author>
              <persName>
                <forename>
                  <xsl:value-of select=".?given"/>
                </forename>
                <surname>
                  <xsl:value-of select=".?family"/>
                </surname>
              </persName>
            </author>
          </xsl:for-each>
          <title>
            <xsl:attribute name="level" select="if ( $hasContainer ) then 'a' else 'm'"/>
            <xsl:value-of select="$bibData?title"/>
          </title>
        </xsl:variable>
        <biblStruct xml:id="{$citeKey}" type="{$bibData?type}">
          <xsl:if test="$hasContainer">
            <analytic>
              <xsl:sequence select="$basicInfo"/>
            </analytic>
          </xsl:if>
          <monogr>
            <xsl:choose>
              <xsl:when test="$hasContainer">
                <title level="m">
                  <xsl:value-of select="$bibData?container-title"/>
                </title>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$basicInfo"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="map:contains($bibData, 'ISBN')">
              <idno type="ISBN">
                <xsl:value-of select="$bibData?ISBN"/>
              </idno>
            </xsl:if>
            <imprint>
              <publisher>
                <xsl:value-of select="$bibData?publisher"/>
              </publisher>
              <xsl:if test="map:contains($bibData,'publisher-place')">
                <pubPlace>
                  <xsl:value-of select="$bibData?publisher-place"/>
                </pubPlace>
              </xsl:if>
              <date>
                <xsl:value-of select="$bibData?issued?date-parts?*?*"/>
              </date>
            </imprint>
          </monogr>
        </biblStruct>
      </xsl:map-entry>
    </xsl:map>
  </xsl:template>

    
</xsl:stylesheet>