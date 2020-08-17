<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:m="http://www.mulberrytech.com/xslt/util"
  extension-element-prefixes="m">

<!-- A simple identity transform that writes out the parsed file into a given
     location, flattening its name and removing its DOCTYPE declaration
     in doing so.

     
     <xsl:for-each select="for $x in
        collection('file:///c:/xmlDir?select=*.xml;recurse=yes;on-error=ignore')
        return saxon:discard-document($x)">
     ... Andrew Welch's memory optimization code for Saxon ... -->

  <xsl:param name="source-path" select="'file:/P:/Working/xml-samples'"/>
  <xsl:param name="result-path" select="'file:/P:/Working/query-samples'"/>
  
  <xsl:variable name="input-path" select="concat($source-path,'/')"/>

  <xsl:template match="/" name="start">
    <xsl:choose>
      <xsl:when test="string($source-path) and string($result-path)">
        <xsl:variable name="source-collection" select="concat($source-path,'?select=*.xml;recurse=yes;on-error=ignore')"/>
        <xsl:variable name="collection-files" select="collection($source-collection)"/>
        <xsl:variable name="collection-count" select="count($collection-files)"/>
        <xsl:for-each select="for $x in
            collection($source-collection) return saxon:discard-document($x)">
           <!--<xsl:message>
            <xsl:text>Doing </xsl:text>
            <xsl:value-of select="position()"/>
            <xsl:text> of </xsl:text>
            <xsl:value-of select="$collection-count"/>
          </xsl:message> -->
          
          <xsl:variable name="doctype" select="local-name(*)"/>
          <xsl:variable name="doc-base" select="base-uri(/)"/>
          <!--<xsl:variable name="doc-name" select="m:munge-name($doc-base)"/>-->
          <!--<xsl:variable name="result-name" select="concat($result-path,'/', $doc-name)"/>-->
          <xsl:variable name="result-name" select="concat($result-path,'/samples/sample-',format-number(position(),'000'),'.xml')"/>
          <!--<xsl:message>
            <xsl:text>doc base is </xsl:text>
            <xsl:value-of select="$doc-base"/>
            <xsl:text>&#xA;input path is </xsl:text>
            <xsl:value-of select="$input-path"/>
            <xsl:text>&#xA;doc name is </xsl:text>
            <xsl:value-of select="$doc-name"/>
            <xsl:text>&#xA;relative path is </xsl:text>
            <xsl:value-of select="substring-after($doc-base,$input-path)"/>
            <xsl:text>&#xA;result name is </xsl:text>
            <xsl:value-of select="$result-name"/>
          </xsl:message>-->
          
          <xsl:result-document href="{$result-name}" indent="yes" encoding="US-ASCII">
            <xsl:apply-templates/>
            <!--<xsl:copy-of select="."/>-->
          </xsl:result-document>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Sorry, source and result paths not given properly</xsl:message>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="m:munge-name">
    <!-- Accepts a string containing the Base URI of an input document
         inside the source path. Returns the part of the path after
         the source path, with slashes '/' replaced by an innocuous character -->
    <xsl:param name="input-file"/>
    <xsl:value-of select="substring-after($input-file,$input-path)"/>
  </xsl:function>
  
  <xsl:template match="/*">
    <!--<xsl:copy>
      <xsl:attribute name="file-uri" select="base-uri()"/>
      <xsl:copy-of select="@* | node()"/>
    </xsl:copy>-->
    
    <xsl:processing-instruction name="file-uri">
      <xsl:text> </xsl:text>
      <xsl:value-of select="base-uri()"/>
    </xsl:processing-instruction>
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  
  
  <xsl:template match="@* | processing-instruction() | comment()">
    <xsl:copy-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>
