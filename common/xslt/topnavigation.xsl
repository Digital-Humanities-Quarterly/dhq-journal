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
    <header id="top" class="border-bottom">
      <!-- xsl:call-template name="topbanner"/> -->
      <xsl:call-template name="topnav"/>
    </header>
  </xsl:template>
  
  <!-- Home will always be index of the current issue- change that path accordingly -->
  <xsl:template name="topnav">
    <nav class="navbar navbar-expand-lg bg-body-tertiary">
      <div class="container-fluid">
        <a class="navbar-brand" href="#">DHQ</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <li class="nav-item">
              <a class="nav-link active" aria-current="page" href="{$path_to_home}/index.html">home</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/submissions/index.html">submissions</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/about/about.html">about dhq</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/explore/explore.html">explore</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/people/people.html">dhq people</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/news/news.html">news</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="{$path_to_home}/contact/contact.html">contact</a>
            </li>
            
            <!-- Search toggle -->
            <li class="nav-item">
              <button class="nav-link btn btn-link"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navSearch"
                aria-expanded="false"
                aria-controls="navSearch"
                aria-label="Search">
                🔍
              </button>
            </li>
            
            <!-- Collapsing search -->
            <li class="nav-item collapse" id="navSearch">
              <form class="d-flex ms-lg-2"
                role="search"
                id="searchForm"
                method="get"
                action="{$path_to_home}/vol/search.html"
                accept-charset="UTF-8">
                <input id="q"
                  class="form-control form-control-sm me-2"
                  type="search"
                  name="q"
                  placeholder="keyword"
                  aria-label="Search" />
                  <button class="btn btn-outline-success btn-sm" type="submit">
                    Go
                  </button>
              </form>
            </li>
          </ul>
          <!-- 
          <form class="d-flex" role="search" id="searchForm" method="get" action="{$path_to_home}/vol/search.html"
            enctype="application/x-www-form-urlencoded" accept-charset="UTF-8">
            <div id="search">
              <input id="q" class="form-control me-2" type="text" name="q" value="" placeholder="keyword" aria-label="Search"/>
              <button class="btn btn-outline-success" id="searchSubmit" value="go!" type="submit">Search</button>
            </div>
          </form>
          -->
        </div>
      </div>
    </nav>
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
