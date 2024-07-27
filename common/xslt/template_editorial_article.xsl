<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei dhq xdoc xhtml" version="1.0">
    
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="dhq2html.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xdoc:doc type="stylesheet">
        <xdoc:author>John A. Walsh</xdoc:author>
        <xdoc:copyright>Copyright 2006 John A. Walsh</xdoc:copyright>
        <xdoc:short>XSLT stylesheet to transform DHQauthor documents to XHTML.</xdoc:short>
    </xdoc:doc>
    <!--    <xsl:param name="source" select="''"/>-->
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:template match="tei:TEI">
        <!-- base url to which vol issue id to be attached -->
        
        <html>
            <!-- code to retrieve document title from the TEI file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"/>
            </xsl:call-template>
            
            <body>
                <!-- Call different templates to put the banner, footer, top and side navigation elements -->
                <!--  <xsl:call-template name="banner"/>-->
                <xsl:call-template name="topnavigation"/>
                <div id="main">
                    <div id="leftsidebar">
                        <xsl:call-template name="sidenavigation"/>
                        <!-- moved tapor toolbar to the article level toolbar in dhq2html xslt -->
                        <!--                        <xsl:call-template name="taportool"/> -->
                    </div>
                    <div id="mainContent">
                        <xsl:call-template name="sitetitle"/>
                        
                        <!-- Rest of the document/article is coverd in this template - this is a call to dhq2html.xsl -->
                        <xsl:call-template name="article_main_body"/> 
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
                <xsl:call-template name="customBody"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- customBody template (below) may be overridden in article-specific XSLT (in articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include additional stuff at end of the HTML <body>. See 000151. -->
    <xsl:template name="customBody"/>
    
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
        <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <!-- 2024-06: The ID generated for the bios page does not always match the ID generated here! -->
        <xsl:variable name="bios">
            <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/>
        </xsl:variable>
        <div class="author">
            <!-- 2024-06: Ash changed this to a relative link. The bios page for the Internal Preview 
              site is in the directory above this article's. -->
            <a rel="external">
                <xsl:attribute name="href" select="concat('../bios.html','#',$bios)"/>
                <xsl:apply-templates select="dhq:author_name"/>
            </a>
            <xsl:if test="normalize-space(child::dhq:affiliation)">
                <xsl:apply-templates select="tei:email" mode="author"/>
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="dhq:affiliation"/>
            <xsl:if test="tei:idno[@type='ORCID']">
                <xsl:call-template name="orcid">
                    <xsl:with-param name="orcid" select="normalize-space(tei:idno[@type = 'ORCID'])"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template name="orcid">
        <xsl:param name="orcid"/>
        <xsl:value-of select="' '"/>
        <a href="{$orcid}">
            <img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /><xsl:value-of select="concat('&#x00a0;',$orcid)"/></a>
    </xsl:template>
    
    <xsl:template name="pubInfo">
        <div id="pubInfo">
            <xsl:text>Editorial</xsl:text><br />
        </div>
    </xsl:template>
    
    <xsl:template name="toolbar">
        <xsl:param name="vol_no_zeroes" select="replace( $vol, '^0+', '')"/>
        <div class="toolbar">
            <!-- 2024-06: Ash changed this to a relative link. The index page for the Internal Preview 
              site is in the directory above this article's. -->
            <a>
                <xsl:attribute name="href" select="'../index.html'"/>
                <xsl:text>Editorial</xsl:text>
            </a>
            &#x00a0;|&#x00a0;
            <!-- 2024-06: The XML for this article is in this directory. -->
            <a>
                <xsl:attribute name="href" select="concat($id,'.xml')"/>
                <xsl:text>XML</xsl:text>
            </a>
            |&#x00a0;
            <a href="#" onclick="javascript:window.print();"
                title="Click for print friendly version">Print Article</a>
        </div> 
        <!--        <div> 
            <xsl:call-template name="taportool"/>
            </div> -->
    </xsl:template>
    
    <xsl:template name="toolbar_with_tapor">
        <div class="toolbar">
            <form id="taporware" action="get">
                <!-- added <p></p> to surrond form content to validate [CRB] -->
                <p>
                    <!-- 2024-06: Ash changed this to a relative link. The index page for the Internal Preview 
                      site is in the directory above this article's. -->
                    <a>
                        <xsl:attribute name="href" select="'../index.html'"/>
                        <xsl:text>Editorial</xsl:text>
                    </a>
                    &#x00a0;|&#x00a0;
                    <!-- 2024-06: The XML for this article is in this directory. -->
                    <a>
                        <xsl:attribute name="href" select="concat($id,'.xml')"/>
                        <xsl:text>XML</xsl:text>
                    </a>
                    |&#x00a0;
                    <a href="#" onclick="javascript:window.print();"
                        title="Click for print friendly version">Print Article</a>&#x00a0;|&#x00a0;
                    <select name="taportools" onchange="gototaporware()">
                        <option>Taporware Tools</option>
                        <option value="listword">List Words</option>
                        <option value="findtext">Find Text</option>
                        <option value="colloc">Collocation</option>
                    </select>
                </p>
            </form>
            <!--            <xsl:call-template name="taportool"/> -->
        </div>
    </xsl:template>
    
</xsl:stylesheet>
