<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:param name="doProofing" select="false()" as="xs:boolean"/>
  <!-- The relative path from the webpage to the DHQ home directory. The path must not end with a 
       slash. This value is used by this and other stylesheets to construct links relative, if not 
       directly from the current page, then from the DHQ home directory. Because this stylesheet is used for 
       pages throughout DHQ, the value of $path_to_home should be provided by an stylesheet which imports 
       this one. -->
  <xsl:param name="path_to_home" select="''" as="xs:string"/>
  
  <xsl:template name="topnavigation">
    <div id="top">
      <xsl:call-template name="topbanner"/>
      <xsl:call-template name="topnav"/>
    </div>
  </xsl:template>
  
  <!-- Home will always be index of the current issue- change that path accordingly -->
  <xsl:template name="topnav">
    <div id="topNavigation">
      <!-- 2024-07: Changed @hrefs to use relative links based on the value of $path_to_home -->
      <div id="topnavlinks">
        <span>
          <a href="{$path_to_home}/index.html" class="topnav">home</a>
        </span>
        <span>
          <a href="{$path_to_home}/submissions/index.html" class="topnav">submissions</a>
        </span>
        <span>
          <a href="{$path_to_home}/about/about.html" class="topnav">about dhq</a>
        </span>
        <span>
          <a href="{$path_to_home}/explore/explore.html" class="topnav">explore</a>
        </span>
        <span>
          <a href="{$path_to_home}/people/people.html" class="topnav">dhq people</a>
        </span>
        <span>
          <a href="{$path_to_home}/news/news.html" class="topnav">news</a>
        </span>
        <span id="rightmost">
          <a href="{$path_to_home}/contact/contact.html" class="topnav">contact</a>
        </span>
      </div>
      <div id="searchStuff">
        <form id="searchForm" method="get" action="{$path_to_home}/vol/search.html"
              enctype="application/x-www-form-urlencoded" accept-charset="UTF-8">
          <div id="search">
            <label for="q">Search</label>
            <input id="q" type="text" name="q" value="" placeholder="keyword"/>
            <input id="searchSubmit" type="submit" value="go!"/>
          </div>
        </form>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="topbanner">
    <!-- Added for rotating banner image -->
    <div id="backgroundpic">
      <xsl:variable name="imgFile">
        <xsl:sequence select="unparsed-text('../images/bannerimg/banner29.jpg.base64')"/>
      </xsl:variable>   
      <img alt="" width="100%" height="62px" src="data:image/jpeg;base64,{$imgFile}"/>​
    </div>    
    <div id="banner">
      <!-- If we're generating a proofing copy, add a textual notice of that here. -->
      <xsl:if test="$doProofing">
        <div class="preview-warn">
          <strong>Proofing copy</strong>
        </div>
      </xsl:if>
      <div id="dhqlogo">
        <xsl:variable name="imgFile">
          <xsl:sequence select="unparsed-text('../images/dhqlogo.png.base64')"/>
        </xsl:variable>        
        <img alt="DHQ" src="data:image/png;base64,{$imgFile}"/>
      </div>
      <div id="longdhqlogo">
        <xsl:variable name="imgFile">
          <xsl:sequence select="unparsed-text('../images/dhqlogolonger.png.base64')"/>
        </xsl:variable>        
        <img alt="Digital Humanities Quarterly" src="data:image/png;base64,{$imgFile}"/>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
