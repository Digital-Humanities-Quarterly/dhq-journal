<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
                xmlns="http://www.w3.org/1999/xhtml" version="3.0" >
  
  <xsl:param name="context"/>

  <xsl:template name="footer">
    <xsl:param name="docurl"/>
    <xsl:param name="baseurl" select="'http://www.digitalhumanities.org/'||$context||'/'"/>
    <xsl:variable name="isTEI" select="exists( /child::tei:* )" as="xs:boolean"/>
    <xsl:variable name="yearPublished" as="xs:string">
      <xsl:choose>
        <!-- All articles have the publication date as <date when=""> in the header. -->
        <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when">
          <xsl:sequence select="year-from-date( /*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when )!string()"/>
        </xsl:when>
        <!-- For the TOC, take the latest year that *something* was published. -->
        <xsl:when test="/toc/journal">
          <xsl:sequence select="//journal/title!normalize-space()[matches(.,'^[0-9]{4}$')] => max()"/>
        </xsl:when>
        <!-- Fallback: use the year that we generated the HTML page. -->
        <xsl:otherwise>
          <xsl:sequence select="year-from-date( current-date() )!string()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- The year for the copyright notice is either the year the
         single article was originally published, or for generated
         pages (like author bios or the about page) a range from
         our first year of publication to the latest year that
         *something* was published. -->
    <xsl:variable name="copyYear" as="xs:string">
      <xsl:choose>
        <xsl:when test="$isTEI">
          <!-- This is a TEI file, so use its year of publication -->
          <xsl:sequence select="$yearPublished"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- This is NOT a TEI file, so use range from 2005 to last published thingy -->
          <xsl:sequence select="'2005–'||$yearPublished"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- The copyright holder for the copyright notice. -->
    <xsl:variable name="copyHolder">
      <xsl:choose>
        <xsl:when test="$isTEI">
          <xsl:variable name="plural" select="if ( /*/tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo[2] ) then 's' else ''"/>
          <xsl:sequence select="'the author'||$plural"/>
        </xsl:when>
        <xsl:otherwise><xsl:sequence select="'DHQ'"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div id="footer"> 
      <div style="float:left; max-width:70%;" xsl:expand-text="yes">
        URL: {$baseurl}{$docurl}
        <br/>Comments:&#x20;
        <a href="mailto:dhqinfo@digitalhumanities.org" class="footer">dhqinfo@digitalhumanities.org</a>
        <br/>Published by:&#x20;
        <a href="http://www.digitalhumanities.org" class="footer">The Alliance of Digital Humanities Organizations</a>
        &#x20;and&#x20;
        <a href="http://www.ach.org" class="footer">The Association for Computers and the Humanities</a>
        <br/>Affiliated with:&#x20;
        <a href="https://academic.oup.com/dsh">Digital Scholarship in the Humanities</a>
        <br/>DHQ has been made possible in part by the&#x20;
        <a href="https://www.neh.gov/">National Endowment for the Humanities</a>.
        <br/>© {$copyYear} {$copyHolder}
        <br/>
        <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">
          <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/80x15.png"/>
        </a>
        <br/>Unless otherwise noted, the DHQ web site and all DHQ published content are published under a
        <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
        Individual articles may carry a more permissive license, as described in the footer for the individual article, and in the article’s metadata.
      </div>
      <img style="max-width:200px;float:right;" src="https://www.neh.gov/sites/default/files/styles/medium/public/2019-08/NEH-Preferred-Seal820.jpg?itok=VyHHX8pd"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
