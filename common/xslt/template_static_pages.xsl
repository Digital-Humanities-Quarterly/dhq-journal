<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xdoc xhtml" version="1.0">
    
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xdoc:doc type="stylesheet">
        <xdoc:author>John A. Walsh</xdoc:author>
        <xdoc:copyright>Copyright 2008 John A. Walsh</xdoc:copyright>
        <xdoc:short>XSLT stylesheet to transform DHQ static pages to XHTML.</xdoc:short>
    </xdoc:doc>
    
    <xsl:param name="fname"/>
    <xsl:param name="fdir"/>
    <xsl:param name="fpath">
      <xsl:if test="$fname and $fdir">
        <xsl:value-of select="concat($fdir,$dir-separator,$fname)"/>
      </xsl:if>
    </xsl:param>
    <!-- The relative path from the webpage to the DHQ home directory. -->
    <xsl:param name="path_to_home" select="'..'"/>
    
    <xsl:template match="/">
        <xsl:param name="basicurl" select="'http://www.digitalhumanities.org/dhq/'"/>
        <html>
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="xhtml:html/xhtml:head/xhtml:title"/>
            </xsl:call-template>
            <body>
                <!-- Call different templates to put the banner, footer, top and side navigation elements -->
                <xsl:call-template name="topnavigation"/>
                <div id="main">
                    <div id="leftsidebar">
                        <xsl:call-template name="sidenavigation"/>
                    </div>
                    <div id="mainContent">
                        <xsl:call-template name="sitetitle"/>
                        <!-- This template will copy the rest of the html document as it is after applying template -->
                        <xsl:call-template name="copy_body_text"/>
                        <xsl:call-template name="footer">
                            <!-- 2023-05-05: Ash commented out the parameters set below, 
                              since footer.xsl doesn't contain them. -->
                            <!--<xsl:with-param name="doclink_html"
                                select="concat($basicurl, 'how_to_get_this.html')"/>
                            <xsl:with-param name="doclink_xml"
                                select="concat($basicurl,'no_xml_for_static_pages.xml')"/>-->
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template name="copy_body_text" match="xhtml:html/xhtml:body">
        <div>
            <xsl:variable name="bodytext">
                <xsl:copy-of select="descendant::xhtml:html/xhtml:body/xhtml:*"/>
            </xsl:variable>
            <xsl:copy-of select="$bodytext"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
