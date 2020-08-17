<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0" xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio">
    <!-- tab: &#x0009; -->
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:call-template name="column_labels"/>
      <xsl:apply-templates select="//Artwork|//Book|//BookInSeries|//BookSection|//BlogEntry|//ConferencePaper|//JournalArticle|//Thesis|//VideoGame|//WebSite"/>
    </xsl:template>
    
    <xsl:template name="column_labels">
        <xsl:value-of select="'article id&#x0009;author&#x0009;year&#x0009;title&#x0009;journal/conference/collection&#x0009;abstract&#x0009;reference IDs&#x0009;isDHQ&#x000a;'"/>
    </xsl:template>
       
    
    <xsl:template match="Artwork|Book|BookInSeries|BookSection|BlogEntry|ConferencePaper|JournalArticle|Thesis|VideoGame|WebSite">
        <!-- get id -->
        <xsl:value-of select="concat(normalize-space(@ID),'&#x0009;')"/>
        <!-- get author names -->
        <xsl:apply-templates select="author|editor|creator"/>
        <!-- get publication year -->
        <!-- <xsl:call-template name="get-date"/> -->
        <xsl:call-template name="get-date"/>
        
        <!-- get title -->
        <!-- <xsl:value-of select="concat(normalize-space(title),'&#x0009;')"/> -->
        <xsl:call-template name="get-title"/>
        <!-- get journal/book (for book section) title -->
        <xsl:call-template name="get-container-title"/>      
        
        <!-- get abstract: currently no abstracts -->
        <xsl:value-of select="'&#x0009;'"/>
        <!-- get reference IDs: only for DHQ articles, not yet -->
        <xsl:value-of select="'&#x0009;'"/>
        <!-- isDHQ boolean -->
        <xsl:choose>
            <xsl:when test="normalize-space(journal/title) = 'Digital Humanities Quarterly'">
                <xsl:value-of select="'1'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'0'"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- <xsl:value-of select="'&#x0009;'"/>-->
        <!-- new line -->
        <xsl:value-of select="'&#x000a;'"/>
    </xsl:template>
    
    <!-- <xsl:template name="get-authors" match="//name[role/roleTerm = 'author'] or "> -->
    <xsl:template match="author|editor|creator">
      <xsl:choose>
        <xsl:when test="corporateName">
          <xsl:value-of select="normalize-space(corporateName)"/>
          <xsl:choose>
            <xsl:when test="position() != last()">
              <xsl:value-of select="' | '"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'&#x0009;'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="fullName">
              <xsl:value-of select="normalize-space(fullName)"/>
            </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(familyName)"/>
            <xsl:value-of select="', '"/>
            <xsl:value-of select="normalize-space(givenName)"/>
          </xsl:otherwise>
          </xsl:choose>
            <xsl:choose>
                <xsl:when test="position() != last()">
                    <xsl:value-of select="' | '"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'&#x0009;'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
  
    <!-- named templates. -->
    <xsl:template name="get-title">
      <xsl:choose>
        <xsl:when test="name(.) = 'BookInSeries'">
          <xsl:value-of select="concat(normalize-space(title),' (series: ',normalize-space(series/title),')','&#x0009;')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(normalize-space(title),'&#x0009;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
  
    <xsl:template name="get-container-title">
      <xsl:choose>
        <xsl:when test="name(.) = 'BlogEntry' or name(.) = 'WebSite'">
          <xsl:for-each select="additionalTitle">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() != last()">
              <xsl:value-of select="': '"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="journal/title">
          <xsl:value-of select="normalize-space(journal/title)"/>
        </xsl:when>
        <xsl:when test="name(.) = 'ConferencePaper'">
          <xsl:choose>
            <xsl:when test="publication/title">
              <xsl:value-of select="normalize-space(publication/title)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(conference/title)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="name(.) = 'Thesis'">
          <xsl:value-of select="normalize-space(place)"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- BookSection -->
          <xsl:value-of select="normalize-space(book/title)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="'&#x0009;'"/>
    </xsl:template>
    
    <xsl:template name="get-date">
      <xsl:param name="date">
        <xsl:choose>
          <xsl:when test="name(.) = 'ConferencePaper'">
            <xsl:choose>
              <xsl:when test="publication/date">
                <xsl:value-of select="normalize-space(publication/date)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space(conference/date)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(descendant::date)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:param>
      
      <xsl:choose>
        <xsl:when test="not(descendant::date)">
          <xsl:value-of select="'n.d.&#x0009;'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:analyze-string select="$date" regex='.*?(\d{{4}}).*$'>
            <xsl:matching-substring>
                <xsl:value-of select="concat(regex-group(1),'&#x0009;')"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:value-of select="'--possible bad date--&#x0009;'"/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
          <!-- <xsl:value-of select="concat($date,'&#x0009;')"/> -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
        
    
</xsl:stylesheet>