<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dhq="http://www.digitalhumanities.org/ns/dhq" 
                xmlns:cc="http://web.resource.org/cc/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"      
                xmlns="http://www.tei-c.org/ns/1.0"
                version="2.0">
    <!-- schema changes needed:
        
      * @style
      * seg/@xml:id
      * seg/@rend (or use @type)
      * figure[@rend = 'inline'] needs @rend
      -->

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
      <desc>
         <p> TEI utility stylesheet for identity transformation </p>
         <p>This software is dual-licensed:

1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
Unported License http://creativecommons.org/licenses/by-sa/3.0/ 

2. http://www.opensource.org/licenses/BSD-2-Clause
		
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

This software is provided by the copyright holders and contributors
"as is" and any express or implied warranties, including, but not
limited to, the implied warranties of merchantability and fitness for
a particular purpose are disclaimed. In no event shall the copyright
holder or contributors be liable for any direct, indirect, incidental,
special, exemplary, or consequential damages (including, but not
limited to, procurement of substitute goods or services; loss of use,
data, or profits; or business interruption) however caused and on any
theory of liability, whether in contract, strict liability, or tort
(including negligence or otherwise) arising in any way out of the use
of this software, even if advised of the possibility of such damage.
</p>
         <p>Author: See AUTHORS</p>
         <p>Id: $Id: identity.xsl 9646 2011-11-05 23:39:08Z rahtz $</p>
         <p>Copyright: 2008, TEI Consortium</p>
      </desc>
   </doc>
    
    <xsl:output omit-xml-declaration="yes"/>

    <!-- identity transform -->
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            href="../../common/schema/DHQauthor-TEI.rnc" type="application/relax-ng-compact-syntax"
        </xsl:processing-instruction>
        <TEI>
        <xsl:call-template name="teiHeader"/>
        <text>
            <body>
        <xsl:apply-templates select="//*[@id = 'DHQtext']"/>
            </body>
            <back>
        <xsl:apply-templates select="//*[@id = 'worksCited']"/>
            </back>
        </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="body">
        <body>
            <xsl:apply-templates/>
        </body>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:call-template name="addID"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
	     </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class = 'bibl']">
        <bibl xml:id="{span[@class = 'ref']/@id}" label="{span[@class = 'ref']}">
            <xsl:apply-templates/>
        </bibl>
    </xsl:template>
    
    <xsl:template match="div[@class = 'bibl']/span[@class = 'ref']"/>
    
    <xsl:template match="center[img]">
        <figure>
            <head>
                <xsl:apply-templates select="p[@class = 'caption']"/>
            </head>
            <figDesc><xsl:value-of select="img/@alt"/></figDesc>
            <graphic url="{img/@src}"/>
        </figure>
    </xsl:template>
    
    <xsl:template match="p[@class = 'caption']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="i">
        <hi rend="italic"><xsl:apply-templates/></hi>
    </xsl:template>
    
    <xsl:template match="cite">
        <title><xsl:apply-templates/></title>
    </xsl:template>
    
    <xsl:template match="div">
        <div>
            <xsl:call-template name="addAtts"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="div[@class = 'counter']"/>
    
    <xsl:template match="div[@class = 'ptext']">
        <p>
            <xsl:call-template name="addStyle"/>
            <xsl:call-template name="addMouseover"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="//div[@class = 'ptext']/div">
        <seg>
            <xsl:call-template name="addAtts"/>
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    
    
    
    
    
    <xsl:template match="h1|h2|h3|h4|h5|h6">
        <head><xsl:call-template name="addID"/><xsl:apply-templates/></head>
    </xsl:template>
    
    <xsl:template match="ul">
        <list type="bulleted">
            <xsl:call-template name="addID"/>
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    
    <xsl:template match="li">
        <item><xsl:call-template name="addID"/><xsl:apply-templates/></item>
    </xsl:template>
    
    
    <xsl:template match="@id">
        <xsl:attribute name="xml:id" select="."/>
    </xsl:template>
    
    
    <xsl:template name="addID">
        <xsl:if test="@id">
            <xsl:attribute name="xml:id">
                 <xsl:value-of select="@id"/>
            </xsl:attribute> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="addStyle">
        <xsl:if test="@style">
            <xsl:attribute name="style">
                <xsl:value-of select="@style"/>
            </xsl:attribute> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="addMouseover">
        <xsl:if test="@mouseover">
            <xsl:attribute name="mouseover">
                <xsl:value-of select="@mouseover"/>
            </xsl:attribute> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="addAtts">
        <xsl:call-template name="addID"/>
        <xsl:call-template name="addStyle"/>
        <xsl:call-template name="addMouseover"/>
    </xsl:template>
    
    <xsl:template match="blockquote">
        <quote rend="block">
            <xsl:apply-templates/>
        </quote>
    </xsl:template>
    
    <xsl:template match="br">
        <lb/>
    </xsl:template>
    
    <xsl:template match="span[@onmouseover=&quot;this.className='smalltext'&quot;]">
        <seg type="transform_small_text">
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    
    <xsl:template match="span[@onmouseover = &quot;replaceText(this,'-in');this.className='bigtext';&quot;]">
        <seg type="transform_big_text">
            <choice type="transform">
                <orig> in</orig>
                <reg>-in</reg>
            </choice>
        </seg>
    </xsl:template>
    
    <xsl:template match="h1[center]">
        <head rend="center">
            <xsl:apply-templates select="center/text()"/>
        </head>
    </xsl:template>
    
    <xsl:template name="teiHeader">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <xsl:comment>Author should supply the title and personal information</xsl:comment>
                    <title type="article"><hi rend="bold">Coming soon:</hi> A Deep History of Electronic Textuality: The Case of <title rend="italic">English Reprints Jhon Milton Areopagitica</title></title>
                    <dhq:authorInfo>
                        <xsl:comment>Include a separate &lt;dhq:authorInfo> element for each author</xsl:comment>
                        <dhq:author_name>Whitney Anne <dhq:family>Trettien</dhq:family></dhq:author_name>
                        <dhq:affiliation>Duke University</dhq:affiliation>
                        <email>whitney.trettien@duke.edu</email>
                        <dhq:bio><p>Whitney Anne Trettien is a PhD candidate in English at Duke University, with a master's degree from MIT in Comparative Media Studies. Her projects and publications, both creative and critical, can be found at her website: <ref target="http://whitneyannetrettien.com">http://whitneyannetrettien.com</ref>.</p></dhq:bio>
                    </dhq:authorInfo>
                </titleStmt>
                <publicationStmt><publisher>Alliance of Digital Humanities Organizations</publisher>
<publisher>Association for Computers and the Humanities</publisher>
                    <xsl:comment>This information will be completed at publication</xsl:comment>
                    <idno type="DHQarticle-id">000150</idno>
                    <idno type="volume">007</idno>
                    <idno type="issue">1</idno>
                    <date when="2013-07-03">3 July 2013</date>
                    <dhq:articleType>article</dhq:articleType>
                    <availability><cc:License rdf:about="http://creativecommons.org/licenses/by-nc-nd/2.5/"/></availability>
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
                    <language ident="en"/>
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
                <change when="2013-03-20" who="JHF">Created stub article</change>
            </revisionDesc>
        </teiHeader>
        
    </xsl:template>
    
    <xsl:template match="div[@id = 'worksCited']">
        <listBibl>
            <xsl:apply-templates/>
        </listBibl>
    </xsl:template>
    
    
    
    
        
</xsl:stylesheet>