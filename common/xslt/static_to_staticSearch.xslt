<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  exclude-result-prefixes="#all"
  version="3.0">
  <!--
    This is my 2nd crack at preparing a DHQ article HTML file to be served by
    the UVic Endings Project Static Search system.
    (See, e.g. https://endings.uvic.ca/staticSearch/docs/howDoIUseIt.html.)
    INPUT file, specified: ignored, except its path is used to determine input directory.
    INPUT directory: a prepared “corpus” of the DHQ articles. For now, all this has to contain
                     is a bunch of 0[0-9]{5}.html and their corresponding .xml files. No internal
                     directory structure, just a pile of HTML and XML files. Other files are
                     allowed, but ignored. Thus something like:
                     $ cd /path/to/dhq-journal/
                     $ time cp -pr dhq/vol/*/*/*/* /tmp/DHQ_tmp_corpus/
                     will do the trick.
    OUTPUT: A copy of each input HTML with extra metadata inserted is placed in a file
            in the same directory with the same name as the input HTML except with
            “_evepss” appended before the “.html” extension.
  -->

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:output method="xhtml" indent="no" html-version="5"/>
  
  <xsl:variable name="input_path" select="base-uri(/) => replace('/[^/]+$','')"/>
  <xsl:variable name="primary_inputs" select="$input_path||'?match=00[0-9]{4}.html;recurse=no;on-error=warning;xinclude=yes;'"/>
  <xsl:variable name="src" select="/"/>
  <xsl:variable name="input_collection" select="collection( $primary_inputs )" as="document-node()+"/>
  
  <xsl:template match="/">
    <xsl:message select="'debug: pi='||$primary_inputs||', which has '||count($input_collection)"/>
    <xsl:apply-templates select="$input_collection/html"/>
  </xsl:template>
  
  <xsl:template match="html">
    <xsl:variable name="myBaseName" select="base-uri(.) => replace('\.html$','')"/>
    <xsl:variable name="src" select="document( $myBaseName||'.xml')" as="document-node()"/>
    <xsl:result-document href="{$myBaseName||'_uvepss.html'}">
      <html>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="node()">
          <xsl:with-param name="src" tunnel="yes" as="element(tei:teiHeader)" select="$src/*/tei:teiHeader"/>
        </xsl:apply-templates> 
      </html>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="html:meta">
    <xsl:param name="src" as="element(tei:teiHeader)" tunnel="yes"/>
    <xsl:copy-of select="."/>
    <meta name="article type" class="staticSearch_desc" content="{$src//dhq:articleType}"/>
    <meta name="date of publication" class="staticSearch_date" content="{$src/tei:fileDesc/tei:publicationStmt/tei:date/@when}"/>
    <meta name="volume" class="staticSearch_num" content="{$src//tei:idno[@type eq 'volume']}"/>
    <meta name="issue"  class="staticSearch_num" content="{$src//tei:idno[@type eq 'issue']}"/>
  </xsl:template>

</xsl:stylesheet>
