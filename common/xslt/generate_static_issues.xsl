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
  
  
 <!--
    PARAMETERS
   -->
  
  <!-- An absolute path to the DHQ repository. -->
  <xsl:param name="repo-dir" as="xs:string">
    <xsl:variable name="thisXsl" select="concat('/',
      dhq:set-filesystem-path(('common', 'xslt', 'generate_static_issues.xsl')),
      '$')"/>
    <!-- Escape any backslashes so a Windows filepath can be processed with regex. -->
    <xsl:variable name="thisXsl" select="replace($thisXsl, '(\\)', '\\$1')"/>
    <xsl:sequence select="replace(static-base-uri(), $thisXsl, '')"/>
  </xsl:param>
  
  <!-- The directory to which the static DHQ site will be saved. -->
  <xsl:param name="static-dir" as="xs:string" required="yes"/>
  
  <!-- The base URL for DHQ. Passed on to the article HTML transformations. -->
  <xsl:param name="context" as="xs:string"/>
  
  <!-- When $do-proofing is toggled on, the articles in the "editorial" space should 
    be included, and the HTML should appear distinct from the regular DHQ site. -->
  <xsl:param name="do-proofing" select="false()" as="xs:boolean"/>
  
  <!-- When $do-proofing AND $do-proofing-full are toggled on, the 
    preview issue and other public issues are not processed. Only the articles in 
    the "editorial" space of the TOC are included. -->
  <xsl:param name="do-proofing-full" select="true()" as="xs:boolean"/>
  
  
 <!--
    GLOBAL VARIABLES
   -->
  
  <!-- Whether to generate the full Ant build file needed to transfer all articles 
    and TOC derivatives, as well as compress the articles' XML. -->
  <xsl:variable name="do-full-build" as="xs:boolean"
    select="not($do-proofing) or ($do-proofing and $do-proofing-full)"/>
  
  <!-- Find any articles that appear in two different issues. These will need to be 
    handled separately in the Ant build file. -->
  <xsl:variable name="duplicated-articles" as="xs:string*">
    <xsl:for-each-group select="//item[@id]" group-by="@id/data(.)">
      <xsl:if test="count( current-group() ) gt 1">
        <xsl:sequence select="current-grouping-key()"/>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:variable>
  
  <!-- The document node of this TOC file is retained here for use in 
    dhq:set-up-issue-transformation(). -->
  <xsl:variable name="toc-source" select="/"/>
  
  <!-- Default settings for the transformation of articles from TEI to HTML. -->
  <xsl:variable name="xsl-map-base" as="map(*)" 
    select="map {
        'stylesheet-location':
          dhq:set-filesystem-path(($repo-dir, 'common', 'xslt', 'template_article.xsl')),
        'cache': true()
      }"/>
  
  
  
 <!--
    DEFAULT PROCESSING TEMPLATES
   -->
  
  <xsl:template match="*" mode="#all">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="@* | text() | comment() | processing-instruction()" mode="#all"/>
  
  
  
 <!--
    TEMPLATES, #default mode
   -->
  
  <xsl:template match="/">
    <xsl:message select="'Base repository path: '||$repo-dir"/>
    <!-- “main” output is an Ant build file for creating article index
         pages, bio pages, and copying each article's assets from the
         repo to the newly created static site. -->
    <xsl:text>&#x0A;</xsl:text>
    <project name="dhq_articles">
      <xsl:comment>
        This is an Ant build file produced by running generate_static_issues.xsl on 
        the DHQ TOC. The build targets defined below are designed to be used ONLY by 
        the main DHQ build file. Please do NOT run any of these targets on their own! </xsl:comment>
      
      <target name="copyArticleResources">
        <!-- Copy all public articles' XML, figures, etc. from the repository to the 
          static directory. -->
        <copy enablemultiplemappings="true">
          <!-- We could use the Ant property ${toDir.static.path}, but since the 
            generated build file will be local to this computer, we can simply use 
            $static-dir without worrying about OS-specific file separators. -->
          <xsl:attribute name="todir" select="$static-dir"/>
          <fileset>
            <xsl:attribute name="dir">${basedir}${file.separator}articles</xsl:attribute>
          </fileset>
          <compositemapper>
            <!-- Generate regex mappers for any article that appears in more than 
              one issue. (As of 2023-06, there is only one: 000109 is included in 
              both 5.3 and 6.2.) We only need to do this if multiple issues will be 
              part of the static output. -->
            <xsl:if test="$do-full-build">
              <xsl:apply-templates select="//item[@id = $duplicated-articles]" mode="dupe-article"/>
            </xsl:if>
            <!-- A majority of articles only appear once throughout DHQ. Resource 
              mappers for these articles can appear inside <firstmatchmapper>. -->
            <firstmatchmapper>
              <xsl:choose>
                <!-- If we're only processing the "editorial" section of the TOC, 
                  apply templates there and only there. -->
                <xsl:when test="not($do-full-build)">
                  <xsl:apply-templates select="//journal[@editorial eq 'true']"/>
                </xsl:when>
                <!-- Run all transformations for all issues and articles. If an 
                  article is known to be duplicated across issues, the file mapper 
                  output is suppressed. -->
                <xsl:otherwise>
                  <xsl:apply-templates/>
                </xsl:otherwise>
              </xsl:choose>
            </firstmatchmapper>
          </compositemapper>
        </copy>
      </target>
      <!-- Also, generate an Ant target for zipping up all non-preview XML articles. 
        We don't need to do this when proofing the editorial articles alone. -->
      <xsl:if test="$do-full-build">
        <xsl:call-template name="make-target-to-compress-xml"/>
      </xsl:if>
    </project>
    <!-- While we're in the TOC, generate indexes of all article titles and all 
      contributors. We don't need to do this when proofing the editorial articles 
      alone. -->
    <xsl:if test="$do-full-build">
      <xsl:call-template name="generate-article-indexes"/>
    </xsl:if>
  </xsl:template>
  
  <!-- The "editorial" section of the TOC is for articles that are being worked on 
    by the DHQ editors and authors. The articles in this section should not be 
    published on the DHQ site, only in a preview copy. -->
  <xsl:template match="journal[@editorial eq 'true']">
    <!-- Proceed with transforming the articles in this section ONLY if $do-proofing 
      is toggled on. -->
    <xsl:if test="$do-proofing">
      <xsl:message select="'Processing editorial section'"/>
      <xsl:variable name="fpath" select="'editorial'"/>
      <!-- Generate index of articles. -->
      <!-- Define the transformation of the TOC into the Internal Preview index. 
        Most of the heavy lifting is done by dhq:set-up-issue-transformation(). -->
      <xsl:variable name="editorial-index-map" as="map(*)"
        select="dhq:set-up-issue-transformation(., 'template_editorial.xsl', $fpath||'/index.html', '..')"/>
      <xsl:variable name="outDir" select="dhq:set-filesystem-path(( $static-dir, 'editorial' ))"/>
      <!-- Generate this issue’s main page using $editorial-index-map -->
      <xsl:result-document href="{$outDir||'/index.html'}">
        <xsl:sequence select="transform( $editorial-index-map )?output"/>
      </xsl:result-document>
      <!-- Generate author biographies. -->
      <xsl:variable name="editorial-bios-map" as="map(*)" 
        select="dhq:set-up-issue-transformation(., 'template_editorial_bios.xsl', $fpath||'/bios.html', '..')"/>
      <!-- Generate the biographies page through two XSL transformations. -->
      <xsl:result-document href="{$outDir||'/bios.html'}">
        <xsl:call-template name="transform-with-sorting">
          <xsl:with-param name="transform-1-map" select="$editorial-bios-map" as="map(*)"/>
          <xsl:with-param name="transform-2-xsl-filename" select="'bios_sort.xsl'"/>
        </xsl:call-template>
      </xsl:result-document>
      <!-- Transform the articles in this section. -->
      <xsl:apply-templates>
        <xsl:with-param name="vol" select="@vol/data(.)" tunnel="yes"/>
        <xsl:with-param name="issue" select="@issue/data(.)" tunnel="yes"/>
        <xsl:with-param name="fpath" select="$fpath" tunnel="yes"/>
        <xsl:with-param name="outDir" select="$outDir" tunnel="yes"/>
        <xsl:with-param name="defaultXslPath" tunnel="yes" 
          select="dhq:set-filesystem-path(( $repo-dir, 'common', 'xslt', 
                                            'template_editorial_article.xsl' ))"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <!-- For each DHQ issue, we first produce an index page and the contributors' 
    biographies page. If this issue is the current one, we also produce the DHQ home 
    page index. Then, the XSLT proceeds to work on each article in the issue. -->
  <xsl:template match="journal[@vol][@issue]">
    <xsl:variable name="fpath" select="string-join( ( 'vol', @vol/data(), @issue/data()), '/' )"/>
    <xsl:variable name="outDir" 
      select="dhq:set-filesystem-path(( $static-dir, 'vol', @vol/data(), @issue/data() ))"/>
    <xsl:message select="'Processing volume '||@vol||', issue '||@issue||' …'"/>
    <!-- Define the transformation of the TOC into the index for this issue. Most of 
      the heavy lifting is done by dhq:set-up-issue-transformation(). -->
    <xsl:variable name="issue-index-map" as="map(*)"
      select="dhq:set-up-issue-transformation(., 'template_toc.xsl', $fpath||'/index.html')"/>
    <!-- Generate this issue’s main page using $issue-index-map -->
    <xsl:result-document href="{$outDir||'/index.html'}">
      <xsl:sequence select="transform( $issue-index-map )?output"/>
    </xsl:result-document>
    <!-- Define the transformation of the TOC into the biographies page for this 
      issue. -->
    <xsl:variable name="issue-bios-map" as="map(*)" 
      select="dhq:set-up-issue-transformation(., 'template_bios.xsl', $fpath||'/bios.html')"/>
    <!-- Generate this issue’s biographies page through two XSL transformations. -->
    <xsl:result-document href="{$outDir||'/bios.html'}">
      <xsl:call-template name="transform-with-sorting">
        <xsl:with-param name="transform-1-map" select="$issue-bios-map" as="map(*)"/>
        <xsl:with-param name="transform-2-xsl-filename" select="'bios_sort.xsl'"/>
      </xsl:call-template>
    </xsl:result-document>
    <xsl:choose>
      <!-- If this is the current issue, run the transformation again for the DHQ home 
        page. The result will be identical to the issue index, but the URL at the 
        bottom will be http://www.digitalhumanities.org/dhq/index.html -->
      <xsl:when test="@current eq 'true'">
        <xsl:variable name="new-param-map" as="map(*)">
          <xsl:variable name="revisedParams" select="map {
              QName( (),'fpath'): 'index.html',
              QName( (),'path_to_home'): '.'
            }"/>
          <xsl:sequence select="map:merge(($revisedParams, $issue-index-map?stylesheet-params))"/>
        </xsl:variable>
        <xsl:variable name="index-index-map" 
          select="map:put( $issue-index-map, 'stylesheet-params', $new-param-map )"/>
        <xsl:result-document href="{$static-dir||'/index.html'}">
          <xsl:sequence select="transform( $index-index-map )?output"/>
        </xsl:result-document>
      </xsl:when>
      <!-- If this is the preview issue, we need copies of the index and bios pages 
        in the "preview" folder. As in the current issue, the pages will be the 
        nearly identical to their counterparts in "vol/". -->
      <xsl:when test="@preview eq 'true'">
        <!-- Create the index page for the "preview" directory. -->
        <xsl:variable name="preview-index-map" as="map(*)"
          select="dhq:set-up-issue-transformation(., 'template_preview.xsl', 'preview/index.html', '..')"/>
        <xsl:result-document href="{$static-dir||'/preview/index.html'}">
          <xsl:sequence select="transform( $preview-index-map )?output"/>
        </xsl:result-document>
        <!-- Create the contributor bios page for the "preview" directory. -->
        <xsl:variable name="preview-bios-map" as="map(*)"
          select="dhq:set-up-issue-transformation(., 'template_preview_bios.xsl', 'preview/bios.html', '..')"/>
        <xsl:result-document href="{$static-dir||'/preview/bios.html'}">
          <xsl:call-template name="transform-with-sorting">
            <xsl:with-param name="transform-1-map" select="$preview-bios-map" as="map(*)"/>
            <xsl:with-param name="transform-2-xsl-filename" select="'bios_sort.xsl'"/>
          </xsl:call-template>
        </xsl:result-document>
      </xsl:when>
    </xsl:choose>
    <!-- Proceed to transform the contents of the issue (articles). -->
    <xsl:apply-templates>
      <xsl:with-param name="vol" select="@vol/data(.)" tunnel="yes"/>
      <xsl:with-param name="issue" select="@issue/data(.)" tunnel="yes"/>
      <xsl:with-param name="fpath" select="$fpath" tunnel="yes"/>
      <xsl:with-param name="outDir" select="$outDir" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- An article listed for an issue is transformed into HTML. Then, an Ant file 
    mapper entry is created, so that this article's XML and other resources can be 
    copied to the static directory later. -->
  <xsl:template match="journal//item[@id]">
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
        <!-- Check for older versions of this article. These should also be 
          transformed into XHTML. -->
        <xsl:variable name="previousVersion" 
          select="doc($srcPath)//dhq:revisionNote/@previous/data(.)"/>
        <!-- TODO: what happens when there's more than one previous version? -->
        <xsl:if test="count($previousVersion) eq 1">
          <xsl:variable name="prevDoc" 
            select="concat($srcDir,'/',$previousVersion,
              if ( ends-with($previousVersion,'.xml') ) then () else '.xml' )"/>
          <xsl:choose>
            <xsl:when test="doc-available($prevDoc)">
              <xsl:call-template name="transform-article">
                <xsl:with-param name="articleId" select="$articleId"/>
                <xsl:with-param name="srcDir" select="$srcDir"/>
                <xsl:with-param name="srcPath" select="$prevDoc"/>
                <xsl:with-param name="outDir" select="$outArticleDir"/>
                <xsl:with-param name="outFile" select="concat($previousVersion,'.html')"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message 
                select="concat('Could not find previous version of article at ',$prevDoc)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
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
  
  
 <!--
    TEMPLATES, dupe-article mode
   -->
  
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
  
  
  
 <!--
    NAMED TEMPLATES
   -->
  
  <!-- Generate the indexes of all article titles and all contributors. Each index 
    is processed in two steps: First, the TOC is transformed with a special 
    stylesheet. Then, another stylesheet sorts all of the indexed entries. -->
  <xsl:template name="generate-article-indexes">
    <!-- Generate the index of all articles by title. -->
    <xsl:variable name="titles-index-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'source-node'" select="$toc-source"/>
        <xsl:sequence select="dhq:stylesheet-path-entry('title_index.xsl')"/>
        <xsl:map-entry key="'stylesheet-params'">
          <xsl:map>
            <xsl:map-entry key="QName( (),'fpath')" select="'index/title.html'"/>
            <xsl:map-entry key="QName( (),'context')" select="$context"/>
            <xsl:map-entry key="QName( (),'doProofing')" select="$do-proofing"/>
            <xsl:map-entry key="QName( (),'path_to_home')" select="'..'"/>
          </xsl:map>
        </xsl:map-entry>
      </xsl:map>
    </xsl:variable>
    <xsl:result-document href="{$static-dir||'/index/title.html'}">
      <xsl:call-template name="transform-with-sorting">
        <xsl:with-param name="transform-1-map" select="$titles-index-map" as="map(*)"/>
        <xsl:with-param name="transform-2-xsl-filename" select="'title_sort.xsl'"/>
      </xsl:call-template>
    </xsl:result-document>
    <!-- Generate the index of all DHQ contributors. -->
    <xsl:variable name="authors-index-map" as="map(*)">
      <xsl:map>
        <xsl:map-entry key="'source-node'" select="$toc-source"/>
        <xsl:sequence select="dhq:stylesheet-path-entry('author_index.xsl')"/>
        <xsl:map-entry key="'stylesheet-params'">
          <xsl:map>
            <xsl:map-entry key="QName( (),'fpath')" select="'index/author.html'"/>
            <xsl:map-entry key="QName( (),'context')" select="$context"/>
            <xsl:map-entry key="QName( (),'doProofing')" select="$do-proofing"/>
            <xsl:map-entry key="QName( (),'path_to_home')" select="'..'"/>
          </xsl:map>
        </xsl:map-entry>
      </xsl:map>
    </xsl:variable>
    <xsl:result-document href="{$static-dir||'/index/author.html'}">
      <!--<xsl:call-template name="transform-with-sorting">
        <xsl:with-param name="transform-1-map" select="$authors-index-map" as="map(*)"/>
        <xsl:with-param name="transform-2-xsl-filename" select="'author_sort.xsl'"/>
      </xsl:call-template>-->
      <xsl:sequence select="transform( $authors-index-map )?output"/>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Create an Ant file mapper to copy XML and article assets into the right static directory. -->
  <xsl:template name="make-ant-file-mapper">
    <xsl:param name="article-id" as="xs:string"/>
    <xsl:param name="static-article-dir" as="xs:string"/>
    <xsl:variable name="toVal" select="translate($static-article-dir, '\', '/' )"/>
    <!-- 2023-11-21: DHQ currently serves out article XML from the issue directory, not from the article 
      directory. Since most articles are handled by wrapping <regexpmapper> in <firstmatchmapper>, the 
      rule to place article XML in the issue directory must appear before the generic rule for all other 
      article resources. Duplicate articles will have their XML placed in *both* the issue directory and 
      the article directory.
      
      If DHQ eventually decides to place article XML next to the HTML, delete the <regexpmapper> below. 
      The second file mapper will place the XML in the article directory.
      
      2024-05-28: The "editorial" (internal preview) article XSLT expects the XML to be in the same 
        directory as the HTML, it turns out.
    -->
    <xsl:if test="not(ancestor::journal[@editorial eq 'true'])">
      <regexpmapper handledirsep="true">
        <xsl:attribute name="from" select="'^'||$article-id||'/'||$article-id||'\.xml$'"/>
        <xsl:attribute name="to"   select="replace( $toVal, concat('^', $static-dir, '/' ), '' )||'.xml'"/>
      </regexpmapper>
    </xsl:if>
    <!-- Map all (remaining) resources in the article folder to the static article 
      folder. -->
    <regexpmapper handledirsep="true">
      <xsl:attribute name="from" select="'^'||$article-id||'/(.*)$'"/>
      <xsl:attribute name="to"   select="replace( $toVal, concat('^', $static-dir, '/' ), '' )||'/\1'"/>
    </regexpmapper>
  </xsl:template>
  
  <!-- Generate an Ant target for zipping up all non-preview XML articles. -->
  <xsl:template name="make-target-to-compress-xml">
    <target name="zipArticleXml">
      <!-- The articles' build file should inherit the basedir property of the DHQ 
        build file. To make it clearer which folder we're working from, "basedir" 
        is here mapped onto a new property "toDir.git". -->
      <property name="toDir.git">
        <xsl:attribute name="value">${basedir}</xsl:attribute>
      </property>
      <echo>Zipping XML for all articles…</echo>
      <zip>
        <!-- The ZIP file of article XML should be saved within the "data" folder of 
          $static-dir. -->
        <xsl:attribute name="destfile">
          <xsl:value-of select="$static-dir"/>
          <xsl:text>${file.separator}data${file.separator}dhq-xml.zip</xsl:text>
        </xsl:attribute>
        <!-- We're only interested in zipping up articles that:
                1. are relatively stable (read: not in the preview issue or 
                  editorial area), and
                2. are not example articles.
             We also only need one ZIP entry per article, even if the article 
             appears in multiple DHQ issues.
          -->
        <xsl:for-each-group group-by="@id/data(.)" 
            select=".//journal[not(@preview eq 'true') and not(@editorial eq 'true')]
                              //item[@id][not(starts-with(@id, '9'))]">
          <xsl:variable name="id" select="current-grouping-key()"/>
          <!-- We want each XML file to appear under the same directory, without 
            any intermediate folders in the way. To do this, we use Ant's 
            <zipfileset> to start each article in its containing directory, and 
            prefix its file entry with a common folder name "dhq-articles". -->
          <zipfileset>
            <xsl:attribute name="dir">
              <xsl:text>${toDir.git}${file.separator}articles${file.separator}</xsl:text>
              <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:attribute name="includes">
              <xsl:value-of select="$id"/>
              <xsl:text>.xml</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="prefix">
              <xsl:text>dhq-articles</xsl:text>
            </xsl:attribute>
          </zipfileset>
        </xsl:for-each-group>
      </zip>
    </target>
  </xsl:template>
  
  <!-- Transform an article from XML into HTML, and store it in the static site 
    directory $outDir. -->
  <xsl:template name="transform-article">
    <xsl:param name="vol" tunnel="yes"/>
    <xsl:param name="issue" tunnel="yes"/>
    <xsl:param name="articleId" select="@id/data(.)" as="xs:string"/>
    <xsl:param name="srcDir" as="xs:string"/>
    <xsl:param name="srcPath" as="xs:string"/>
    <xsl:param name="fpath" as="xs:string" tunnel="yes"/>
    <xsl:param name="outDir" as="xs:string"/>
    <!-- By default, the transformation results will be saved as $articleID.html 
      Sometimes we need to override this; for example, when dealing with a previous 
      version of an article. -->
    <xsl:param name="outFile" select="concat($articleId,'.html')" as="xs:string"/>
    <xsl:param name="defaultXslPath" as="xs:string?" tunnel="yes"/>
    <!-- Create the map which will define the article's transformation. -->
    <xsl:variable name="xslMap" as="map(*)">
      <!-- Some DHQ articles have alternate XSL stylesheets. If the article folder 
        contains one at 'resources/xslt/ARTICLE-ID.xsl', that stylesheet is used 
        instead of the generic DHQ article stylesheet. Since the special-case 
        XSLTs are only used once, we signal that they shouldn't be cached. -->
      <xsl:variable name="altXslPath" 
        select="dhq:set-filesystem-path( ($srcDir, 'resources', 'xslt', $articleId||'.xsl') )"/>
      <xsl:variable name="useStylesheet" 
        select="if ( doc-available($altXslPath) ) then map {
                    'stylesheet-location': $altXslPath,
                    'cache': false()
                  }
                (: If the default XSLT has been overridden, we'll need a new map. 
                  Here too, no caching should be done. :)
                else if ( exists($defaultXslPath) and doc-available($defaultXslPath) ) then
                  map {
                      'stylesheet-location': $defaultXslPath,
                      'cache': false()
                    }
                (: By default, we can just use the $xsl-map-base defined globally. 
                  Most articles will use this. :)
                else $xsl-map-base"/>
      <xsl:variable name="otherEntries" 
        select="map {
            'source-node': doc($srcPath),
            'stylesheet-params': map {
                QName((),'context'): $context,
                QName((),'vol'): $vol,
                QName((),'issue'): $issue,
                QName((),'fpath'): concat($fpath,'/',$outFile),
                QName((),'doProofing'): $do-proofing
              }
          }"/>
      <xsl:sequence select="map:merge(($useStylesheet, $otherEntries))"/>
    </xsl:variable>
    <!-- Attempt to transform the TEI article into XHTML, and save the result to the 
         output directory. -->
    <xsl:try>
      <xsl:result-document href="{$outDir}/{$outFile}" method="xhtml">
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
  
  <!-- Some DHQ index pages were set up to be transformed in two steps: first, 
    generating the base HTML; then, sorting the index entries. This template 
    streamlines the two transformations. -->
  <xsl:template name="transform-with-sorting">
    <xsl:param name="transform-1-map" as="map(*)"/>
    <xsl:param name="transform-2-xsl-filename" as="xs:string"/>
    <xsl:variable name="transform-2-map" as="map(*)">
      <xsl:map>
        <xsl:sequence select="dhq:stylesheet-path-entry($transform-2-xsl-filename)"/>
        <xsl:map-entry key="'source-node'" select="transform( $transform-1-map )?output"/>
      </xsl:map>
    </xsl:variable>
    <xsl:sequence select="transform( $transform-2-map )?output"/>
  </xsl:template>
  
  
 <!--  FUNCTIONS  -->
  
  <!-- Create a path to some resource on the filesystem. -->
  <xsl:function name="dhq:set-filesystem-path" as="xs:string">
    <xsl:param name="path-parts" as="xs:string*"/>
    <xsl:sequence select="string-join($path-parts, '/')"/>
  </xsl:function>
  
  <!-- Create a map defining a transformation at the issue level. The map is used to 
    produce an issue index page and a list of contributors. -->
  <xsl:function name="dhq:set-up-issue-transformation" as="map(*)">
    <xsl:param name="journal-node" as="node()"/>
    <xsl:param name="xsl-filename" as="xs:string"/>
    <xsl:param name="web-filepath" as="xs:string"/>
    <xsl:sequence 
      select="dhq:set-up-issue-transformation($journal-node, $xsl-filename, $web-filepath, '../../..')"/>
  </xsl:function>
  
  
  <!-- Create a map defining a transformation at the issue level. The map is used to 
    produce an issue index page and a list of contributors. This version allows the 
    relative path to the DHQ home directory to be set. -->
  <xsl:function name="dhq:set-up-issue-transformation" as="map(*)">
    <xsl:param name="journal-node" as="node()"/>
    <xsl:param name="xsl-filename" as="xs:string"/>
    <xsl:param name="web-filepath" as="xs:string"/>
    <xsl:param name="relative-path-home" as="xs:string"/>
    <xsl:map>
      <xsl:map-entry key="'source-node'" select="$toc-source"/>
      <xsl:sequence select="dhq:stylesheet-path-entry($xsl-filename)"/>
      <xsl:map-entry key="'stylesheet-params'">
        <xsl:map>
          <xsl:map-entry key="QName( (),'vol'  )" select="$journal-node/@vol/data()"/>
          <xsl:map-entry key="QName( (),'issue')" select="$journal-node/@issue/data()"/>
          <xsl:map-entry key="QName( (),'fpath')" select="$web-filepath"/>
          <xsl:map-entry key="QName( (),'context')" select="$context"/>
          <xsl:map-entry key="QName( (),'path_to_home')" select="$relative-path-home"/>
          <xsl:map-entry key="QName( (),'doProofing')" select="$do-proofing"/>
          <!-- toc.xsl uses <xsl:message> to list every article in the issue. This 
            is useful but too much noise for the static site generation process, so 
            it's turned off here. -->
          <xsl:map-entry key="QName( (),'do-list-articles')" select="false()"/>
        </xsl:map>
      </xsl:map-entry>
    </xsl:map>
  </xsl:function>
  
  <!-- Generate a map entry with a stylesheet location, for use in fn:transform(). -->
  <xsl:function name="dhq:stylesheet-path-entry" as="map(*)">
    <xsl:param name="fn" as="xs:string"/>
    <xsl:map-entry key="'stylesheet-location'" 
      select="dhq:set-filesystem-path(( $repo-dir, 'common', 'xslt', $fn ))"/>
  </xsl:function>
  
</xsl:stylesheet>
