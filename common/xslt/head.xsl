<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
		exclude-result-prefixes="#all"
                >

  <!-- The relative path from the webpage to the DHQ home directory. The path must not end with a 
       slash. This value is used by this and other stylesheets to construct links relative, if not 
       directly from the current page, then from the DHQ home directory. Because this stylesheet is
       used for pages throughout DHQ, the value of $path_to_home should be provided by any stylesheet
       which imports this one. -->
  <xsl:param name="path_to_home" select="''" as="xs:string"/>
  <xsl:param name="assets-path" select="concat($path_to_home,'/common/')"/>
  <xsl:param name="doProofing" select="false()" as="xs:boolean"/>
  
  <xsl:template name="head">
    <xsl:param name="title" as="xs:string"/>
    <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
      <title>
        <!-- Articles can have more than one <title> in <titleStmt> if more 
             than one language is represented. By default, this stylesheet will 
             take the first one offered. To ensure that the expected title is 
             used, check for multiple <title>s and choose one before calling 
             the "head" template. -->
        <xsl:value-of select="concat('DHQ: Digital Humanities Quarterly: ',$title[1])"/>
      </title>
      <!-- old asset link, before embedding. -->
      <!--link rel="stylesheet" type="text/css" href="{$assets-path}common/css/dhq.css"/-->
      <style type="text/css">
        <xsl:sequence select="unparsed-text('../css/dhq.css')"/>
      </style>
      <!-- old asset link, before embedding. -->
      <!--link rel="stylesheet" type="text/css" media="screen"  href="{$assets-path}common{$dir-separator}css{$dir-separator}dhq_screen.css"/-->
      <style type="text/css" media="screen">
        <xsl:sequence select="unparsed-text('../css/dhq_screen.css')"/>
      </style>
      <!-- old asset link, before embedding. -->
      <!--link rel="stylesheet" type="text/css" media="print" href="{$assets-path}common/css/dhq_print.css"/-->
      <style type="text/css" media="print">
        <xsl:sequence select="unparsed-text('../css/dhq_print.css')"/>
      </style>
      
      <!-- If we're generating a preview version of the site, special CSS rules go here. -->
      <xsl:if test="$doProofing">
        <style>
          <xsl:sequence select="unparsed-text('../css/dhq_proof.css')"/>
        </style>
      </xsl:if>
      
      <!-- what do do about rss? -->
      <link rel="alternate" type="application/atom+xml" href="{$assets-path}/feed/news.xml"/><!-- maybe should be path_to_home? -->

      <!-- old asset link, before embedding. -->
      <!--link rel="shortcut icon" href="{$assets-path}common/images/favicon.ico"/-->
      <xsl:variable name="favicon" as="xs:string">
        <xsl:sequence select="unparsed-text('../images/favicon.ico.base64')"/>
      </xsl:variable>        
      <link href="{concat('data:image/x-icon;base64,',$favicon)}" rel="icon" type="image/x-icon" />
      
      <!-- old asset link, before embedding. -->
      <script defer="defer" type="text/javascript" src="{$assets-path}js/javascriptLibrary.js">
        <xsl:comment> serialize </xsl:comment>
      </script>
      <!-- 2024-07: Embedding the Javascript below into XHTML caused the JS to be serialized so
           browsers couldn't execute it (less-than symbols could not be parsed). -->
      <!--<script defer="defer" type="text/javascript">
          <xsl:sequence select="unparsed-text('../js/javascriptLibrary.js')"/>
          </script>-->
      
      <!-- Google Analytics -->
      <script type="text/javascript">
 var _gaq = _gaq || [];
 _gaq.push(['_setAccount', 'UA-15812721-1']);
 _gaq.push(['_trackPageview']);

 (function() {
   var ga = document.createElement('script'); ga.type =
'text/javascript'; ga.async = true;
   ga.src = ('https:' == document.location.protocol ? 'https://ssl' :
'http://www') + '.google-analytics.com/ga.js';
   var s = document.getElementsByTagName('script')[0];
s.parentNode.insertBefore(ga, s);
 })();
      </script>
      <!-- New google analytics 2023-06-19 -->
      <!-- Google tag (gtag.js) -->
      <script async="async" src="https://www.googletagmanager.com/gtag/js?id=G-F59WMFKXLW"></script>
      <script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-F59WMFKXLW');
      </script>
      
      <xsl:comment>WTF?</xsl:comment>
      <!-- 2024-06-27: Ash removed Polyfill.io CDN as it has been injecting malware. We were 
           using it to provide ECMAScript 6 (ES6) features to older browsers. -->
      
      <script>
        <!-- The predefined skipHtmlTags array lists the names of the tags whose contents
             should not be processed by MathJaX (other than to look for ignore/process
             classes as listed below). You can add to (or remove from) this list to
             prevent MathJax from processing mathematics in specific contexts. In the
             example below, `code` and `pre` are **removed** from the skipHtmlTags array.
             See http://docs.mathjax.org/en/latest/options/document.html . -->
                MathJax = {
                    options: {
                        skipHtmlTags: {'[-]': ['code', 'pre']}
                    }
                };
      </script>
      <script id="MathJax-script" async="" src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
        <xsl:comment>Gimme some comment!</xsl:comment>
      </script>     
      <!--script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-MML-AM_CHTML' async="async"><xsl:comment>Gimme some comment!</xsl:comment></script-->
      
      <!-- <xsl:comment>Newstuff</xsl:comment>
           <script id="MathJax-script" async="async" src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"><xsl:comment> serialize </xsl:comment>
           </script>
           <xsl:comment>End newstuff</xsl:comment>-->
      <!-- prism syntax highligher -->
      <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/default.min.css" /> -->
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/xcode.min.css" />
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/highlight.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
      
      <script src="https://code.jquery.com/jquery-3.4.0.min.js" integrity="sha256-BJeo0qm959uMBGb65z40ejJYGSgR7REI4+CW1fNKwOg=" crossorigin="anonymous"><xsl:comment>Gimme some comment!</xsl:comment></script>
      <!-- Insert any special-case code defined by the caller: -->
      <xsl:call-template name="customHead"/> 
      
      <!--
          Metadata for the Univerity of Victoria Endings Project
          Static Search (UVEPSS). This template seems to be called
          from 15 different places (in 13 different files), but on
          quick review the only contexts it is called from are the
          document node, <tei:TEI>, and <search:results>. I do not
          think that last one will ever occur in the static world.
      -->
      <xsl:variable name="srcHeader" as="element(tei:teiHeader)?" select="/tei:TEI/tei:teiHeader"/>
      <xsl:if test="$srcHeader//dhq:*">
        <meta name="article type" class="staticSearch_desc" content="{$srcHeader//dhq:articleType}"/>
        <meta name="date of publication" class="staticSearch_date" content="{$srcHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when}"/>
        <meta name="volume" class="staticSearch_num" content="{$srcHeader//tei:idno[@type eq 'volume']}"/>
        <meta name="issue"  class="staticSearch_num" content="{$srcHeader//tei:idno[@type eq 'issue']}"/>
        <!--
            As of this writing (2024-02-21) —
            * There are no .xml files with 0 /*/teiHeader/fileDesc/titleStmt/title (of course not, that would be invalid)
            * There are no .xml files with > 2 /*/teiHeader/fileDesc/titleStmt/title
            * There are 49 .xml files that have 2 /*/teiHeader/fileDesc/titleStmt/title (the other 1,355 have 1)
            * All 98 of those <title> elements (2 for each of the 49 files) have both @type and @xml:lang
            * All 98 of those title/@type have value 'article'
            * Of the 1,355 .xml files that have 1 <title>:
              -  1105 type=article
              -   245 [no @type]
              -     4 type=issue
              -     1 type=editorial
            * So I think, in the absence of being given a preferential natural language,
              the only way to get the title is to take the first <title>.
           -->
        <meta name="docTitle" class="staticSearch_docTitle"
              content="{$srcHeader/tei:fileDesc/tei:titleStmt/tei:title[1]!normalize-space(.)}"/>

	<!-- If we are generating a full searchable site, allow highlighting of search results -->
	<xsl:if test="not( $doProofing )">
          <script type="text/javascript" src="{$path_to_home}/vol/uvepss/ssHighlight.js"/>
	</xsl:if>
      </xsl:if>
            
    </head>
  </xsl:template>

  <!--
      customHead template (below) may be overridden in
      the article-specific XSLT (which is the file
      articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include
      additional stuff in the HTML <head>. See 000151.
  -->
  <xsl:template name="customHead"/>
  
</xsl:stylesheet>
