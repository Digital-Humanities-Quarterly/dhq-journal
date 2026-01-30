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
    exclude-result-prefixes="xs array map math"
    version="3.0">
    
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Whether or not to Zotero-derived <biblStruct>s should be saved in a separate document. -->
    <xsl:param name="save-zotero-biblStructs-elsewhere" select="true()" as="xs:boolean"/>
    <!-- If $save-zotero-biblStructs-elsewhere is turned on, the filepath to the document for the 
      derived <listBibl>. -->
    <xsl:param name="save-zotero-biblStructs-to" as="xs:string?">
      <xsl:variable name="inputDocPath" select="base-uri()"/>
      <xsl:value-of select="replace($inputDocPath, '[^/]+$', 'zotero-data.xml')"/>
    </xsl:param>
    
    <!-- Whether to put the Zotero JSON bibliography entries in the article's <xenoData>. -->
    <xsl:param name="show-zotero-json" select="false()" as="xs:boolean"/>
    
    <!-- Try to generate maps from the JSON contents of Zotero "CSL citation" processing instructions. -->
    <xsl:variable name="zotero-citation-processing-instructions" as="map(*)*">
      <xsl:for-each select="//processing-instruction('biblio')[contains(., 'ZOTERO_ITEM CSL_CITATION')]">
        <xsl:variable name="citationMap" select="parse-json(substring-after(., 'CSL_CITATION'))" as="map(*)"/>
        <!-- Zotero citation IDs are not guaranteed to be unique (I suspect they may be duplicated if 
          the author copy-pasted a citation), so we add the processing instruction's XPath string as a 
          means to identify a citation map from a particular PI. -->
        <xsl:sequence select="map:merge(( $citationMap, map:entry('xpath', path(.)) ))"/>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- Process data from the Zotero citation PIs in order to get one map per unique bibliography entry. -->
    <xsl:variable name="bibliography-entries-from-citation-PIs" as="map(*)?">
      <xsl:if test="exists($zotero-citation-processing-instructions)">
        <!-- Group all citationItems by their Zotero ID, which allows us to get only one map per ID. -->
        <xsl:variable name="uniqueCitedEntries" as="map(*)">
          <xsl:map>
            <xsl:for-each-group select="$zotero-citation-processing-instructions?citationItems?*" group-by="?id">
              <xsl:variable name="entryMap" select="current-group()[1]"/>
              <xsl:map-entry key="current-grouping-key()" select="$entryMap"/>
            </xsl:for-each-group>
          </xsl:map>
        </xsl:variable>
        <!-- Generate a mapping of the Zotero ID to a proposed, generated bibliography ID. At this point, 
          the generated ID is not guaranteed to be unique — if the same author published two articles in 
          one year, for instance, the generated ID would probably be the same. -->
        <xsl:variable name="zoteroIdToArticleId" as="map(*)">
          <xsl:map>
            <xsl:for-each select="$uniqueCitedEntries?*">
              <xsl:variable name="entryMap" select="."/>
              <xsl:variable name="proposedArticleId" 
                select="dhq:propose-bibliography-entry-id($entryMap?itemData)"/>
              <xsl:map-entry key="$entryMap?id" select="$proposedArticleId"/>
            </xsl:for-each>
          </xsl:map>
        </xsl:variable>
        <!-- Compose a map with all unique Zotero bibliography entry maps, as well as newly generated 
          data such as their unique generated IDs. -->
        <xsl:map>
          <xsl:variable name="zoteroKeys" select="map:keys($zoteroIdToArticleId)"/>
          <xsl:for-each select="$zoteroKeys">
            <xsl:variable name="zoteroId" select="."/>
            <xsl:variable name="thisEntry" select="$uniqueCitedEntries?($zoteroId)"/>
            <xsl:variable name="artId" as="xs:string">
              <xsl:variable name="proposedId" select="$zoteroIdToArticleId?($zoteroId)"/>
              <xsl:choose>
                <!-- If there's proposed ID is represented more than once in the Zotero-to-DHQ mapping, 
                  add a postfix with the index of this key in the $zoteroKeys sequence. -->
                <xsl:when test="count($zoteroIdToArticleId?*[. eq $proposedId]) gt 1">
                  <xsl:sequence select="$proposedId||'-'||index-of($zoteroKeys, $zoteroId)"/>
                </xsl:when>
                <!-- Otherwise, it's already unique. Use the proposed ID as-is. -->
                <xsl:otherwise>
                  <xsl:sequence select="$proposedId"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!-- We use the Zotero ID as the key, because it is guaranteed to be unique and individual 
              citations can reference it to get at the unique generated ID. -->
            <xsl:map-entry key="xs:string($zoteroId)">
              <!-- Compile data for the bibliography entry. -->
              <xsl:call-template name="parse-bibliographic-json">
                <xsl:with-param name="citation-map" select="$thisEntry"/>
                <xsl:with-param name="unique-entry-id" select="$artId"/>
              </xsl:call-template>
            </xsl:map-entry>
          </xsl:for-each>
        </xsl:map>
      </xsl:if>
    </xsl:variable>
    
    
    <!-- Before doing anything else, check for Zotero inline citations (processing instructions which contain 
      JSON). The bibliographic data is compiled here so that it can be used elsewhere in the document. -->
    <xsl:template match="/">
      <xsl:choose>
        <!-- If there are no Zotero processing instructions, apply templates to the DHQ article as usual. -->
        <xsl:when test="empty($zotero-citation-processing-instructions)">
          <xsl:apply-templates/>
        </xsl:when>
        <!-- If there are citation PIs, compile the JSON data they contain, then tunnel the maps to the 
          templates that can make use of that data. -->
        <xsl:otherwise>
          <!-- Prepare DHQ-style citations. -->
          <xsl:variable name="zoteroCitationPtrs" as="map(*)">
            <xsl:map>
              <!-- For each citation PI, create <ptr>s to each of the referenced bibliography entries. -->
              <xsl:for-each select="$zotero-citation-processing-instructions">
                <!-- Because Zotero's citation identifiers may be duplicated, we need to use the XPath 
                  string for the PI to guarantee a unique map key. -->
                <xsl:variable name="zoteroCitationId" select=".?citationID" as="xs:string"/>
                <xsl:variable name="piPath" select=".?xpath" as="xs:string"/>
                <xsl:map-entry key="dhq:make-unique-citation-key($zoteroCitationId, $piPath)">
                  <xsl:for-each select="?citationItems?*">
                    <xsl:variable name="zoteroID" select="?itemData?id cast as xs:string" as="xs:string"/>
                    <xsl:variable name="idref" select="dhq:get-bibliography-entry-id($zoteroID)"/>
                    <ptr target="#{$idref}">
                      <xsl:if test="map:contains(., 'locator')">
                        <xsl:attribute name="loc" select="?locator"/>
                      </xsl:if>
                    </ptr>
                  </xsl:for-each>
                </xsl:map-entry>
              </xsl:for-each>
            </xsl:map>
          </xsl:variable>
          <!-- Proceed to transform the DHQ article as expected, but tunnel the compiled Zotero citation 
            data to the templates that need them. The bibliography maps are stored in the global 
            variable $bibliography-entries-from-citation-PIs. -->
          <xsl:apply-templates>
            <xsl:with-param name="inline-citations" select="$zoteroCitationPtrs" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
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
                    <date><xsl:comment>include @when with ISO date and also content in the form 23 February 2024</xsl:comment></date>
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
                        <bibl>DHQ classification scheme; full list available at <ref target="https://dhq.digitalhumanities.org/taxonomy.xml">https://dhq.digitalhumanities.org/taxonomy.xml</ref></bibl>
                    </taxonomy>
                    <taxonomy xml:id="authorial_keywords">
                        <bibl>Keywords supplied by author; no controlled vocabulary</bibl>
                    </taxonomy>
                        <taxonomy xml:id="project_keywords">
                                <bibl>DHQ project registry; full list available at <ref target="https://dhq.digitalhumanities.org/projects.xml">https://dhq.digitalhumanities.org/projects.xml</ref></bibl>
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
                        <xsl:comment>Authors may suggest one or more keywords from the DHQ keyword list, visible at https://dhq.digitalhumanities.org/taxonomy.xml; these may be supplemented or modified by DHQ editors</xsl:comment>
                        
                        <xsl:comment>Enter keywords below preceeded by a "#". Create a new term element for each</xsl:comment>
                        <term corresp=""/>
                    </keywords>
                    <keywords scheme="#authorial_keywords">
                      <xsl:comment>Authors may include one or more keywords (in &lt;term> elements) of their choice</xsl:comment>
                      <term/>
                    </keywords>
                        <keywords scheme="#project_keywords">
                                <list type="simple">
                                        <item></item>
                                </list>
                        </keywords>
                </textClass>
            </profileDesc>
           <!-- Create a copy of the Zotero bibliographic data in <xenoData>. (Useful for debugging.) -->
           <xsl:if test="$show-zotero-json and exists($bibliography-entries-from-citation-PIs)">
              <xenoData>
                <xsl:text>[ </xsl:text>
                <xsl:sequence select="string-join($bibliography-entries-from-citation-PIs?*?jsonStr, ',&#x20;&#x20;&#x0A;')"/>
                <xsl:text> ]</xsl:text>
              </xenoData>
           </xsl:if>
           <revisionDesc>
             <xsl:comment> Replace both "NNNNNN"s in the @target of ther &lt;ref> below with the appropriate DHQarticle-id value. </xsl:comment>
	     <change>The version history for this file can be found on <ref type="gitHist" target="https://github.com/Digital-Humanities-Quarterly/dhq-journal/commits/main/articles/NNNNNN/NNNNNN.xml">GitHub</ref>.</change>
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
                    <xsl:choose>
                      <!-- If $save-zotero-biblStructs-elsewhere is toggled on, and there's a Zotero bibliography, 
                        process <p>-citations as <bibl>s and save the Zotero-derived <biblStruct>s to a separate 
                        document. -->
                      <xsl:when test="$save-zotero-biblStructs-elsewhere and exists($bibliography-entries-from-citation-PIs)">
                        <xsl:apply-templates select="descendant::p[dhq:has-zotero-bibliography-pi(.)]" 
                          mode="biblio"/>
                        <xsl:if test="exists($save-zotero-biblStructs-to) and 
                           normalize-space($save-zotero-biblStructs-to) ne ''">
                          <xsl:result-document href="{$save-zotero-biblStructs-to}">
                            <xsl:document>
                              <listBibl>
                                <xsl:sequence select="$bibliography-entries-from-citation-PIs?*?teiBibEntry"/>
                              </listBibl>
                            </xsl:document>
                          </xsl:result-document>
                        </xsl:if>
                      </xsl:when>
                      <!-- If the document contains Zotero citations, populate the DHQ bibliography with those 
                        entries. -->
                      <xsl:when test="exists($bibliography-entries-from-citation-PIs)">
                        <xsl:variable name="biblStructSeq" as="node()*">
                          <xsl:apply-templates select="descendant::p[dhq:has-zotero-bibliography-pi(.)]" 
                            mode="biblio"/>
                        </xsl:variable>
                        <xsl:variable name="unmatchedEntries" as="node()*" 
                          select="$bibliography-entries-from-citation-PIs?*[not(?citationKey = $biblStructSeq/@xml:id/data(.))]
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
        
   <xsl:template match="figure/graphic" priority="2">
     <!-- <graphic>s that are already wrapped in <figure> get
          reproduced with just their @url. -->
     <xsl:copy><xsl:apply-templates select="attribute::url"/></xsl:copy>
   </xsl:template>
   
   <xsl:template match="graphic" priority="1">
     <!-- <graphic>s without a parent <figure> get wrapped in
          <figure>. (Those with a parent <figure> are processed 
          in the template above, instead.)-->
     <figure>
       <head></head>
       <graphic><xsl:apply-templates select="attribute::url"/></graphic>
     </figure>
   </xsl:template>

  <xsl:template match="figure">
    <xsl:copy>
      <xsl:apply-templates select="head"/>
      <!-- We always want a <head>, even if empty (in which case line
           above did nothing)-->
      <xsl:if test="not(head)"><head/></xsl:if>
      <xsl:apply-templates select="graphic|table"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@url">
    <!-- TEIGarage puts images in a './media/' directory, but we want
         to use a './resources/images/' directory. -->
    <xsl:attribute name="url" select="replace( normalize-space(.), '^.*/', 'resources/images/')"/>
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
    </xsl:template>
    -->
        <!--Created code below for cases where a converted file has extensive highlighting that needs to be retained; commented out because in most cases this is more trouble than it is worth (since there's a lot of extraneous <hi> coming from TEIGarage). Longer term, we want to be able to parse the @style attribute on <hi> and pass through more actionable information to the final version.
    <xsl:template match="hi">
        <xsl:copy>
            <xsl:apply-templates select="attribute::style | child::node()"/>
        </xsl:copy>
    </xsl:template>
-->    
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
      <xsl:variable name="xpath" select="path(.)"/>
      <xsl:if test="$show-zotero-json">
        <xsl:copy/>
      </xsl:if>
      <xsl:sequence select="$inline-citations?(dhq:make-unique-citation-key($citationID, $xpath))"/>
    </xsl:template>
    
    
  <!--
      BIBLIO MODE
    -->
    
    <xsl:template match="div[not(descendant::div)][descendant-or-self::*[dhq:has-zotero-bibliography-pi(.)]]"
       mode="biblio">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
      </xsl:copy>
    </xsl:template>
    
    <!-- <p>s are not processed by default, only when Zotero's processing instruction appears. -->
    <xsl:template match="p" mode="biblio"/>
    
    <!-- This template handles the paragraph with the Zotero processing instruction. The PI indicates 
      that this and all following <p>s are generated by Zotero. In order to process each <p> in order, 
      this template also processes the triggering <p>'s siblings. -->
    <xsl:template match="p[dhq:has-zotero-bibliography-pi(.)]" mode="biblio" priority="2">
      <!-- Iterate over this and all following paragraphs, treating them as bibliographic citations. -->
      <xsl:iterate select="(., following-sibling::p)">
        <xsl:param name="try-entries" select="$bibliography-entries-from-citation-PIs" as="map(*)?"/>
        <!-- Turn this <p> into a <bibl>, which will give us a better foundation for finding matches. -->
        <xsl:variable name="thisBibl" as="node()">
          <bibl>
            <xsl:apply-templates mode="biblio"/>
          </bibl>
        </xsl:variable>
        <xsl:variable name="italicizedField" 
          select="descendant::hi[normalize-space(.) ne ''][1]/replace(., '\W', '')"/>
        <xsl:variable name="biblMatches" as="map(*)*" 
          select="dhq:match-citations($thisBibl, $try-entries)"/>
        <xsl:variable name="numMatches" select="count($biblMatches)"/>
        <xsl:choose>
          <!-- If we're replacing this <p> with a matching <biblStruct>, do so. -->
          <xsl:when test="not($save-zotero-biblStructs-elsewhere) and $numMatches eq 1">
            <xsl:sequence select="$biblMatches?teiBibEntry"/>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" select="map:remove($try-entries, $biblMatches?itemId)"/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- If we want to replace this <p> but more than one <biblStruct> matches, surround the possible 
            matches with comments. -->
          <xsl:when test="not($save-zotero-biblStructs-elsewhere) and $numMatches gt 1">
            <xsl:comment> More than one match!!! </xsl:comment>
            <xsl:sequence select="$biblMatches?teiBibEntry"/>
            <xsl:comment> End matches!!! </xsl:comment>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" select="$try-entries"/>
            </xsl:next-iteration>
          </xsl:when>
          <!-- Otherwise, transform this <p> into a <bibl>. -->
          <xsl:otherwise>
            <bibl>
              <xsl:if test="$numMatches eq 1">
                <xsl:attribute name="xml:id" select="$biblMatches?citationKey"/>
              </xsl:if>
              <xsl:sequence select="$thisBibl/node()"/>
            </bibl>
            <xsl:next-iteration>
              <xsl:with-param name="try-entries" 
                select="if ( $numMatches eq 1 ) then
                          map:remove($try-entries, $biblMatches?itemId)
                        else $try-entries"/>
            </xsl:next-iteration>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:iterate>
    </xsl:template>
    
    <!-- Process the text node children of <p>-citations. Quote marks are turned into <title rend="quotes"> 
      (ONLY if both delimiters are present; it's easier for humans to introduce tags across multiple nodes). URLs 
      (starting with "http" or "https") are turned into <ref>. -->
    <xsl:template match="p/text() | title/text()" priority="3" mode="biblio">
      <!-- Look for double quote pairs first. -->
      <xsl:variable name="parsedQuoteDoubles" as="node()*">
        <xsl:analyze-string select="." regex="“([^”]+)”" flags="m">
          <xsl:matching-substring>
            <title rend="quotes"><xsl:value-of select="regex-group(1)"/></title>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <!-- Test the text node results of $parsedQuoteDoubles for single quote pairs. -->
      <xsl:variable name="parsedQuoteSingles" as="node()*">
        <xsl:for-each select="$parsedQuoteDoubles">
          <xsl:choose>
            <xsl:when test="self::text()">
              <!-- We can't use the [^’] character group here, because ’ can be used in contractions. Using . in 
                "dot-all" mode (the "s" flag) will match the furthest closing delimiter and hopefully include 
                those contractions. -->
              <xsl:analyze-string select="." regex="‘(.+)’" flags="sm">
                <xsl:matching-substring>
                  <title rend="quotes"><xsl:value-of select="regex-group(1)"/></title>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="biblio"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <!-- Test the text node results of $parsedQuoteSingles for strings that look like URLs. -->
      <xsl:variable name="parsedUrls" as="node()*">
        <xsl:for-each select="$parsedQuoteSingles">
          <xsl:choose>
            <xsl:when test="self::text()">
              <!-- Though periods are valid characters in URLs, the period at the end is not part of the <ref>. -->
              <xsl:analyze-string select="." regex="(https?://?[A-Za-z0-9\.~:/?#\[\]@!$&amp;'()*+,;%=_-]+)(\.)">
                <xsl:matching-substring>
                  <ref target="{regex-group(1)}"><xsl:value-of select="regex-group(1)"/></ref>
                  <xsl:text>.</xsl:text>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="biblio"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <!-- Output whatever nodes have been processed above. -->
      <xsl:sequence select="$parsedUrls"/>
    </xsl:template>
    
    <!-- Any <hi> is likely to be a title of some kind when it appears inside one of Zotero's generated 
      "Bibliography" paragraphs. -->
    <xsl:template match="p//hi[@rend eq 'italic']" priority="5" mode="biblio">
      <title>
        <xsl:apply-templates select="@* | node()"/>
      </title>
    </xsl:template>
    
    <!-- The template that parses //p/text() iteratively introduces <title> elements. If we run across one, copy 
      its structure and process its children. -->
    <xsl:template match="title" mode="biblio">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="biblio"/>
      </xsl:copy>
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
    <xsl:param name="unique-entry-id" as="xs:string?"/>
    <xsl:variable name="bibData" select="$citation-map?itemData"/>
    <xsl:map>
      <xsl:map-entry key="'itemId'" select="$bibData?id"/>
      <xsl:map-entry key="'citationKey'" select="$unique-entry-id"/>
      <xsl:map-entry key="'jsonMap'" select="$bibData"/>
      <xsl:map-entry key="'jsonStr'" select="serialize($citation-map, map { 'method': 'json', 'indent': true() })"/>
      <!-- Generate a <biblStruct> that can be used in the bibliography instead of a <p> or plain <bibl>. -->
      <xsl:map-entry key="'teiBibEntry'">
        <xsl:call-template name="make-biblStruct-from-zotero-data">
          <xsl:with-param name="zotero-item-map" select="$bibData"/>
          <xsl:with-param name="zotero-item-uri" select="$citation-map?uris?1"/>
          <xsl:with-param name="citation-key" select="$unique-entry-id"/>
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
    <xsl:param name="citation-key" as="xs:string" 
      select="dhq:get-bibliography-entry-id($zotero-item-map?id cast as xs:string)"/>
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
    <biblStruct xml:id="{$citation-key}" type="{$bibType}" corresp="{$zotero-item-uri}">
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
      Given a string, lower-case it and remove characters that aren't letters or digits.
    -->
  <xsl:function name="dhq:comparable-string" as="xs:string?">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:if test="exists($string)">
      <xsl:value-of select="lower-case($string) 
                            => replace('\W', '')
                            => normalize-space()"/>
    </xsl:if>
  </xsl:function>
  
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
      Given a <bibl> with minimal encoding, try to identify the Zotero bibliography entry (or entries) which 
      match it.
    -->
  <xsl:function name="dhq:match-citations" as="map(*)*">
    <xsl:param name="readable-citation" as="node()"/>
    <xsl:param name="bibliography-entry-map" as="map(*)"/>
    <xsl:variable name="entryMatchUrl" 
      select="if ( empty($readable-citation//ref[@target]) ) then () else 
              $bibliography-entry-map?*[?jsonMap?URL[. = $readable-citation//ref[@target]/data(@target)]]"/>
    <xsl:choose>
      <xsl:when test="exists($entryMatchUrl)">
        <xsl:sequence select="$entryMatchUrl"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="readableTitles" select="$readable-citation/title/dhq:comparable-string(.)"/>
        <xsl:variable name="biblMatchTitle"
          select="$bibliography-entry-map?*[exists(?jsonMap?title[dhq:comparable-string(.) = $readableTitles])
                                         or exists(?jsonMap?container-title[dhq:comparable-string(.) = $readableTitles])]"/>
        <xsl:sequence select="$biblMatchTitle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
      Given a map of bibliographic data, find or create an identifier for this entry.
    -->
  <xsl:function name="dhq:propose-bibliography-entry-id">
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
  
  <!--
      Given a bibliography entry's Zotero ID (a number cast as a string), get the unique ID that should 
      be used in the DHQ article.
    -->
  <xsl:function name="dhq:get-bibliography-entry-id" as="xs:string?">
    <xsl:param name="zotero-id" as="xs:string"/>
    <xsl:if test="map:contains($bibliography-entries-from-citation-PIs, $zotero-id)">
      <xsl:sequence select="$bibliography-entries-from-citation-PIs?($zotero-id)?citationKey"/>
    </xsl:if>
  </xsl:function>
  
  <!--
      Given a Zotero citation ID and an XPath representing the processing instruction, concatenate the
      strings to create a unique identifier and map key.
    -->
  <xsl:function name="dhq:make-unique-citation-key" as="xs:string">
    <xsl:param name="zotero-id" as="xs:string"/>
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:sequence select="$zotero-id||'-'||$xpath"/>
  </xsl:function>
  
</xsl:stylesheet>
