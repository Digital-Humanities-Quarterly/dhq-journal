<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="context"/>
    <xsl:template name="footer">
        <xsl:param name="docurl"/>
        <xsl:param name="baseurl" select="concat('http://www.digitalhumanities.org/',$context,'/')"/>
        <div id="footer"> 
            <!--DHQ Preview Web Site: Content in Draft Form. Final version will appear: <a
                href="http://www.digitalhumanities.org/dhq/" class="footer"
                >http://www.digitalhumanities.org/dhq/</a>. <br/> -->URL: <xsl:value-of
                select="concat($baseurl,$docurl)"/><br/>Last updated:
            <script type="text/javascript">
                var monthArray = new initArray("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
                var lastModifiedDate = new Date(document.lastModified);
                var currentDate = new Date();
                document.write(" ",monthArray[(lastModifiedDate.getMonth()+1)]," ");
                document.write(lastModifiedDate.getDate(),", ",(lastModifiedDate.getFullYear()));
            </script>
            <br/> Comments: <a><xsl:attribute name="href">
                <xsl:value-of select="'mailto:dhqinfo@digitalhumanities.org'"/>
            </xsl:attribute><xsl:attribute name="class">
                <xsl:value-of select="'footer'"/>
            </xsl:attribute>dhqinfo@digitalhumanities.org</a><br/> Published by:
            <a><xsl:attribute name="href">
                <xsl:value-of select="'http://www.digitalhumanities.org'"/>
            </xsl:attribute><xsl:attribute name="class">
                <xsl:value-of select="'footer'"/>
            </xsl:attribute>The Alliance of Digital Humanities Organizations</a><br />Affiliated with: <a>
                <xsl:attribute name="href"><xsl:value-of select="'http://llc.oxfordjournals.org/'"/></xsl:attribute><xsl:value-of select="'Literary and Linguistic Computing'"/></a>
            <br/> Copyright 2005 - <script type="text/javascript">
                document.write(currentDate.getFullYear());</script> <br/> <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
        </div>
        
    </xsl:template>
</xsl:stylesheet>
