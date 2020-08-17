<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- Get the name from the request paramter -->
    <xsl:param name="name"/>
    <xsl:param name="password"/>
    
    <xsl:template match="authentication">
        <authentication>
            <xsl:apply-templates select="users"/>
        </authentication>
    </xsl:template>
    
    
    <xsl:template match="users">
        <xsl:apply-templates select="user"/>
    </xsl:template>
    
    
    <xsl:template match="user">
        <!-- Compare the name of the user -->
        <xsl:if test="normalize-space(name) = $name">
            <!-- Compare the associated password -->
            <xsl:if test="normalize-space(password) = $password">
                <!-- found, so create the ID -->
                <ID><xsl:value-of select="name"/></ID>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
