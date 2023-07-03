<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns=""
  xpath-default-namespace=""
  exclude-result-prefixes="#all"
  version="3.0">
  
<!--
    Use the DHQ table of contents to transform DHQ articles into HTML, and create a 
    mapping between each source directory and its static equivalent.
    
    An article's HTML and TEI files are stored at the expected path in the static 
    site directory. For example, the article 000130 and its associated files are 
    stored at:
        articles/000130/
    And their static site equivalent is stored in this directory structure:
        vol/6/3/000130/
    
    Ash Clark and Syd Bauman
    2023
  -->
  
  <xsl:output encoding="UTF-8" indent="yes" method="xhtml" omit-xml-declaration="no"/>
  
 <!--  PARAMETERS  -->
  
  <!-- The character used to separate directories on this filesystem. -->
  <xsl:param name="dir-separator" select="'/'" as="xs:string"/>
  
  <!-- An absolute path to the DHQ repository. -->
  <xsl:param name="repo-dir" as="xs:string">
    <xsl:variable name="thisXsl" select="concat($dir-separator,
      string-join(('common', 'xslt', 'generate_static_issues.xsl'), $dir-separator),
      '$')"/>
    <xsl:sequence select="replace(static-base-uri(), $thisXsl, '')"/>
  </xsl:param>
  
  <!-- The directory to which the static DHQ site will be saved. -->
  <xsl:param name="static-dir" as="xs:string" required="yes"/>
  
  <!-- The base URL for DHQ. Passed on to the article HTML transformations. -->
  <xsl:param name="context" as="xs:string"/>
  
  
 <!--  GLOBAL VARIABLES  -->
  
  <!-- Default settings for the transformation of articles from TEI to HTML. -->
  <xsl:variable name="xsl-map-base" as="map(*)" 
    select="map {
        'stylesheet-location':
          string-join(($repo-dir, 'common', 'xslt', 'template_article.xsl'), 
            $dir-separator),
        'cache': true()
      }"/>
  
  
 <!--  DEFAULT PROCESSING TEMPLATES  -->
  
  <xsl:template match="*" mode="#all">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="@* | text() | comment() | processing-instruction()" mode="#all"/>
  
  
 <!--  TEMPLATES, #default mode  -->
  
  <xsl:template match="/">
    <!-- “main” output is an Ant build file for creating article index
         pages, bio pages, and copying each article's assets from the
         repo to the newly created static site. -->
    <xsl:text>&#x0A;</xsl:text>
    <project name="dhq_articles">
      <target name="copyArticleResources">
        <copy>
          <!-- Remember: no @xsl:expand-text for following line! -->
          <xsl:attribute name="todir">${toDir.static}</xsl:attribute>
          <fileset>
            <xsl:attribute name="dir">${basedir}${file.separator}articles</xsl:attribute>
          </fileset>
          <firstmatchmapper>
            <xsl:apply-templates/>
          </firstmatchmapper>
        </copy>
      </target>
    </project>
  </xsl:template>
  
  <!-- The editorial section of the TOC is skipped, at least for now. -->
  <xsl:template match="journal[@editorial eq 'true']"/>
  
  <xsl:template match="journal[@vol][@issue]">
    <xsl:variable name="fpath" select="string-join( ( 'vol', @vol/data(), @issue/data()), '/' )"/>
    <xsl:variable name="outDir" select="string-join( ( $static-dir, 'vol', @vol/data(), @issue/data() ), $dir-separator)"/>
    <xsl:variable name="param-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="QName( (),'vol'  )" select="@vol/data()"/>
        <xsl:map-entry key="QName( (),'issue')" select="@issue/data()"/>
        <xsl:map-entry key="QName( (),'fpath')" select="$fpath||'/index.html'"/>
        <xsl:map-entry key="QName( (),'context')" select="$context"/>
      </xsl:map>
    </xsl:variable>
    <xsl:message select="'Processing '||@vol||'.'||@issue||' …'"/>
    <xsl:variable name="issue-index-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'stylesheet-location'"
                       select="string-join( ( $repo-dir, 'common', 'xslt', 'template_toc.xsl' ), $dir-separator )"/>
        <xsl:map-entry key="'source-node'" select="/"/>
        <xsl:map-entry key="'stylesheet-params'" select="$param-map"/>
      </xsl:map>
    </xsl:variable>
    <xsl:variable name="issue-bios-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'stylesheet-location'"
          select="string-join( ( $repo-dir, 'common', 'xslt', 'template_bios.xsl' ), $dir-separator )"/>
        <xsl:map-entry key="'source-node'" select="/"/>
        <xsl:map-entry key="'stylesheet-params'" select="$param-map"/>
      </xsl:map>
    </xsl:variable>
    <xsl:variable name="issue-bios-sort-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'stylesheet-location'"
          select="string-join( ( $repo-dir, 'common', 'xslt', 'bios_sort.xsl' ), $dir-separator )"/>
        <xsl:map-entry key="'source-node'" select="transform( $issue-bios-map )?output"/>
        <xsl:map-entry key="'stylesheet-params'" select="$param-map"/>
      </xsl:map>
    </xsl:variable>
    <!-- Q: does $dir-separator, in result-documents below, need to be '/' instead? -->
    <xsl:result-document href="{$outDir||$dir-separator||'bios.html'}">
      <xsl:sequence select="transform( $issue-bios-sort-map )?output"/>
    </xsl:result-document>
    <xsl:result-document href="{$outDir||$dir-separator||'index.html'}">
      <xsl:sequence select="transform( $issue-index-map )?output"/>
    </xsl:result-document>
    <xsl:if test="@current eq 'true'">
      <xsl:variable name="new-param-map" select="map:put( $param-map, QName( (),'fpath'), 'index.html')"/>
      <xsl:variable name="index-index-map" select="map:put( $issue-index-map, 'stylesheet-params', $new-param-map )"/>
      <!-- xsl:message select="'Debugging '||@vol||'.'||@issue||' with map='||serialize( $index-index-map, map {'method':'json','indent': true() } )"/ -->
      <!-- Q: does $dir-separator, below, need to be '/' instead? -->
      <xsl:result-document href="{$static-dir||$dir-separator||'index.html'}">
        <xsl:sequence select="transform( $index-index-map )?output"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:apply-templates>
      <xsl:with-param name="vol" select="@vol/data(.)" tunnel="yes"/>
      <xsl:with-param name="issue" select="@issue/data(.)" tunnel="yes"/>
      <xsl:with-param name="fpath" select="$fpath" tunnel="yes"/>
      <xsl:with-param name="outDir" select="$outDir" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="journal[@vol][@issue]//item[@id]">
    <xsl:param name="outDir" as="xs:string" tunnel="yes"/>
    <xsl:variable name="articleId" select="@id/data(.)"/>
    <xsl:variable name="srcDir" 
      select="string-join(($repo-dir,'articles',$articleId),$dir-separator)"/>
    <xsl:variable name="srcPath" 
      select="concat($srcDir,$dir-separator,$articleId,'.xml')"/>
    <xsl:variable name="outArticleDir" 
      select="concat($outDir,$dir-separator,$articleId)"/>
    <!-- Make sure that the TEI article exists before proceeding to transform it. -->
    <xsl:choose>
      <xsl:when test="doc-available($srcPath)">
        <xsl:call-template name="transform-article">
          <xsl:with-param name="articleId" select="$articleId"/>
          <xsl:with-param name="srcDir" select="$srcDir"/>
          <xsl:with-param name="srcPath" select="$srcPath"/>
          <xsl:with-param name="outDir" select="$outArticleDir"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('Could not find an article at ',$srcPath)"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Finally, map the source directory and the output directory, for later use by Ant. -->
    <regexpmapper handledirsep="true">
      <xsl:variable  name="to"   select="translate( $outArticleDir, '\', '/' )"/>
      <xsl:attribute name="from" select="'^'||$articleId||'/(.*)$'"/>
      <xsl:attribute name="to"   select="replace( $to, concat('^', $static-dir, '/' ), '' )||'/\1'"/>
    </regexpmapper>
  </xsl:template>
  
  
 <!--  NAMED TEMPLATES  -->
  
  <xsl:template name="transform-article">
    <xsl:param name="vol" tunnel="yes"/>
    <xsl:param name="issue" tunnel="yes"/>
    <xsl:param name="articleId" select="@id/data(.)" as="xs:string"/>
    <xsl:param name="srcDir" as="xs:string"/>
    <xsl:param name="srcPath" as="xs:string"/>
    <xsl:param name="fpath" as="xs:string" tunnel="yes"/>
    <xsl:param name="outDir" as="xs:string"/>
    <!-- Create the map which will define the article's transformation. -->
    <xsl:variable name="xslMap" as="map(*)">
      <!-- Some DHQ articles have alternate XSL stylesheets. If the article folder 
        contains one at 'resources/xslt/ARTICLE-ID.xsl', that stylesheet is used 
        instead of the generic DHQ article stylesheet. Since the special-case 
        XSLTs are only used once, we signal that they shouldn't be cached. -->
      <xsl:variable name="altXslPath" 
        select="string-join(($srcDir, 'resources', 'xslt', concat($articleId,'.xsl')), 
          $dir-separator)"/>
      <xsl:variable name="useStylesheet" 
        select="if ( doc-available($altXslPath) ) then map {
                    'stylesheet-location': $altXslPath,
                    'cache': false()
                  }
                else $xsl-map-base"/>
      <xsl:variable name="otherEntries" 
        select="map {
            'source-node': doc($srcPath),
            'stylesheet-params': map {
                QName((),'context'): $context,
                QName((),'vol'): $vol,
                QName((),'issue'): $issue,
                QName((),'fpath'): concat( $fpath, '/', $articleId, '.html')
              }
          }"/>
      <xsl:sequence select="map:merge(($useStylesheet, $otherEntries))"/>
    </xsl:variable>
    <!-- Copy the TEI source to the output directory. -->
    <xsl:result-document href="{$outDir}/{$articleId}.xml"
       method="xml" indent="false">
      <xsl:sequence select="doc($srcPath)"/>
    </xsl:result-document>
    <!-- Attempt to transform the TEI article into XHTML, and save the result to the 
      output directory. -->
    <xsl:try>
      <!-- Q: does $dir-separator, below, need to be '/' instead? -->
      <xsl:result-document href="{$outDir}{$dir-separator}{$articleId}.html" method="xhtml">
        <xsl:sequence select="transform($xslMap)?output"/>
      </xsl:result-document>
      <!-- If something went wrong, recover but provide information for debugging 
        the error. -->
      <xsl:catch>
        <xsl:message>
          <xsl:text>Something went wrong in transforming article </xsl:text>
          <xsl:value-of select="$articleId"/>
        </xsl:message>
        <xsl:message select="$err:module"/>
        <xsl:message select="$err:description"/>
        <!-- When things go wrong, they're likely to go wrong en masse. Each 
          article's error message is separated with a delimiter. -->
        <xsl:message>******</xsl:message>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  
 <!--  FUNCTIONS  -->
  
</xsl:stylesheet>
