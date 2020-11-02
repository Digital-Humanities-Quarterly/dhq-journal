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
        
        
    </xsl:template>
    
    
    <xsl:template name="customBody">
        <xsl:call-template name="galleriaBodyHooks"/>
    </xsl:template>
    
    <xsl:template name="galleriaBodyHooks">
        <script>
           (function() { 
            	// Load the Azur theme
            	Galleria.loadTheme('/dhq/common/galleria/themes/classic/galleria.classic.min.js');
            
            // Initialize Galleria
            	Galleria.run('#galleria', { trueFullscreen: true});
            	//Galleria.run('#galleria');
	   }());
            
        </script>
    </xsl:template>

    
</xsl:stylesheet>
