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
    Use the DHQ table of contents to generate many static webpages: individual 
    articles, issue indexes, and issue biography pages. These static pages are 
    produced with fn:transform(), and saved to $static-dir via 
    <xsl:result-document>.
    
    An article's HTML and TEI files are stored at the expected path in the static 
    site directory. For example, the article 000130 and its associated files are 
    stored at:
        articles/000130/
    And their static site equivalent is stored in this directory structure:
        vol/6/3/000130/
    
    In addition, this stylesheet produces an Ant build file which maps between each 
    source article directory and its static equivalent.
    
    Ash Clark and Syd Bauman
    2023
  -->
  
  <xsl:output encoding="UTF-8" indent="yes" method="xhtml" omit-xml-declaration="no"/>
  
 <!--  PARAMETERS  -->
  
  <!-- The character used to separate directories on this filesystem. -->
  <!-- TODO: Figure out if <xsl:result-document>s should always use '/' instead. -->
  <xsl:param name="dir-separator" select="'/'" as="xs:string"/>
  
  <!-- An absolute path to the DHQ repository. -->
  <xsl:param name="repo-dir" as="xs:string">
    <xsl:variable name="thisXsl" select="concat($dir-separator,
      dhq:set-filesystem-path(('common', 'xslt', 'generate_static_issues.xsl')),
      '$')"/>
    <xsl:sequence select="replace(static-base-uri(), $thisXsl, '')"/>
  </xsl:param>
  
  <!-- The directory to which the static DHQ site will be saved. -->
  <xsl:param name="static-dir" as="xs:string" required="yes"/>
  
  <!-- The base URL for DHQ. Passed on to the article HTML transformations. -->
  <xsl:param name="context" as="xs:string"/>
  
  
 <!--  GLOBAL VARIABLES  -->
  
  <!-- Find any articles that appear in two different issues. These will need to be 
    handled separately in the Ant build file. -->
  <xsl:variable name="duplicated-articles" as="xs:string*">
    <xsl:for-each-group select="//item[@id]" group-by="@id/data(.)">
      <xsl:if test="count( current-group() ) gt 1">
        <xsl:sequence select="current-grouping-key()"/>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:variable>
  
  <!-- Default settings for the transformation of articles from TEI to HTML. -->
  <xsl:variable name="xsl-map-base" as="map(*)" 
    select="map {
        'stylesheet-location':
          dhq:set-filesystem-path(($repo-dir, 'common', 'xslt', 'template_article.xsl')),
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
        <copy enablemultiplemappings="true">
          <!-- Remember: no @xsl:expand-text for following line! -->
          <xsl:attribute name="todir">${toDir.static}</xsl:attribute>
          <fileset>
            <xsl:attribute name="dir">${basedir}${file.separator}articles</xsl:attribute>
          </fileset>
          <compositemapper>
            <!-- Generate regex mappers for any article that appears in more than 
              one issue. (As of 2023-06, there is only one: 000109 is included in 
              both 5.3 and 6.2.) -->
            <xsl:apply-templates select="//item[@id = $duplicated-articles]" mode="dupe-article"/>
            <!-- A majority of articles only appear once throughout DHQ. Resource 
              mappers for these articles can appear inside <firstmatchmapper>. -->
            <firstmatchmapper>
              <!-- Run all transformations for all issues and articles. If an 
                article is known to be duplicated across issues, the file mapper 
                output is suppressed. -->
              <xsl:apply-templates/>
            </firstmatchmapper>
          </compositemapper>
        </copy>
      </target>
    </project>
  </xsl:template>
  
  <!-- The editorial section of the TOC is skipped, at least for now. -->
  <xsl:template match="journal[@editorial eq 'true']"/>
  
  <xsl:template match="journal[@vol][@issue]">
    <xsl:variable name="fpath" select="string-join( ( 'vol', @vol/data(), @issue/data()), '/' )"/>
    <xsl:variable name="outDir" 
      select="dhq:set-filesystem-path(( $static-dir, 'vol', @vol/data(), @issue/data() ))"/>
    <xsl:message select="'Processing '||@vol||'.'||@issue||' …'"/>
    <!-- Establish a set of parameters to be handed into XSLT programs we are about to run. -->
    <xsl:variable name="param-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="QName( (),'vol'  )" select="@vol/data()"/>
        <xsl:map-entry key="QName( (),'issue')" select="@issue/data()"/>
        <xsl:map-entry key="QName( (),'fpath')" select="$fpath||'/index.html'"/>
        <xsl:map-entry key="QName( (),'context')" select="$context"/>
      </xsl:map>
    </xsl:variable>
    <!-- A base map which will be used to generate the index-map, bios-map, and bios-sort-map. -->
    <xsl:variable name="issue-template-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'source-node'" select="/"/>
        <xsl:map-entry key="'stylesheet-params'" select="$param-map"/>
      </xsl:map>
    </xsl:variable>
    <!-- The issue-index map is just the template plus a 'stylesheet-location' entry. -->
    <xsl:variable name="issue-index-map" as="map(*)"
      select="map:merge(($issue-template-map, dhq:stylesheet-path-entry('template_toc.xsl')))"/>
    <!-- The issue-bios map is also just the template plus a (different) 'stylesheet-location' entry.  -->
    <xsl:variable name="issue-bios-map" as="map(*)" 
      select="map:merge(($issue-template-map, dhq:stylesheet-path-entry('template_bios.xsl')))"/>
    <!-- The issue-bios-sort map is a bit more complicated, because its source node is the result of
         a transform based on the issue-bios map. -->
    <xsl:variable name="issue-bios-sort-map" as="map(*)">
      <xsl:map>
        <xsl:sequence select="dhq:stylesheet-path-entry('bios_sort.xsl')"/>
        <xsl:map-entry key="'source-node'" select="transform( $issue-bios-map )?output"/>
        <xsl:map-entry key="'stylesheet-params'" select="$param-map"/>
      </xsl:map>
    </xsl:variable>
    <!-- Generate this issue’s bios based on the issue-bios-sort map -->
    <xsl:result-document href="{$outDir||'/'||'bios.html'}">
      <xsl:sequence select="transform( $issue-bios-sort-map )?output"/>
    </xsl:result-document>
    <!-- Generate this issue’s main page on the issue-index map -->
    <xsl:result-document href="{$outDir||'/index.html'}">
      <xsl:sequence select="transform( $issue-index-map )?output"/>
    </xsl:result-document>
    <!-- Q: does $dir-separator, in result-documents above, need to be '/' instead? -->
    <!-- If this is the current issue, run the transformation again for the DHQ home 
      page. The result will be identical to the issue index, but the URL at the 
      bottom will be http://www.digitalhumanities.org/dhq/index.html -->
    <xsl:if test="@current eq 'true'">
      <xsl:variable name="new-param-map" 
        select="map:put( $param-map, QName( (),'fpath'), 'index.html')"/>
      <xsl:variable name="index-index-map" 
        select="map:put( $issue-index-map, 'stylesheet-params', $new-param-map )"/>
      <!-- Q: does $dir-separator, below, need to be '/' instead? -->
      <xsl:result-document href="{$static-dir||'/index.html'}">
        <xsl:sequence select="transform( $index-index-map )?output"/>
      </xsl:result-document>
    </xsl:if>
    <!-- Proceed to transform the contents of the issue (articles). -->
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
      select="dhq:set-filesystem-path(($repo-dir, 'articles', $articleId))"/>
    <xsl:variable name="srcPath" 
      select="dhq:set-filesystem-path(($srcDir, concat($articleId,'.xml')))"/>
    <xsl:variable name="outArticleDir" 
      select="dhq:set-filesystem-path(($outDir, $articleId))"/>
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
    <!-- Finally, map the source directory and the output directory, for later use 
      by Ant. If this article appears in a different issue, nothing happens. -->
    <xsl:if test="not($articleId = $duplicated-articles)">
      <xsl:call-template name="make-ant-file-mapper">
        <xsl:with-param name="article-id" select="$articleId"/>
        <xsl:with-param name="static-article-dir" select="$outArticleDir"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  
 <!--  TEMPLATES, dupe-article mode  -->
  
  <xsl:template match="*" mode="dupe-article"/>
  
  <xsl:template match="item[@id = $duplicated-articles]" mode="dupe-article">
    <xsl:variable name="articleId" select="@id/data(.)"/>
    <xsl:variable name="journEl" select="ancestor::journal[1]"/>
    <xsl:variable name="outDir" 
      select="dhq:set-filesystem-path(($static-dir, 'vol', $journEl/@vol/data(), $journEl/@issue/data(), $articleId))"/>
    <xsl:call-template name="make-ant-file-mapper">
      <xsl:with-param name="article-id" select="$articleId"/>
      <xsl:with-param name="static-article-dir" select="$outDir"/>
    </xsl:call-template>
  </xsl:template>
  
  
 <!--  NAMED TEMPLATES  -->
  
  <xsl:template name="make-ant-file-mapper">
    <xsl:param name="article-id" as="xs:string"/>
    <xsl:param name="static-article-dir" as="xs:string"/>
    <xsl:variable name="toVal" select="translate($static-article-dir, '\', '/' )"/>
    <regexpmapper handledirsep="true">
      <xsl:attribute name="from" select="'^'||$article-id||'/(.*)$'"/>
      <xsl:attribute name="to"   select="replace( $toVal, concat('^', $static-dir, '/' ), '' )||'/\1'"/>
    </regexpmapper>
  </xsl:template>
  
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
    <!-- Attempt to transform the TEI article into XHTML, and save the result to the 
         output directory. -->
    <xsl:try>
      <xsl:result-document href="{$outDir}/{$articleId}.html" method="xhtml">
        <xsl:sequence select="transform($xslMap)?output"/>
      </xsl:result-document>
      <!-- If something went wrong, recover but provide information for debugging 
           the error. -->
      <xsl:catch>
        <xsl:message select="'Something went wrong in transforming article '||$articleId"/>
        <xsl:message select="$err:module"/>
        <xsl:message select="$err:description"/>
        <!-- When things go wrong, they're likely to go wrong en masse. Each 
             article's error message is separated with a delimiter. -->
        <xsl:message>*********</xsl:message>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  
 <!--  FUNCTIONS  -->
  
  <!-- Create a path to some resource on the filesystem, using $dir-separator. -->
  <xsl:function name="dhq:set-filesystem-path" as="xs:string">
    <xsl:param name="path-parts" as="xs:string*"/>
    <xsl:sequence select="string-join($path-parts, $dir-separator)"/>
  </xsl:function>
  
  <!-- Generate a map entry with a stylesheet location, for use in fn:transform(). -->
  <xsl:function name="dhq:stylesheet-path-entry" as="map(*)">
    <xsl:param name="fn" as="xs:string"/>
    <xsl:map-entry key="'stylesheet-location'" 
      select="dhq:set-filesystem-path(( $repo-dir, 'common', 'xslt', $fn ))"/>
  </xsl:function>
  
</xsl:stylesheet>
