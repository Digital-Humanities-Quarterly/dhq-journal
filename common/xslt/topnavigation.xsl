<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="context"/>
    <xsl:template name="topnavigation">
        <div id="top">
            <xsl:call-template name="topbanner"/>
            <xsl:call-template name="topnav"/>
        </div>
    </xsl:template>
    <!-- Home will always be index of the current issue- change that path accordingly -->
    <xsl:template name="topnav">
        <div id="topNavigation">
            <div id="topnavlinks">
                <span>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>home</a>
                </span>
                <span>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/submissions/index.html')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>submissions</a>
                </span>
                <span>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/about/about.html')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>about dhq</a>
                </span>
                <span>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/people/people.html')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>dhq people</a>
                </span>
                <span>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/news/news.html')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>news</a>
                </span>
            	
                <span id="rightmost">
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/contact/contact.html')"/>
                    </xsl:attribute><xsl:attribute name="class">
                        <xsl:value-of select="'topnav'"/>
                    </xsl:attribute>contact</a>
                </span>
            </div>
            <div id="search">
                <!-- append '+AND+idno%40type%3ADHQarticle-id' on form action to limit search to articles [CRB] -->
                <form action="/dhq/findIt" method="get" onsubmit="javascript:document.location.href=cleanSearch(this.queryString.value); return false;">
                    <div><input type="text" name="queryString" size="18" /><xsl:text> </xsl:text><input type="submit" value="Search" /></div>
                </form>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="topbanner">
        <!--Added for rotating banner image -->
        <div id="backgroundpic">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="concat('/',$context,'/common/js/pics.js')"/>
                </xsl:attribute>
                <xsl:comment>displays banner image</xsl:comment>
            </script>
        </div>
        
        <div id="banner">
            <div id="dhqlogo">
                <img>
                    <xsl:attribute name="src">
                        <xsl:value-of select="concat('/',$context,'/common/images/dhqlogo.png')"/>
                    </xsl:attribute>
                    <xsl:attribute name="alt">
                        <xsl:value-of select="'DHQ Logo'"/>
                    </xsl:attribute>
                </img>
            </div>
            <div id="longdhqlogo">
                <img>
                    <xsl:attribute name="src">
                        <xsl:value-of select="concat('/',$context,'/common/images/dhqlogolonger.png')"/>
                    </xsl:attribute>
                    <xsl:attribute name="alt">
                        <xsl:value-of select="'Digital Humanities Quarterly Logo'"/>
                    </xsl:attribute>
                </img>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
