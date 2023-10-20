<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
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
      JSON). The bibliographic data is compiled here so that it can be used elsewhere in the document. -->
    <xsl:template match="/">
      <xsl:variable name="zoteroCitationPIs" as="item()*">
        <!-- Try to generate maps from the JSON contents of Zotero "CSL citation" processing instructions. -->
        <xsl:for-each select="//processing-instruction('biblio')[contains(., 'ZOTERO_ITEM CSL_CITATION')]">
          <xsl:sequence select="parse-json(substring-after(., 'CSL_CITATION'))"/>
        </xsl:for-each>
      </xsl:variable>
      <!-- Prepare DHQ-style citations. -->
      <xsl:variable name="zoteroCitationPtrs" as="map(*)?">
        <xsl:if test="exists($zoteroCitationPIs)">
          <xsl:map>
            <xsl:for-each select="$zoteroCitationPIs">
              <xsl:map-entry key="?citationID">
                <xsl:for-each select="?citationItems?*">
                  <xsl:variable name="idref" select="dhq:set-bibliography-entry-id(?itemData)"/>
                  <ptr target="#{$idref}">
                    <xsl:if test="map:contains(., 'locator')">
                      <xsl:attribute name="loc" select="?locator"/>
                    </xsl:if>
                  </ptr>
                </xsl:for-each>
              </xsl:map-entry>
            </xsl:for-each>
          </xsl:map>
        </xsl:if>
      </xsl:variable>
      <!-- Generate a series of map entries corresponding to each unique Zotero item (bibliography entry). -->
      <xsl:variable name="zoteroBibEntries" as="map(*)?">
        <xsl:if test="exists($zoteroCitationPIs)">
          <xsl:map>
            <!-- Each map corresponds to an inline citation (marking a reference in the article proper). The map does, 
              however, fully replicate each referenced Zotero item. In order to process each unique item only once, we 
              group the Zotero items by their ID. -->
            <xsl:for-each-group select="$zoteroCitationPIs?citationItems?*" group-by="?id">
              <xsl:variable name="entryId" select="dhq:set-bibliography-entry-id(?itemData)"/>
              <xsl:map-entry key="$entryId">
                <!-- Compile data for the bibliography entry. -->
                <xsl:call-template name="parse-bibliographic-json">
                  <!-- Process only the first Zotero item matching this ID. -->
                  <xsl:with-param name="citation-map" select="head(current-group())"/>
                </xsl:call-template>
              </xsl:map-entry>
            </xsl:for-each-group>
          </xsl:map>
        </xsl:if>
      </xsl:variable>
      <!-- Proceed to transform the DHQ article as expected, but tunnel the compiled Zotero data to the templates 
        that need them. -->
      <xsl:apply-templates>
        <xsl:with-param name="inline-citations" select="$zoteroCitationPtrs" tunnel="yes"/>
        <xsl:with-param name="compiled-bibliography" select="$zoteroBibEntries" tunnel="yes"/>
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
                    	
                    	<xsl:comment>Enter keywords below preceeded by a "#". Create a new term element for each</xsl:comment>
                        <term corresp=""/>
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
        <xsl:param name="compiled-bibliography" as="map(*)?" tunnel="yes"/>
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
                    <!-- If the document contains Zotero citations, populate the DHQ bibliography with those entries. -->
                    <xsl:choose>
                      <xsl:when test="exists($compiled-bibliography)">
                        <xsl:variable name="biblStructSeq" as="node()*">
                          <xsl:apply-templates select="descendant::p[dhq:has-zotero-bibliography-pi(.)]" mode="biblio"/>
                        </xsl:variable>
                        <xsl:variable name="unmatchedEntries" as="node()*" 
                          select="$compiled-bibliography?*[not(?citationKey = $biblStructSeq/@xml:id/data(.))]
                                                          ?teiBibEntry"/>
                        <xsl:sequence select="$biblStructSeq"/>
                        <xsl:if test="exists($unmatchedEntries)">
                          <xsl:message>Unmatched bibliography entries</xsl:message>
                          <xsl:comment> Entries below were cited but could not be matched to Zotero's bibliography </xsl:comment>
                          <xsl:sequence select="$unmatchedEntries"/>
                        </xsl:if>
                      </xsl:when>
                      <!-- If no Zotero metadata could be found, output a <bibl> placeholder. -->
                      <xsl:otherwise>
                          <bibl></bibl>
                      </xsl:otherwise>
                    </xsl:choose>
                </listBibl>
            </back>
        </xsl:copy>
    </xsl:template>
    
    
     
    <!-- Suppress unwanted attributes and elements -->
    <xsl:template match="p/@* | note/@* | table/@*"/>
    <xsl:template match="anchor"/>
    <xsl:template match="pb"/>
    <xsl:template match="lb"/>
    
    
   <!-- handling of figures and tables-->
	
    <xsl:template match="graphic[not(parent::figure)]">
    	<figure>
    		<head></head>
    		<graphic><xsl:apply-templates select="attribute::url"></xsl:apply-templates></graphic>
    	</figure>
    </xsl:template>
	
    <xsl:template match="figure">
    	<figure>
    		<head><xsl:value-of select="./head"/></head>
    		<graphic>
        		<xsl:attribute name="url">
        			<xsl:value-of select="./graphic/@url"/>
        		</xsl:attribute>
    		</graphic>
    	</figure>
    </xsl:template>

	<xsl:template match="p[@rend eq 'dhq_figdesc']">
		<!-- TTD: it would be ideal if we could move the head to be the first child of <figure> -->
		<figDesc><xsl:comment>If this figDesc is invalid, move it into the nearest figure element</xsl:comment><xsl:apply-templates/><xsl:apply-templates/></figDesc>
	</xsl:template>

	<xsl:template match="p[@rend eq 'dhq_caption']">
		<!-- TTD: it would be ideal if we could move the head to be the first child of <figure> -->
		<head><xsl:comment>If this head is invalid, move it into the nearest figure element</xsl:comment><xsl:apply-templates/></head>	
	</xsl:template>


	<xsl:template match="p[@rend eq 'dhq_table_label']">
    	<!-- TTD: it would be ideal if we could move the head to be the first child of <table> -->
		<head><xsl:comment>If this head is invalid, move it into the nearest table element</xsl:comment><xsl:apply-templates/></head>	
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

    <!-- handling of phrase-level elements that are marked with DHQ Word styles -->
    <xsl:template match="hi[@rend eq 'dhq_term']">
    	<term>
    		<xsl:apply-templates/>
    	</term>
    </xsl:template>
	
    <xsl:template match="hi[@rend eq 'dhq_emphasis']">
    	<emph>
    		<xsl:apply-templates/>
    	</emph>
    </xsl:template>
	
    <xsl:template match="hi[@rend eq 'dhq_italic_title']">
    	<title rend="italic">
    		<xsl:apply-templates/>
    	</title>
    </xsl:template>

    <xsl:template match="hi[@rend eq 'dhq_quote']">
    	<quote rend="inline">
    		<xsl:apply-templates/>
    	</quote>
    </xsl:template>

   <!-- <xsl:template match="hi[@rend eq 'dhq_citation']">
    	<ptr>
    		<xsl:attribute name="target">
    			<xsl:value-of select="."></xsl:value-of>
    		</xsl:attribute>
    	</ptr>
    </xsl:template>-->




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
    <xsl:template match="mml:*">
      <!-- Make sure MathML element names have the "mml" prefix. -->
      <xsl:element name="mml:{local-name()}">
        <xsl:apply-templates select="@* | node()"/>
      </xsl:element>
    </xsl:template>
    
    <xsl:template match="mml:mi/@xml:space"/>
    <!-- fix mathml display issue? -->
    
    
  <!--  ZOTERO PROCESSING  -->
    
    <!-- Replace Zotero's inline citation PIs with DHQ-style <ptr>s. -->
    <xsl:template match="processing-instruction('biblio')[contains(., 'ZOTERO_ITEM CSL_CITATION')]">
      <xsl:param name="inline-citations" as="map(*)?" tunnel="yes"/>
      <xsl:variable name="citationID" 
        select="substring-after(., 'CSL_CITATION') 
                => parse-json()
                => map:get('citationID')"/>
      <xsl:if test="$show-zotero-json">
        <xsl:copy/>
      </xsl:if>
      <xsl:sequence select="$inline-citations?($citationID)"/>
    </xsl:template>
    
    
  <!--  BIBLIO MODE  -->
    
    <xsl:template match="div[not(descendant::div)][descendant-or-self::*[dhq:has-zotero-bibliography-pi(.)]]"
       mode="biblio">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p" mode="biblio"/>
    
    <!-- Any <hi> is likely to be a title of some kind when it appears inside one of Zotero's generated 
      "Bibliography" paragraphs. -->
    <xsl:template match="p//hi[@rend eq 'italic']" priority="5" mode="biblio">
      <title>
        <xsl:apply-templates select="@* | node()"/>
      </title>
    </xsl:template>
    
    <xsl:template match="p[dhq:has-zotero-bibliography-pi(.)]" mode="biblio" priority="2">
      <xsl:param name="compiled-bibliography" as="map(*)?" tunnel="yes"/>
      <xsl:iterate select="(., following-sibling::p)">
        <xsl:param name="try-entries" select="$compiled-bibliography" as="map(*)?"/>
        <xsl:variable name="italicizedField" 
          select="descendant::hi[normalize-space(.) ne ''][1]/replace(., '\W', '')"/>
        <xsl:variable name="biblMatches" as="map(*)*">
          <xsl:variable name="biblMatchTitle"
            select="$try-entries?*[?jsonMap?title[replace(., '\W', '') eq $italicizedField]]"/>
          <xsl:variable name="biblMatchContainerTitle"
            select="$try-entries?*[?jsonMap?container-title[replace(., '\W', '') eq $italicizedField]]"/>
          <xsl:choose>
            <!-- If there wasn't an italicized field to use as testing, look for titles which appear in this string. -->
            <xsl:when test="not(exists($italicizedField))">
              <xsl:variable name="me" select="."/>
              <xsl:sequence select="$try-entries?*[?jsonMap?title[contains($me, .)]]"/>
            </xsl:when>
            <!-- If there's an exact match on the main title, use that entry. -->
            <xsl:when test="exists($biblMatchTitle)">
              <xsl:sequence select="$biblMatchTitle"/>
            </xsl:when>
            <xsl:when test="count($biblMatchContainerTitle) eq 1">
              <xsl:sequence select="$biblMatchContainerTitle"/>
            </xsl:when>
            <!-- When there's more than one entry that has a "container" title which matches this entry, do further 
              testing against the first token of this entry.  -->
            <xsl:when test="count($biblMatchContainerTitle) gt 1">
              <xsl:variable name="firstToken" 
                select="(tokenize(normalize-space(.), ' ')[1]) => replace('\W', '')"/>
              <xsl:if test="exists($firstToken) and $firstToken ne ''">
                <xsl:sequence 
                  select="$biblMatchContainerTitle[exists(?jsonMap?author?*[replace(?family, '\W', '') eq $firstToken])]"/>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="count($biblMatches) eq 1">
            <xsl:sequence select="$biblMatches?teiBibEntry"/>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" select="map:remove($try-entries, $biblMatches?itemId)"/>
            </xsl:next-iteration>
          </xsl:when>
          <xsl:when test="count($biblMatches) gt 1">
            <xsl:comment> More than one match!!! </xsl:comment>
            <xsl:sequence select="$biblMatches?teiBibEntry"/>
            <xsl:comment> End matches!!! </xsl:comment>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" select="$try-entries"/>
            </xsl:next-iteration>
          </xsl:when>
          <xsl:otherwise>
            <bibl>
              <xsl:apply-templates mode="biblio"/>
            </bibl>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" select="$try-entries"/>
            </xsl:next-iteration>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:iterate>
    </xsl:template>
    
    
  <!-- Compile Zotero's bibliographic data into a map, e.g. 
      map {
          'itemId': 480,
          'citationKey': "hopperGrammaticalization2003",
          'jsonMap': map { (: Copy of the JSON entry :) },
          'jsonStr': "", (: JSON serialized as an indented string :),
          'teiBibEntry':
            <biblStruct xml:id="hopperGrammaticalization2003"
                        type="book"
                        corresp="http://zotero.org/users/7242265/items/UJUERPA2">
               <monogr>
                  <author>
                     <persName>
                        <forename>Paul</forename>
                        <surname>Hopper</surname>
                     </persName>
                  </author>
                  <author>
                     <persName>
                        <forename>Elizabeth</forename>
                        <surname>Traugott</surname>
                     </persName>
                  </author>
                  <title level="m">Grammaticalization</title>
                  <idno type="ISBN">978-0-521-80421-9</idno>
                  <imprint>
                     <publisher>Cambridge University Press</publisher>
                     <pubPlace>Cambridge</pubPlace>
                     <date>2003</date>
                  </imprint>
               </monogr>
            </biblStruct>
        }
    -->
  <xsl:template name="parse-bibliographic-json" as="map(*)">
    <xsl:param name="citation-map" as="map(*)"/>
    <xsl:variable name="bibData" select="$citation-map?itemData"/>
    <!-- If the Zotero data includes a "citation key", use that as an identifier. Otherwise, fall back 
      on Zotero's ID, which at least will be unique and consistent across appearances. -->
    <xsl:variable name="citeKey" select="dhq:set-bibliography-entry-id($bibData)"/>
    <xsl:map>
      <xsl:map-entry key="'itemId'" select="$bibData?id"/>
      <xsl:map-entry key="'citationKey'" select="$citeKey"/>
      <xsl:map-entry key="'jsonMap'" select="$bibData"/>
      <xsl:map-entry key="'jsonStr'" select="serialize($citation-map, map { 'method': 'json', 'indent': true() })"/>
      <!-- Generate a <biblStruct> that can be used in the bibliography instead of a <p> or plain <bibl>. -->
      <xsl:map-entry key="'teiBibEntry'">
        <xsl:call-template name="make-biblStruct-from-zotero-data">
          <xsl:with-param name="zotero-item-map" select="$bibData"/>
          <xsl:with-param name="zotero-item-uri" select="$citation-map?uris?1"/>
        </xsl:call-template>
      </xsl:map-entry>
    </xsl:map>
  </xsl:template>
  
  <!-- 
    Use Zotero JSON data to generate a <tei:biblStruct>.
    -->
  <xsl:template name="make-biblStruct-from-zotero-data">
    <xsl:param name="zotero-item-map" as="map(*)"/>
    <xsl:param name="zotero-item-uri" as="xs:string"/>
    <!-- If the Zotero data includes a "citation key", use that as an identifier. Otherwise, fall back 
      on Zotero's ID, which at least will be unique and consistent across appearances. -->
    <xsl:variable name="citeKey" select="dhq:set-bibliography-entry-id($zotero-item-map)"/>
    <!-- Get this entry's Zotero item type (Zotero's label for what the work is, e.g. "Conference Paper"
      or "Book"). https://www.zotero.org/support/kb/item_types_and_fields -->
    <xsl:variable name="bibType" as="xs:string?">
      <xsl:variable name="typeStr">
        <xsl:analyze-string select="$zotero-item-map?type" regex="-(\w)">
          <xsl:matching-substring>
            <xsl:value-of select="upper-case(regex-group(1))"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="string-join($typeStr,'')"/>
    </xsl:variable>
    <!-- Determine if this entry is part of a larger work. If so, we'll need to create an <analytic>. -->
    <xsl:variable name="hasContainer" select="map:contains($zotero-item-map, 'container-title')"/>
    <xsl:variable name="langAttr" as="attribute()?">
      <xsl:if test="map:contains($zotero-item-map, 'language') 
                    and not(lower-case($zotero-item-map?language) = ('en', 'eng', 'english', ''))">
        <xsl:attribute name="xml:lang" select="$zotero-item-map?language"/>
      </xsl:if>
    </xsl:variable>
    <!-- Create the base <title> and <author> for this entry. Where it goes in the <biblStruct> depends 
      on the value of $hasContainer . -->
    <xsl:variable name="basicInfo">
      <title>
        <xsl:attribute name="level" select="if ( $hasContainer ) then 'a' else 'm'"/>
        <xsl:copy-of select="$langAttr"/>
        <xsl:value-of select="$zotero-item-map?title"/>
      </title>
      <xsl:for-each select="$zotero-item-map?author?*">
        <author>
          <xsl:call-template name="name-bibliography-contributor">
            <xsl:with-param name="person-map" select="."/>
          </xsl:call-template>
        </author>
      </xsl:for-each>
    </xsl:variable>
    <!-- Set up the <biblStruct>. -->
    <biblStruct xml:id="{$citeKey}" type="{$bibType}" corresp="{$zotero-item-uri}">
      <!-- If this entry is part of a larger work, it is represented as an <analytic>. -->
      <xsl:if test="$hasContainer">
        <analytic>
          <xsl:sequence select="$basicInfo"/>
        </analytic>
      </xsl:if>
      <monogr>
        <xsl:choose>
          <!-- If this entry is part of a larger work, the <monogr> describes the container work, such 
            as the journal or book title. -->
          <xsl:when test="$hasContainer">
            <title>
              <!-- Journal titles get a @level="j", all others are "m" (monograph-level title). -->
              <xsl:attribute name="level" 
                select="if ( $bibType eq 'journalArticle' ) then 'j' else 'm'"/>
              <xsl:copy-of select="$langAttr"/>
              <xsl:value-of select="$zotero-item-map?container-title"/>
            </title>
          </xsl:when>
          <!-- If this entry is the whole of the work, the title and authorship info can be placed here. -->
          <xsl:otherwise>
            <xsl:sequence select="$basicInfo"/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Describe any editors for this entry. -->
        <xsl:if test="map:contains($zotero-item-map, 'editor')">
          <xsl:for-each select="$zotero-item-map?editor?*">
            <editor>
              <xsl:call-template name="name-bibliography-contributor">
                <xsl:with-param name="person-map" select="."/>
              </xsl:call-template>
            </editor>
          </xsl:for-each>
        </xsl:if>
        <!-- Include the DOI and ISBN, if they are present in the Zotero data. -->
        <xsl:if test="map:contains($zotero-item-map, 'DOI')">
          <idno type="DOI">
            <xsl:value-of select="$zotero-item-map?DOI"/>
          </idno>
        </xsl:if>
        <xsl:if test="map:contains($zotero-item-map, 'ISBN')">
          <idno type="ISBN">
            <xsl:value-of select="$zotero-item-map?ISBN"/>
          </idno>
        </xsl:if>
        <!-- Set up the <imprint>. -->
        <imprint>
          <!-- Describe the entry's volume, issue, and page numbers, if they are present in the Zotero 
            data. -->
          <xsl:if test="map:contains($zotero-item-map, 'volume')">
            <biblScope unit="volume">
              <xsl:value-of select="$zotero-item-map?volume"/>
            </biblScope>
          </xsl:if>
          <xsl:if test="map:contains($zotero-item-map, 'issue')">
            <biblScope unit="issue">
              <xsl:value-of select="$zotero-item-map?issue"/>
            </biblScope>
          </xsl:if>
          <xsl:if test="map:contains($zotero-item-map, 'page')">
            <biblScope unit="page">
              <xsl:value-of select="$zotero-item-map?page"/>
            </biblScope>
          </xsl:if>
          <!-- Include the publisher name and publication location, if they are present in the Zotero data. -->
          <xsl:if test="map:contains($zotero-item-map, 'publisher')">
            <publisher>
              <xsl:value-of select="$zotero-item-map?publisher"/>
            </publisher>
          </xsl:if>
          <xsl:if test="map:contains($zotero-item-map,'publisher-place')">
            <pubPlace>
              <xsl:value-of select="$zotero-item-map?publisher-place"/>
            </pubPlace>
          </xsl:if>
          <!-- Try to include a publication date. Zotero describes these as an array of dates, which 
            themselves are arrays of "date parts". For example:
              [ 
                [ "2007", 3, 20 ]
              ]
            The array above contains only one date, 2007-03-20, which has been represented as an array 
            containing the year (as a string), the month and the day (as numbers).
          -->
          <xsl:variable name="arrayOfDates" select="$zotero-item-map?issued?date-parts"/>
          <xsl:if test="not(empty($arrayOfDates)) and array:size($arrayOfDates) gt 0">
            <date>
              <xsl:choose>
                <!-- If $arrayOfDates has more than one date inside it, use the first two date arrays as 
                  @from and @to. -->
                <xsl:when test="array:size($arrayOfDates) gt 1">
                  <xsl:variable name="parts" as="xs:string*">
                    <xsl:for-each select="$arrayOfDates?*">
                      <xsl:value-of select="dhq:date-array-to-string(.)"/>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:attribute name="from" select="$parts[1]"/>
                  <xsl:attribute name="to" select="$parts[2]"/>
                  <xsl:value-of select="string-join($parts, ', ')"/>
                </xsl:when>
                <!-- If $arrayOfDates has only one date, it may have a @when attribute but should always 
                  have text content. -->
                <xsl:otherwise>
                  <xsl:variable name="singularDate" select="$arrayOfDates?*"/>
                  <xsl:variable name="singularDateStr" select="dhq:date-array-to-string($singularDate)"/>
                  <!-- If the date matches one of three formats (YYYY-MM-DD, YYYY-MM, or YYYY), it can 
                    be used in a @when attribute. -->
                  <xsl:if test="$singularDateStr castable as xs:date 
                             or $singularDateStr castable as xs:gYearMonth 
                             or $singularDateStr castable as xs:gYear">
                    <xsl:attribute name="when" select="$singularDateStr"/>
                  </xsl:if>
                  <xsl:value-of select="$singularDateStr"/>
                </xsl:otherwise>
              </xsl:choose>
            </date>
          </xsl:if>
          <xsl:if test="map:contains($zotero-item-map,'URL')">
            <note type="url">
              <xsl:value-of select="$zotero-item-map?URL"/>
            </note>
          </xsl:if>
        </imprint>
      </monogr>
      <!-- If this entry occurred as part of a conference or collection, that information is described 
        in <series>. -->
      <xsl:if test="map:contains($zotero-item-map, 'collection-title')">
        <series>
          <title level="s">
            <xsl:value-of select="$zotero-item-map?collection-title"/>
          </title>
        </series>
      </xsl:if>
    </biblStruct>
  </xsl:template>
  
  <xsl:template name="name-bibliography-contributor">
    <xsl:param name="person-map" as="map(*)?"/>
    <xsl:variable name="mapKeys" select="map:keys($person-map)"/>
    <xsl:choose>
      <xsl:when test="empty($person-map)">
        <name><xsl:comment> No authorship information found in Zotero data </xsl:comment></name>
      </xsl:when>
      <xsl:when test="$mapKeys = ('given', 'family')">
        <persName>
          <forename>
            <xsl:value-of select="$person-map?given"/>
          </forename>
          <surname>
            <xsl:value-of select="$person-map?family"/>
          </surname>
        </persName>
      </xsl:when>
      <xsl:when test="$mapKeys = 'literal'">
        <orgName>
          <xsl:value-of select="$person-map?literal"/>
        </orgName>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment select="serialize($person-map)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- 
      Given an array of date components, create a string representing that date.
    -->
  <xsl:function name="dhq:date-array-to-string" as="xs:string?">
    <xsl:param name="date-array" as="array(*)?"/>
    <xsl:variable name="numDateParts" 
      select="if ( empty($date-array) ) then () else array:size($date-array)"/>
    <xsl:choose>
      <!-- If there are no usable date components, do nothing. -->
      <xsl:when test="empty($date-array) or $numDateParts eq 0"/>
      <!-- If the array contains 1–3 date components, join them up with "-" separators, W3C-style. -->
      <xsl:when test="$numDateParts gt 0 and $numDateParts le 3">
        <xsl:variable name="year" select="$date-array?(1)"/>
        <xsl:variable name="month" as="xs:string?">
          <xsl:if test="$numDateParts ge 2">
            <xsl:variable name="monthNum" select="$date-array?(2)"/>
            <xsl:value-of select="format-number($monthNum, '00')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="day" as="xs:string?">
          <xsl:if test="$numDateParts ge 3">
            <xsl:variable name="dayNum" select="$date-array?(3)"/>
            <xsl:value-of select="format-number($dayNum, '00')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="string-join(($year, $month, $day), '-')"/>
      </xsl:when>
      <!-- If the array contains more than 3 components, print them without too much munging. -->
      <xsl:otherwise>
        <xsl:variable name="dateParts">
          <xsl:for-each select="$date-array?*">
            <xsl:variable name="this-part" select="."/>
            <xsl:choose>
              <xsl:when test="$this-part instance of xs:integer and $this-part lt 100">
                <xsl:value-of select="format-number($this-part, '00')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$this-part"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($dateParts, ', ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
      Test an element for a child processing instruction that indicates a Zotero bibliography was added in.
    -->
  <xsl:function name="dhq:has-zotero-bibliography-pi" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:sequence select="exists($element/processing-instruction('biblio')[contains(., 'ADDIN ZOTERO_BIBL')])"/>
  </xsl:function>
  
  <!--
      Given a map of bibliographic data, find or create an identifier for this entry.
    -->
  <xsl:function name="dhq:set-bibliography-entry-id">
    <xsl:param name="zotero-item-map" as="map(*)"/>
    <xsl:choose>
      <!-- The standard DHQ bibliography entry ID is the first-listed author's surname, followed by the 
        publication year. If those two components are present, we can create this kind of ID. (We might 
        be able to recover from a missing date or surname, but uniqueness would not be guaranteed. This 
        function needs to be able to work independently from the collection of bibliography entries.) -->
      <xsl:when test="exists($zotero-item-map?author?*[map:contains(., 'family')]) 
                  and exists($zotero-item-map?issued[map:contains(., 'date-parts') 
                  and array:size(?date-parts) gt 0])">
        <xsl:variable name="surname1">
          <xsl:variable name="firstStr" select="($zotero-item-map?author?*[?family]?family)[1]"/>
          <xsl:value-of select="replace(lower-case($firstStr), '[^\w-]', '')"/>
        </xsl:variable>
        <xsl:variable name="date" select="$zotero-item-map?issued?date-parts?(1)?(1)"/>
        <xsl:value-of select="concat($surname1,$date)"/>
      </xsl:when>
      <!-- Some Zotero data may contain the "citation key" field, which we can use as an identifier. -->
      <xsl:when test="map:contains($zotero-item-map, 'citation-key')">
        <xsl:value-of select="replace($zotero-item-map?citation-key, '[^\w-]', '')"/>
      </xsl:when>
      <!-- If all else fails, use the word "zotero" followed by the Zotero identifier for this entry. -->
      <xsl:otherwise>
        <xsl:value-of select="concat('zotero',$zotero-item-map?id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
</xsl:stylesheet>