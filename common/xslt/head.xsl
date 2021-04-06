<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="context"/>
    <xsl:template name="head">
        <xsl:param name="title"/>
        <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8"/>         
            <title>
                <xsl:value-of select="concat('DHQ: Digital Humanities Quarterly: ',$title)"/>
            </title>
          <link rel="stylesheet" type="text/css" href="/{$context}/common/css/dhq.css"/>
          <link rel="stylesheet" type="text/css" media="screen"  href="/{$context}/common/css/dhq_screen.css"/>
          <link rel="stylesheet" type="text/css" media="print" href="/{$context}/common/css/dhq_print.css"/>
          <link rel="alternate" type="application/atom+xml"  href="/{$context}/feed/news.xml"/>
          <link rel="shortcut icon" href="/{$context}/common/images/favicon.ico"/>
          <script type="text/javascript" src="/{$context}/common/js/javascriptLibrary.js">
            <xsl:comment> serialize </xsl:comment>
          </script>
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

          <xsl:comment>WTF?</xsl:comment>
            <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"><xsl:comment>Gimme some comment!</xsl:comment></script>
            <script>
                <!-- The predefined skipHtmlTags array lists the names of the tags whose contents should not be processed by MathJaX (other than to look for ignore/process classes as listed below). You can add to (or remove from) this list to prevent MathJax from processing mathematics in specific contexts. In the example below, `code` and `pre` are **removed** from the skipHtmlTags array. See http://docs.mathjax.org/en/latest/options/document.html . -->
                MathJax = {
                    options: {
                        skipHtmlTags: {'[-]': ['code', 'pre']}
                    }
                };
            </script>
            <script id="MathJax-script" async=""
                src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"><xsl:comment>Gimme some comment!</xsl:comment>
            </script>     
<!-- <script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-MML-AM_CHTML' async="async"><xsl:comment>Gimme some comment!</xsl:comment></script> -->
          
         <!-- <xsl:comment>Newstuff</xsl:comment>
          <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"><xsl:comment> serialize </xsl:comment></script>
          <script id="MathJax-script" async="async" src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"><xsl:comment> serialize </xsl:comment>
          </script>
          <xsl:comment>End newstuff</xsl:comment>-->
          <!-- prism syntax highligher -->
            <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/default.min.css" /> -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/github.min.css" />
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/highlight.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
                
            
          
<script src="https://code.jquery.com/jquery-3.4.0.min.js" integrity="sha256-BJeo0qm959uMBGb65z40ejJYGSgR7REI4+CW1fNKwOg=" crossorigin="anonymous"><xsl:comment>Gimme some comment!</xsl:comment></script>
            <xsl:call-template name="customHead"/> 
            
            
        </head>
    </xsl:template>
    
    <!-- customHead template (below) may be overridden in article-specific XSLT (in articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include additional stuff in the HTML <head>. See 000151. -->
    <xsl:template name="customHead"/> 
</xsl:stylesheet>
