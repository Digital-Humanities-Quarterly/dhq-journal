<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="toc.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <!--Parameter from sitemap -->
    <xsl:param name="context"/>
    <xsl:param name="vol"><xsl:value-of select="toc/journal[@current]/@vol"/></xsl:param>
    <xsl:param name="issue"><xsl:value-of select="toc/journal[@current]/@issue"/></xsl:param>
    <xsl:param name="fpath"/>
    <xsl:param name="staticPublishingPathPrefix"><xsl:value-of select="'../../toc/'"/></xsl:param>
    
    <xsl:template match="/">
        <html>
            <!-- code to retrieve document title from the TOC file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="toc/journal[@vol=$vol and @issue=$issue]/title"/>
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
                        <!-- Rest of the document/article is coverd in this template - this is a call to toc.xsl -->
                        <xsl:call-template name="index_main_body"/>
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
