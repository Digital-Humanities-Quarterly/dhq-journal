<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    exclude-result-prefixes="tei dhq cc xdoc" version="1.0">
    
    <xsl:import href="../../../../common/xslt/template_editorial_article.xsl"/>
    
    
    <xsl:template name="customHead">
        <xsl:call-template name="citeGameDemoHeadHooks"/>
    </xsl:template>
    
    <xsl:template name="citeGameDemoHeadHooks">
        <script src="resources/cite_game_demo/test-deps/base64-js/base64js.min.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        <script src="resources/cite_game_demo/test-deps/jszip.min.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        <script src="resources/cite_game_demo/test-deps/FileSaver.min.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        
        <script src="resources/cite_game_demo/citestate.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        <script src="resources/cite_game_demo/recorder/recorder-worker.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        <script src="resources/cite_game_demo/head_code.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
        <script src="resources/cite_game_demo/utilities.js" type="text/javascript" charset="utf-8"><xsl:comment>Gimme some comment!</xsl:comment></script>
    </xsl:template>
    
</xsl:stylesheet>
