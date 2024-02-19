<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    >
    
    <xsl:param name="context"/>
    <xsl:param name="assets-path" select="concat('/',$context,'/')"/>
    <!-- The character used to separate directories in filepaths. This is only used 
      for linking to local CSS and Javascript, so that a preview webpage is styled 
      appropriately on Windows computers. -->
    <xsl:param name="dir-separator" select="'/'"/>
    
    <xsl:template name="head">
        <xsl:param name="title"/>
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
           <!--
          <link rel="stylesheet" type="text/css" href="{$assets-path}common{$dir-separator}css{$dir-separator}dhq.css"/>
                   -->
          <style>
              <xsl:sequence select="unparsed-text('../css/dhq.css')"/>
          </style>
            <!-- old asset link, before embedding. -->
            <!--
          <link rel="stylesheet" type="text/css" media="screen"  href="{$assets-path}common{$dir-separator}css{$dir-separator}dhq_screen.css"/>
          -->
            <style media="screen">
                <xsl:sequence select="unparsed-text('../css/dhq_screen.css')"/>
            </style>
            <!-- old asset link, before embedding. -->
            <!-- 
          <link rel="stylesheet" type="text/css" media="print" href="{$assets-path}common{$dir-separator}css{$dir-separator}dhq_print.css"/>
          -->
            <style media="print">
                <xsl:sequence select="unparsed-text('../css/dhq_print.css')"/>
            </style>
           <!-- what do do about rss? -->
          <link rel="alternate" type="application/atom+xml"  href="{$assets-path}feed{$dir-separator}news.xml"/>

            <!-- old asset link, before embedding. -->
            <!--   
          <link rel="shortcut icon" href="{$assets-path}common{$dir-separator}images{$dir-separator}favicon.ico"/>
          -->
          <xsl:variable name="favicon">
              <xsl:sequence select="unparsed-text('../images/favicon.ico.base64')"/>
          </xsl:variable>        
          <link href="{concat('data:image/x-icon;base64,',$favicon)}" rel="icon" type="image/x-icon" />
            
            <!-- old asset link, before embedding. -->
            <!--             
          <script defer="defer" type="text/javascript" src="{$assets-path}common{$dir-separator}js{$dir-separator}javascriptLibrary.js">
            <xsl:comment> serialize </xsl:comment>
          </script>
          -->
            <script defer="defer" type="text/javascript">
                <xsl:sequence select="unparsed-text('../js/javascriptLibrary.js')"/>
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
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/styles/xcode.min.css" />
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.7.2/highlight.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
                
            
          
<script src="https://code.jquery.com/jquery-3.4.0.min.js" integrity="sha256-BJeo0qm959uMBGb65z40ejJYGSgR7REI4+CW1fNKwOg=" crossorigin="anonymous"><xsl:comment>Gimme some comment!</xsl:comment></script>
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
            </xsl:if>
            
        </head>
    </xsl:template>
    
    <!-- customHead template (below) may be overridden in article-specific XSLT (in articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include additional stuff in the HTML <head>. See 000151. -->

    <xsl:template name="customHead"/> 
</xsl:stylesheet>
