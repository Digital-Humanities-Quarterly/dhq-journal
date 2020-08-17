<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/1999/xhtml" version="1.0">     
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <!--    <xsl:import href="banner.xsl"/>-->
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="bios.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <!-- New code added for templating idea -->
    <!--Parameter from sitemap -->
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:param name="vol"/>
    <xsl:param name="issue"/>
    <xsl:template match="/">
        
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="'Author Biographies'"/>
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
                        <xsl:call-template name="index_main_body">
                            <xsl:with-param name="vol" select="$vol"/>
                            <xsl:with-param name="issue" select="$issue"/>
                        </xsl:call-template>
                        
                        
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
