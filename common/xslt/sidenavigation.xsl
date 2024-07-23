<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <!--
        This stylesheet contains the template "sidenavigation", which generates the 
        sidebar navigation menu. The navbar contains links to every issue in DHQ.
        
        As one of the base DHQ stylesheets, it is imported into other stylesheets 
        which generate full HTML pages.
        
        CHANGES
          2024-07, AMC: Refactored, and replaced links to "/dhq/" with links 
            relative to the home directory.
      -->
    
    <xsl:param name="staticPublishingPathPrefix" select="'../../toc/'"/>
    <xsl:param name="context"/>
    <!-- The relative path from the webpage to the DHQ home directory. The path must 
      not end with a slash. -->
    <xsl:param name="path_to_home" as="xs:string"/>
    
    
    <xsl:template name="sidenavigation">
        <xsl:variable name="tocJournals" 
          select="doc(concat($staticPublishingPathPrefix,'toc.xml'))//journal"/>
        <!--sidenavigation-->
        <div id="leftsidenav">
            <span>Current Issue<br/>
            </span>
            <ul>
                <li>
                    <xsl:variable name="currentIssue" select="$tocJournals[@current]"/>
                    <xsl:variable name="vol" select="$currentIssue/@vol/data(.)"/>
                    <xsl:variable name="issue" select="$currentIssue/@issue/data(.)"/>
                    <a href="{$path_to_home}/vol/{$vol}/{$issue}/index.html">
                        <xsl:value-of select="$currentIssue/title"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="$vol"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="$issue"/>
                    </a>
                </li>
            </ul>
            
            <!-- if there are items in the preview, display the link to the section [CRB] -->
            <xsl:variable name="previewIssue" select="$tocJournals[@preview]"/>
            <xsl:if test="exists($previewIssue)">
                <span>Preview Issue<br/>
                </span>
                <ul>
                    <li>
                        <a href="{$path_to_home}/preview/index.html">
                            <xsl:value-of select="$previewIssue/title"/>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="$previewIssue/@vol"/>
                            <xsl:text>.</xsl:text>
                            <xsl:value-of select="$previewIssue/@issue"/>
                        </a>
                    </li>
                </ul>
            </xsl:if>
            
            <span>Previous Issues<br/>
            </span>
            <ul>
                <xsl:for-each select="$tocJournals[not(@current|@preview|@editorial)]">
                    <xsl:variable name="vol" select="@vol/data(.)"/>
                    <xsl:variable name="issue" select="@issue/data(.)"/>
                    <li>
                        <a href="{$path_to_home}/vol/{$vol}/{$issue}/index.html">
                            <xsl:value-of select="./title"/>
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
                <li>
                  <a href="{$path_to_home}/index/title.html">Title</a>
                </li>
                <li>
                  <a href="{$path_to_home}/index/author.html">Author</a>
                </li>
            </ul>
            
            
        </div>
        
        <img alt="" style="margin-left : 7px;">
            <xsl:attribute name="src" select="concat($path_to_home,'/common/images/lbarrev.png')"/>
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
                        <xsl:value-of select="concat($path_to_home,'/news/news.html#peer_reviews')"/>
                    </xsl:attribute>Call for Reviewers</a>
                </li>
                <li>
                    <a><xsl:attribute name="href">
                        <xsl:value-of select="concat($path_to_home,'/submissions/index.html#logistics')"/>
                    </xsl:attribute>Call for Submissions</a>
                </li>
            </ul>
        </div>
      <!-- 2024-07, AMC: Removed AddThis button and Editorial area "logout" button. -->
        
    </xsl:template>
    
    <xsl:template name="taportool"> 
        <!-- Div statement remove because the content is now inline -->
        <!--         <div class="leftsidecontent"> -->
        <!--         <div class="toolbar"> -->
        <form name="taporware">
            <select name="taportools" onchange="gototaporware()">
                <option>Taporware Tools</option>
                <option value="listword">List Words</option>
                <option value="findtext">Find Text</option>
                <option value="colloc">Collocation</option>
            </select>
        </form>
        <!--        </div> -->
    </xsl:template>
    
    <xsl:template name="sitetitle">
        <div id="printSiteTitle">DHQ: Digital Humanities Quarterly</div>
    </xsl:template>
    
</xsl:stylesheet>
