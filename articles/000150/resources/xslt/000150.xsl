<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:session="http://apache.org/cocoon/session/1.0"
    exclude-result-prefixes="tei dhq cc xdoc" version="1.0">
    
    <xsl:import href="../../../../common/xslt/template_article.xsl"/>
    
    <xsl:param name="staticPublishingPathPrefix" select="'../../toc/'"/>
    
    <xsl:variable name="articleHtml" select="document('../../000150.html')"/>
    
    <xsl:template name="article_main_body">
        <div class="DHQarticle">
            <xsl:call-template name="pubInfo"/>
            <xsl:call-template name="toolbar_top"/>
            <div id="wrapper">
            <xsl:copy-of select="$articleHtml"/>
            </div>
            <xsl:call-template name="notes"/>
            <xsl:call-template name="bibliography"/>
            <xsl:call-template name="toolbar"/>
        </div>
    </xsl:template>
    
    <xsl:template name="customHead">
        <script type="text/javascript" src="resources/javascript/000150.js"> 
        <xsl:comment> force empty tag </xsl:comment>
        </script>

        <style type="text/css">
            .courier{
            font-family:"Courier New", Courier, monospace;
            }
            .smalltext{
            font-size:.7em;
            }
            .bigtext{
            font-size:3em;
            }
            .centertext{
            text-align:center;
            }
            .graytext{
            color:gray;
            }
            .noitalics{
            font-style:normal;
            }
            .boldtext{
            font-weight:bold;
            }
            .indent{
            margin-left:40px;
            }
            #potencie-img1,#potencie-img2,#active-img,#areo-img2,#vexed-img,#dhq-img2,#anom-img,#ocr-txt,#ocr-txt1{
            display:none;
            cursor:pointer;
            }
        </style>
        
    </xsl:template>
    
    <!-- 2024-07: Ash commented out the template below. There's no need to duplicate the code already 
      present in sidenavigation.xsl (which is imported by template_article.xsl). -->
    <!--<xsl:template name="sidenavigation">
        <xsl:param name="session"><session:getxml context="request" path="/"/></xsl:param>
        <!-\-sidenavigation-\->
        <div id="leftsidenav">
            
            <span>Current Issue<br/>
            </span>
            <ul>
                <li>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:variable name="vol"><xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@vol"/></xsl:variable>
                            <xsl:variable name="issue"><xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@issue"/></xsl:variable>
                            <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/title"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@vol"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@issue"/>
                    </a>
                </li>
            </ul>
            
            <!-\- if there are items in the preview, display the link to the section [CRB] -\->
            <xsl:if test="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@preview]">
                <span>Preview Issue<br/>
                </span>
                <ul>
                    <li>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="'/dhq/preview/index.html'"/>
                            </xsl:attribute>
                            <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@preview]/title"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@preview]/@vol"/>
                            <xsl:text>.</xsl:text>
                            <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@preview]/@issue"/>
                        </a>
                    </li>
                </ul>
            </xsl:if>
            
            <span>Previous Issues<br/>
            </span>
            <ul>
                <xsl:for-each select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[not(@current|@preview|@editorial)]">
                    <xsl:variable name="vol"><xsl:value-of select="@vol"/></xsl:variable>
                    <xsl:variable name="issue"><xsl:value-of select="@issue"/></xsl:variable>
                    <li>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('/dhq/vol/',$vol,'/',$issue,'/index.html')"/>
                            </xsl:attribute>
                            <xsl:value-of select="title"/>
                            <xsl:value-of select="concat(': ',$vol)"/>
                            <xsl:value-of select="concat('.',$issue)"/>
                        </a>
                    </li>
                </xsl:for-each>
                <!-\-<li> <a href="">Preview Next Issue</a></li>
                    <li><a href="">Browse DHQ Archives</a></li>
                    <li> <a href="">Browse by Author</a></li>
                    <li><a href="">Browse by Title</a></li>
                    <li> <a href="">Advanced Search</a></li>-\->
            </ul>
            
            <span>Indexes<br />
            </span>
            <ul>
                <li><a><xsl:attribute name="href">
                    <xsl:value-of select="'/dhq/index/title.html'"/>
                </xsl:attribute> Title</a></li>
                <li><a><xsl:attribute name="href">
                    <xsl:value-of select="'/dhq/index/author.html'"/>
                </xsl:attribute> Author</a></li>
            </ul>
            
            
        </div>
        
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="'/dhq/common/images/lbarrev.png'"/>
            </xsl:attribute>
            <xsl:attribute name="style">
                <xsl:value-of select="'margin-left : 7px;'"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="'sidenavbarimg'"/>
            </xsl:attribute>
        </img>
        
        <!-\- issn announcement etc -\->
        <div id="leftsideID">
            <b>ISSN 1938-4122</b>
            <br/>
        </div>
        
        <div class="leftsidecontent">
            <h3>Announcements</h3>
            <ul>
                <li>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="'/dhq/announcements/index.html#reviewers'"
                        />
                    </xsl:attribute>Call for Reviewers</a>
                </li>
                <li>
                    <a><xsl:attribute name="href">
                        <xsl:value-of
                            select="'/dhq/announcements/index.html#submissions'"/>
                    </xsl:attribute>Call for Submissions</a>
                </li>
            </ul>
        </div>
        <div class="leftsidecontent">
            
            <!-\- AddThis Button BEGIN -\->
            <script type="text/javascript">addthis_pub  = 'dhq';</script>
            <a href="http://www.addthis.com/bookmark.php"
                onmouseover="return addthis_open(this, '', '[URL]', '[TITLE]')"
                onmouseout="addthis_close()" onclick="return addthis_sendto()">
                <img src="http://s9.addthis.com/button1-addthis.gif" width="125" height="16" alt="button1-addthis.gif"/>
            </a>
            <script type="text/javascript" src="http://s7.addthis.com/js/152/addthis_widget.js"><![CDATA[<!-\- Javascript functions -\->]]></script>
            <!-\- AddThis Button END -\->
            
            <!-\- Editorial area with logout button if we have a session variable [CRB] -\->
            <!-\-<br /><br /><span><a href="/dhq/login.html">Editorial Area</a></span>-\->
            
            <xsl:if test="string($session)">
                <form action="/dhq/do-logout" method="post"><p><input type="submit" value="Logout" style="border: 1px solid black;"/></p></form>
            </xsl:if>
        </div>
        
        
    </xsl:template>-->
        
        
    
</xsl:stylesheet>