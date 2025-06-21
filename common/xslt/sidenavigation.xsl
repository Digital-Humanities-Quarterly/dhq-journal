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
      2025-06, SDB: Lots of tweaks to make more readable, no changes to output.
      2024-07, AMC: Refactored, and replaced links to "/dhq/" with links relative
                    to the home directory.
  -->
  
  <xsl:param name="staticPublishingPathPrefix" select="'../../toc/'" as="xs:string"/>
  <xsl:variable name="tocFile" select="$staticPublishingPathPrefix||'toc.xml'" as="xs:string"/>
  <xsl:param name="context"/>
  <!-- The relative path from the webpage to the DHQ home directory. The path must not end with a 
       slash. This value is used by this and other stylesheets to construct links relative, if not 
       directly from the current page, then from the DHQ home directory. Because this stylesheet is used for 
       pages throughout DHQ, the value of $path_to_home should be provided by an stylesheet which imports 
       this one. -->
  <xsl:param name="path_to_home" select="''" as="xs:string"/>
  
  <xsl:template name="sidenavigation">
    <xsl:variable name="tocJournals" select="doc( $tocFile )//journal" as="element(journal)+"/>
    <!-- sidenavigation -->
    <div id="leftsidenav">
      <span>Current Issue<br/></span>
      <ul>
        <li>
	  <!-- There must be one and only one <journal> in the TOC with a @current attribute. -->
          <xsl:variable name="currentIssue" select="$tocJournals[@current]" as="element(journal)"/>
          <xsl:variable name="vol" select="$currentIssue/@vol" as="xs:string"/>
          <xsl:variable name="issue" select="$currentIssue/@issue" as="xs:string"/>
          <a href="{$path_to_home}/vol/{$vol}/{$issue}/index.html">
	    <xsl:sequence select="$currentIssue/title!normalize-space(.)||': '||$vol||'.'||$issue"/>
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
  
  
  
  <xsl:template name="sitetitle">
    <div id="printSiteTitle">DHQ: Digital Humanities Quarterly</div>
  </xsl:template>
  
</xsl:stylesheet>
