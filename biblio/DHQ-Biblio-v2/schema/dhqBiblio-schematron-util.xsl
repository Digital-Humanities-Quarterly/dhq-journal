<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:biblio="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- dhq:flatten-string returns an element's value with the following modifications:
         - punctuation is stripped
         - space is normalized
         - value is cast to lower case -->
   <xsl:function name="biblio:flatten-string" as="xs:string">
    <xsl:param name="e" as="element()"/>
    <xsl:variable name="no-extra-ws" select="normalize-space($e)"/>
    <xsl:variable name="no-punctuation" select="replace($no-extra-ws,'\p{P}','')"/>
    <xsl:sequence select="lower-case($no-punctuation)"/>
  </xsl:function>
  
   <xsl:function name="biblio:report-entries" as="xs:string">
    <xsl:param name="e" as="element()*"/>
    <xsl:variable name="locations" as="xs:string*">
      <xsl:for-each-group select="$e" group-by="root()/document-uri(.)">
        <xsl:value-of>
          <xsl:value-of select="replace(current-grouping-key(),'.*/','')"/>
          <xsl:text> (</xsl:text>
          <xsl:value-of select="current-group()/@ID" separator=", "/>
          <xsl:text>)</xsl:text>
        </xsl:value-of>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:sequence select="biblio:emit-sequence($locations,'and')"/>
  </xsl:function>
  
  <!-- dhq:emit-sequence emits a sequence of strings, punctuated with a conjunction
    dhq:emit-sequence(('a','b'),'or')      => "'a' or 'b'"
    dhq:emit-sequence(('a','b','c'),'or')  => "'a', 'b' or 'c'"
    dhq:emit-sequence(('a','b','c'),'and') => "'a', 'b' and 'c'" -->
  
   <xsl:function name="biblio:emit-sequence" as="xs:string">
    <xsl:param name="strings" as="xs:string*"/>
    <xsl:param name="conjunction" as="xs:string"/>
    <xsl:value-of>
      <xsl:for-each select="$strings">
        <xsl:choose>
          <xsl:when test="position() eq 1"/>
          <xsl:when test="position() eq last()">
            <xsl:value-of select="concat(' ',$conjunction,' ')"/>
          </xsl:when>
          <xsl:when test="position() gt 1">, </xsl:when>
        </xsl:choose>
        <!--<xsl:text>&quot;</xsl:text>-->
        <xsl:value-of select="."/>
        <!--<xsl:text>&quot;</xsl:text>-->
      </xsl:for-each>
    </xsl:value-of>
  </xsl:function>
  
</xsl:stylesheet>