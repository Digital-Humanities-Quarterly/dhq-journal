<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    expand-text="yes">
    
    <!-- Primary output: a JSON object (map) -->
    <xsl:output method="json" indent="yes"/>
    
    <!--
    Creates a JSON file where:
      key   = article id (e.g., "000802")
      value = "/vol/{vol}/{issue}/{id}/{id}.html"
    Pulls ids from list[@id='articles'] within each <journal vol="..." issue="...">.
  -->
    <xsl:template match="/toc">
        <xsl:result-document href="articles.json" method="json" indent="yes">
            <xsl:sequence select="
                map:merge(
                for $j in journal[@vol and @issue]
                return map:merge(
                for $id in $j//list[@id='articles']/item/@id ! string()
                return map:entry(
                $id,
                '/vol/' || $j/@vol || '/' || $j/@issue || '/' || $id || '/' || $id || '.html'
                )
                )
                )
                "/>
        </xsl:result-document>
        
        <!-- Also return the same map as the principal result (useful if your runner ignores result-document) -->
        <xsl:sequence select="
            map:merge(
            for $j in journal[@vol and @issue]
            return map:merge(
            for $id in $j//list[@id='articles']/item/@id ! string()
            return map:entry(
            $id,
            '/vol/' || $j/@vol || '/' || $j/@issue || '/' || $id || '/' || $id || '.html'
            )
            )
            )
            "/>
    </xsl:template>
    
</xsl:stylesheet>