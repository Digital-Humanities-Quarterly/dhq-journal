<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <xsl:param name="staticPublishingPathPrefix"><xsl:value-of select="'../../toc/'"/></xsl:param>
    <xsl:param name="context"/>
    
    <xsl:template name="sidenavigation">
        <!--sidenavigation-->
        <div id="leftsidenav">
            
            <span>Current Issue<br/>
            </span>
            <ul>
                <li>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:variable name="vol"><xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@vol"/></xsl:variable>
                            <xsl:variable name="issue"><xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@issue"/></xsl:variable>
                            <xsl:value-of select="concat('/',$context,'/vol/',$vol,'/',$issue,'/index.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/title"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@vol"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="document(concat($staticPublishingPathPrefix,'toc.xml'))//journal[@current]/@issue"/>
                    </a>
                </li>
            </ul>
            
            <!-- if there are items in the preview, display the link to the section [CRB] -->
            <xsl:if test="document('../../toc/toc.xml')//journal[@preview]">
                <span>Preview Issue<br/>
                </span>
                <ul>
                    <li>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('/',$context,'/preview/index.html')"/>
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
                                <xsl:value-of select="concat('/',$context,'/vol/',$vol,'/',$issue,'/index.html')"/>
                            </xsl:attribute>
                            <xsl:value-of select="title"/>
                            <xsl:value-of select="concat(': ',$vol)"/>
                            <xsl:value-of select="concat('.',$issue)"/>
                        </a>
                    </li>
                </xsl:for-each>
                <!--<li> <a href="">Preview Next Issue</a></li>
                    <li><a href="">Browse DHQ Archives</a></li>
                    <li> <a href="">Browse by Author</a></li>
                    <li><a href="">Browse by Title</a></li>
                    <li> <a href="">Advanced Search</a></li>-->
            </ul>
            
            <span>Indexes<br />
            </span>
            <ul>
                <li><a><xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/index/title.html')"/>
                </xsl:attribute> Title</a></li>
                <li><a><xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/index/author.html')"/>
                </xsl:attribute> Author</a></li>
            </ul>
            
            
        </div>
        
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="concat('/',$context,'/common/images/lbarrev.png')"/>
            </xsl:attribute>
            <xsl:attribute name="style">
                <xsl:value-of select="'margin-left : 7px;'"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="''"/>
            </xsl:attribute>
        </img>
        
        <!-- issn announcement etc -->
        <div id="leftsideID">
            <b>ISSN 1938-4122</b>
            <br/>
        </div>
        
        <div class="leftsidecontent">
            <h3>Announcements</h3>
            <ul>
                <li>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/news/news.html#peer_reviews')"
                        />
                    </xsl:attribute>Call for Reviewers</a>
                </li>
                <li>
                    <a><xsl:attribute name="href">
                        <xsl:value-of
                            select="concat('/',$context,'/submissions/index.html#logistics')"/>
                    </xsl:attribute>Call for Submissions</a>
                </li>
            </ul>
        </div>
      <!-- 2024-07, AMC: Removed AddThis button and Editorial area "logout" button. -->
        
    </xsl:template>
    
    
    
    <xsl:template name="sitetitle">
        <div id="printSiteTitle">DHQ: Digital Humanities Quarterly</div>
    </xsl:template>
    
</xsl:stylesheet>
