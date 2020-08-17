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
        <div id="galleria" style="margin-left:auto; margin-right:auto;">
            <xsl:for-each select=".//tei:figure">
                <img>
                    <xsl:attribute name="src">
                       <!-- <xsl:value-of select="concat('resources/images/slides/',substring-after(tei:graphic/@url,'resources/images/'))"/>-->
                      <xsl:value-of select="tei:graphic/@url"/>
                    </xsl:attribute>
                  <!--
                    <xsl:attribute name="data-big">
                        <xsl:value-of select="concat('resources/images/originals/',substring-after(tei:graphic/@url,'resources/images/'))"/>
                    </xsl:attribute>
                    -->
                    <xsl:attribute name="data-title">
                        <xsl:value-of select="normalize-space(tei:head)"/>
                    </xsl:attribute>
                </img>
            </xsl:for-each>
            
                
        </div>
        <p style="margin-left:auto; margin-right:auto; width:450px;border: 1px solid black;
            margin-bottom: 4em;
            background-color: #d5dfe9;
            font-size: .9em;
            padding: 1em 2em;">Download comic as <a href="{concat('resources/pdf/',normalize-space(//tei:idno[@type = 'DHQarticle-id']),'.pdf')}">PDF</a> or <a href="{concat('resources/cbz/',normalize-space(//tei:idno[@type = 'DHQarticle-id']),'.cbz')}">CBZ</a>.
        </p>
    </xsl:template>
    
    <xsl:template name="customHead">
        <xsl:call-template name="galleriaHeadHooks"/>
    </xsl:template>
    
    <xsl:template name="galleriaHeadHooks">
        <!-- load jQuery -->
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
        
        <!-- load Galleria -->
        <script src="/dhq/common/galleria/galleria-1.5.7.min.js"><xsl:comment>Gimme some comment!</xsl:comment></script>
        
        <style>
            #galleria{ width: 950px; height: 1200px; background: #000; padding:20px; border:2px solid #D5DFE9; }
        </style> 
        
    </xsl:template>
    
    
    <xsl:template name="customBody">
        <xsl:call-template name="galleriaBodyHooks"/>
    </xsl:template>
    
    <xsl:template name="galleriaBodyHooks">
        <script>
            
            // Load the Azur theme
            Galleria.loadTheme('/dhq/common/galleria/themes/azur/galleria.azur.min.js');
            
            // Initialize Galleria
            Galleria.run('#galleria', { trueFullscreen: true});
            
        </script>
    </xsl:template>

    
</xsl:stylesheet>
