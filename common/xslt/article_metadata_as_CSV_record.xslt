<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  version="4.0">

  <!--
      This routine reads in a single DHQ article and writes out a
      single CSV-record of metadata intended for DOI ingestion.

      Any field that contains a straight double quotation mark or a
      space character or is empty is surrounded by double straight
      quotation marks (U+0022). And, per my understanding of CSV, a
      double quotation mark within a field is represent by two double
      straight quotation marks in a row.

      There are two fields for the title and two for the abstract. In
      each case the first field is the title or abstract in the
      primary language of the article. In the vast majority of cases
      this is English, but for some it is not. The second field is the
      same in English (and thus is often a useless duplicate), unless
      for some bizarre reason there is no title or abstract in
      English, in which case it is a useless duplicate of the title or
      abstract in the primary language.

      Note: there is NO implicit claim here that this is the best data
      format or that this code is the best way to get this data format
      (it is not). I was asked to perform a particular task and did so
      quickly. It is being checked-in just in the small chance it
      needs to be re-run, and as an example of how one might perform
      this kind of task in general, not as a best practices example.

      To use this program to create a CSV file for (for example) all
      articles listed in the TOC *except* those in the "editorial"
      section, try something like:
      $ mkdir /tmp/ARTs/ /tmp/DHQ_DOI_meta/
      $ saxon -s:toc/toc.xml -xsl:common/xslt/articles_from_TOC.xslt -o:/tmp/DHQarts.list
      $ cd articles ; cp -p $(cat /tmp/DHQarts.list | sort | uniq) /tmp/ARTs/
      $ saxon -s:/tmp/ARTs/ -xsl:common/xslt/article_metadata_as_CSV_record.xslt -o:/tmp/DHQ_DOI_meta/
      $ cat /tmp/DHQ_DOI_meta/* > /tmp/DHQ_meta.csv
      Note that the `cat /tmp/DHQarts.list | sort | uniq` goes through
      the `uniq` cmd to avoid copying a file that has already been
      copied over. I have no idea whether it is more efficient to
      de-duplicate the list or to use the list raw and copy a couple
      of files unnecessarily. You could certainly use just `$(cat
      DHQarts.list)`.
   -->
  <!-- 
      Written 2026-03 by Syd Bauman for Digital Humanities Quarterly.
      🄯 2026 Syd Bauman, available under whatever license DHQ deems.
  -->
  
  <xsl:output method="text"/>

  <!--
      Function dhq:make_CSV_field( $str as xs:string )
      Given the one and only parameter $str, return a CSV field with
      $str as its value, followed by a comma.
  -->
  <xsl:function name="dhq:make_CSV_field" as="xs:string">
    <xsl:param name="str" as="xs:string?"/>
    <!-- Normalize spaces and escape double straight quote mark characters: -->
    <xsl:variable name="field" select="$str => normalize-space() => replace('&quot;','&quot;&quot;')"/>
    <xsl:choose>
      <!-- IF our field is empty OR it contains a space OR it contains a double straight quote mark-->
      <xsl:when test="$field eq ''  or  contains( $field, ' ')  or  contains( $field, '&quot;')">
        <!-- THEN surround it with double straight quotation marks AND append a comma -->
        <xsl:value-of select="'&quot;'||$field||'&quot;,'"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- ELSE just append a comma. -->
        <xsl:value-of select="$field||','"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="/">
    <!-- Process the input article’s <teiHeader> element -->
    <xsl:apply-templates select="/*/teiHeader"/>
  </xsl:template>
  
  <xsl:template match="/*/teiHeader">
    <!-- Remember the element we matched so we can still refer to it after changing the context node. -->
    <xsl:variable name="this_header" select="." as="element(teiHeader)"/>
    <!-- $VOL is the volume number as it occurs, i.e. *with* leading zeroes -->
    <xsl:variable name="VOL" select="fileDesc/publicationStmt/idno[@type eq 'volume']" as="xs:string"/>
    <!-- $vol is the volume number without leading zeroes  -->
    <xsl:variable name="vol" select="format-number( $VOL cast as xs:integer, '##1') cast as xs:string"/>
    <!-- $iss is the issue number (which only 1 digit, so no leading zero problems) -->
    <xsl:variable name="iss" select="fileDesc/publicationStmt/idno[@type eq 'issue']" as="xs:string"/>
    <!-- $aID is the article identifier, which always keeps its leading zeroes -->
    <xsl:variable name="aID" select="fileDesc/publicationStmt/idno[@type eq 'DHQarticle-id']" as="xs:string"/>
    <!-- construct the URL for this article: -->
    <xsl:variable name="URL" as="xs:string"
                  select="'https://dhq.digitalhumanities.org/vol/'||$vol||'/'||$iss||'/'||$aID||'/'||$aID||'.html'"/>
    <!--
        Now that we have a few building blocks easily available,
        assemble output record.
    -->
    <!-- 1, title in native language (which may well be English): -->
    <xsl:value-of select="dhq:make_CSV_field( ( fileDesc/titleStmt/title[ not( lang('en') ) ], fileDesc/titleStmt/title[ lang('en') ] )[1] )"/>
    <!-- 2, title in English (unless there is no such title): -->
    <xsl:value-of select="dhq:make_CSV_field( ( fileDesc/titleStmt/title[ lang('en') ], fileDesc/titleStmt/title[ not( lang('en') ) ] )[1] )"/>
    <!-- 3–20, author names: -->
    <xsl:for-each select="1 to 18">
      <xsl:variable name="author_num" select="." as="xs:integer"/>
      <xsl:value-of select="dhq:make_CSV_field( $this_header/fileDesc/titleStmt/dhq:authorInfo[$author_num]/dhq:author_name )"/>
    </xsl:for-each>
    <!-- 21, publication date: -->
    <xsl:value-of select="dhq:make_CSV_field( fileDesc/publicationStmt/date/@when )"/>
    <!-- 22, article ID: -->
    <xsl:value-of select="dhq:make_CSV_field( $aID )"/>
    <!-- 23, volume number (with leading zeroes): -->
    <xsl:value-of select="dhq:make_CSV_field( $VOL )"/>
    <!-- 24, issue number: -->
    <xsl:value-of select="dhq:make_CSV_field( $iss )"/>
    <!-- 25, URL to article (which uses volume number without leading zeroes): -->
    <xsl:value-of select="dhq:make_CSV_field( $URL )"/>
    <!-- 26, abstract in native language (which may well be English): -->
    <xsl:value-of select="dhq:make_CSV_field( ( //dhq:abstract[ not( lang('en') ) ], //dhq:abstract[ lang('en') ] )[1] )"/>
    <!-- 27, abstract in English (unless there is no such abstract): -->
    <xsl:value-of select="dhq:make_CSV_field( ( //dhq:abstract[ lang('en') ], //dhq:abstract[ not( lang('en') ) ] )[1] )"/>
    <!-- 28; remember that the above ended with a comma, so insert a blank field without a comma so we do not have a mis-match: -->
    <xsl:text>""&#x0A;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
