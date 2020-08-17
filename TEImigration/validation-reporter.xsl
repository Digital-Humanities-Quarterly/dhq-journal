<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:o2="http://www.oxygenxml.com/ns/report"
  exclude-result-prefixes="xs"
  version="2.0">

<xsl:template match="/">
  <html>
    <style type="text/css">
      div.group { margin: 2ex;
                  padding: 1ex;
                  border: thin solid black }
      p.error { font-family: monospace;
                font-size: 120%;
                margin-top: 0px; margin-bottom: 0px }
      p.frequency { font-family: sans-serif;
                font-size: 80%;
                font-weight: bold;
                margin-top: 0px }
      p.file {font-family: sans-serif;
              font-size: small;
              margin-left: 2ex; margin-top:0ex; margin-bottom: 0ex }
    </style>
    
  <body>
  <xsl:for-each-group select="//o2:incident" group-by="o2:description">
    <xsl:sort select="current-grouping-key()"/>
    <div class="group">
      <xsl:variable name="distribution"
        select="distinct-values(current-group()/o2:systemID)"/>
      <p class="error">
        <xsl:value-of select="current-grouping-key()"/>
      </p>
      <p class="frequency">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="count(current-group())"/>
        <xsl:text> case</xsl:text>
        <xsl:if test="exists(current-group()[2])">s</xsl:if>
        <xsl:text> total in </xsl:text>
        <xsl:value-of select="count($distribution)"/>
        <xsl:text> file</xsl:text>
        <xsl:if test="exists($distribution[2])">s</xsl:if>
        <xsl:text>)</xsl:text>
      </p>
      <div class="files">
        <xsl:for-each-group select="current-group()" group-by="o2:systemID">
          <p class="file">
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="count(current-group())"/>
            <xsl:text> case</xsl:text>
            <xsl:if test="exists(current-group()[2])">s</xsl:if>
            <xsl:text>)</xsl:text>
          </p>
        </xsl:for-each-group>
      </div>
    </div>
  </xsl:for-each-group>
  </body>
  </html>
  
</xsl:template>
  
  <xsl:template match="o2:incident">
    <div class="incident">
      <xsl:apply-templates select="o2:systemID"/>
    </div>
  </xsl:template>
  
  <xsl:template match="o2:incident">
    <p class="{local-name()}incident">
      <xsl:apply-templates select="o2:description, o2:systemID"/>
    </p>
  </xsl:template>
  
  
  <!--<incident>
    <engine>ISO Schematron (XSLT 2.0)</engine>
    <severity>error</severity>
    <description>foreign/@xml:lang is being reported as 'la' (@xml:lang='la') [report]</description>
    <systemID>file:/C:/Users/Wendell/Projects/DigitalHumanities/DHQ/TEImigration/results/000001.xml</systemID>
    <location>
      <start>
        <line>49</line>
        <column>0</column>
      </start>
    </location>
  </incident>-->
  
</xsl:stylesheet>
