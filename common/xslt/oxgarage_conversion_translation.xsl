<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
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
                    <title type="article" xml:lang="[2-letter language code]"><xsl:comment>article title in non-English language</xsl:comment></title>
                    <title type="article" xml:lang="en"><xsl:comment>article title in English</xsl:comment></title>
                    <xsl:comment>Add a &lt;title&gt; with appropriate @xml:lang for articles in languages other than English</xsl:comment>
                    <dhq:authorInfo xml:id="">
                        <xsl:comment>Include a separate &lt;dhq:authorInfo&gt; element for each author</xsl:comment>
                        <xsl:comment>The value of xml:id should be first_last without diacritics, all lower case.</xsl:comment>
                        <dhq:author_name>first name(s) <dhq:family>family name</dhq:family></dhq:author_name>
                    <idno type="ORCID"><xsl:comment>if the author has an ORCID ID, include the full URI, e.g. https://orcid.org/0000-0000-0000-0000</xsl:comment></idno>
                        <dhq:affiliation></dhq:affiliation>
                        <email></email>
                        <dhq:bio><p></p></dhq:bio>
                    </dhq:authorInfo>
                    <dhq:translatorInfo xml:id="">
                         <xsl:comment>Include a separate &lt;dhq:translatorInfo&gt; element for each translator</xsl:comment>
                         <xsl:comment>The value of xml:id should be first_last without diacritics, all lower case.</xsl:comment>
                        <dhq:translator_name>first name(s) <dhq:family>family name</dhq:family></dhq:translator_name>
                        <dhq:affiliation></dhq:affiliation>
                        <email></email>
                        <dhq:bio><p></p></dhq:bio>
                    </dhq:translatorInfo>
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
                </classDecl>
            </encodingDesc>
            <profileDesc>
                <langUsage>
                    <language ident="en" extent="fill in extent: original | translation | translation stub"/>
                    <language ident="[2-letter language code]" extent="fill in extent"/>
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
                </textClass>
            </profileDesc>
            <revisionDesc>
                <xsl:comment>Each change should include @who and @when as well as a brief note on what was done.</xsl:comment>
                <change></change>
            </revisionDesc>
        </teiHeader>
    </xsl:template>
    
    <xsl:template match="text">
        <text>
            <group>
                
                <xsl:comment>Original language</xsl:comment>

        <xsl:copy>
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:attribute name="type">original</xsl:attribute>
            <xsl:attribute name="resp">-- fill in --</xsl:attribute>
            <xsl:comment>@resp for the original article is a pointer to xml:id of &lt;dhq:authorInfo&gt;, e.g. "#john_doe"</xsl:comment>
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
        </xsl:copy>
                
                <xsl:comment>Translated language</xsl:comment>
                
                <text xml:lang="en" type="translation_stub" resp="!-- fill in --">
                    <xsl:comment>Use "translation_stub" if only the abstract and possibly a short summary is translated. Use "translation" if the entire article has been translated.</xsl:comment>
                   <xsl:comment> @resp for the translation is a pointer to xml:id of &lt;dhq:translatorInfo&gt;</xsl:comment>
                    <front>
                        <dhq:abstract>
                            <p></p>
                        </dhq:abstract>
                        <dhq:teaser>
                            <p></p>
                        </dhq:teaser>
                    </front>
                    <body>
                        <div>
                            <head>Note on Translation</head>
                            <xsl:comment>This boilerplate paragraph describes DHQ's translation practices. If there is no full translation, this paragraph should be left in place. If the article is fully translated, this paragraph can be deleted (it is essentially a stand-in in cases where no full translation is provided).</xsl:comment>
                            <p>For articles in languages other than English, DHQ provides an English-language abstract to support searching and discovery, and to enable those not fluent in the article's original language to get a basic understanding of its contents. In many cases, machine translation may be helpful for those seeking more detailed access. While DHQ does not typically have the resources to translate articles in full, we welcome contributions of effort from readers. If you are interested in translating any article into another language, please contact us at editors@digitalhumanities.org and we will be happy to work with you.</p>
                        </div>
                    </body>
                </text>
                
            </group>
            
            <xsl:comment>The bibliography should follow DHQ's standard practices.</xsl:comment>
            <back>
                <listBibl>
                    <bibl></bibl>
                </listBibl>
            </back>
            
        </text>
    </xsl:template>
    
    
     
    <!-- Transformations To Contents of <text> -->
    <xsl:template match="p/@* | note/@* | table/@*"/>
    <xsl:template match="anchor | graphic"/>
    
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
    <xsl:template match="seg">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="hi[@rend eq 'italic']">
        <xsl:copy>
            <xsl:apply-templates select="attribute::rend | child::node()"/>
        </xsl:copy>
    </xsl:template>
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
    
    
    <!-- Transformations Re MathML -->
    <xsl:template match="mml:mi/@xml:space"/>
    
    
    

    
</xsl:stylesheet>