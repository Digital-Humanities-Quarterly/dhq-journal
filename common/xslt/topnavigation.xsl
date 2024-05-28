<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:param name="context"/>
    <xsl:param name="doProofing" select="false()" as="xs:boolean"/>
    
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
            <xsl:variable name="imgFile">
                <xsl:sequence select="unparsed-text('../images/bannerimg/banner29.jpg.base64')"/>
            </xsl:variable>   
            <img alt="" width="100%" height="62px" src="{concat('data:image/jpeg;base64,',$imgFile)}"/>​
        </div>
        
        <div id="banner">
            <xsl:if test="$doProofing">
              <div class="preview-warn">
                <strong>Proofing copy</strong>
              </div>
            </xsl:if>
            <div id="dhqlogo">
                <xsl:variable name="imgFile">
                    <xsl:sequence select="unparsed-text('../images/dhqLogo.png.base64')"/>
                </xsl:variable>        
                <img alt="DHQ" src="{concat('data:image/png;base64,',$imgFile)}" />
            </div>
            <div id="longdhqlogo">
                <xsl:variable name="imgFile">
                    <xsl:sequence select="unparsed-text('../images/dhqlogolonger.png.base64')"/>
                </xsl:variable>        
                <img alt="Digital Humanities Quarterly" src="{concat('data:image/png;base64,',$imgFile)}" />
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
