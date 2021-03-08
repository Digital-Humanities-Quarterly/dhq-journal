<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    exclude-result-prefixes="tei dhq cc xdoc" version="1.0">
    
    <xsl:import href="../../../../common/xslt/template_editorial_article.xsl"/>
    
    <xsl:template match="tei:ab[@type = 'imageGallery']">
        <div class="galleria" style="margin-left:auto; margin-right:auto;">
            <xsl:for-each select=".//tei:figure">
                <img>
                    <xsl:attribute name="src">
                        <xsl:value-of select="concat('resources/images/slides/',substring-after(tei:graphic/@url,'resources/images/'))"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-big">
                        <xsl:value-of select="concat('resources/images/originals/',substring-after(tei:graphic/@url,'resources/images/'))"/>
                    </xsl:attribute>
                    <xsl:attribute name="data-title">
                        <xsl:value-of select="normalize-space(tei:head)"/>
                    </xsl:attribute>
                </img>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="customHead">
        <xsl:call-template name="galleriaHeadHooks"/>
    </xsl:template>
    
    <xsl:template name="galleriaHeadHooks">
        <!-- load jQuery -->
        <!-- <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"><xsl:comment>Gimme some comment!</xsl:comment></script> -->
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
        
        <!-- load Galleria -->
        <!-- <script src="/dhq/common/galleria/galleria-1.2.9.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script> -->
        <script src="/dhq/common/galleria/galleria-1.5.7.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
        
        <style>
            #galleria{ width: 800px; height: 500px; background: #000 }
        </style> 
        
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
