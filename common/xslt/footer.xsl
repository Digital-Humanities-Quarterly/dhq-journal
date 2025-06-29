<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml" version="3.0" >
  
  <xsl:param name="context"/>

  <xsl:template name="footer">
    <xsl:param name="docurl"/>
    <xsl:param name="baseurl" select="'http://www.digitalhumanities.org/'||$context||'/'"/>
    <!--
        For the 2nd part of the URL, examine $docurl — If it ends with
        6_digits-dot-h-t-m-l it is an article, and should have an
        article level directory specified.
    -->
    <xsl:variable name="latterurl">
      <xsl:choose>
        <xsl:when test="matches( $docurl, '/[0-9]{6}\.html$')">
          <!-- Since the article level directory has the same name as
               the 6-digits portion of the article filename, just
               parse it off and duplicate it. -->
          <xsl:sequence select="replace( $docurl, '((/[0-9]{6})\.html)$', '$2$1')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$docurl"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div id="footer"> 
      <div style="float:left; max-width:70%;" xsl:expand-text="yes">
        URL: {$baseurl}{$latterurl}
        <br/>
        Comments:&#x20;
        <a href="mailto:dhqinfo@digitalhumanities.org" class="footer">dhqinfo@digitalhumanities.org</a>
        <br/>
        Published by:&#x20;
        <a href="http://www.digitalhumanities.org" class="footer">The Alliance of Digital Humanities Organizations</a>
        &#x20;and&#x20;
        <a href="http://www.ach.org" class="footer">The Association for Computers and the Humanities</a>
        <br/>
        Affiliated with:&#x20;
        <a href="https://academic.oup.com/dsh">Digital Scholarship in the Humanities</a>
        <br/>
        DHQ has been made possible in part by the&#x20;
        <a href="https://www.neh.gov/">National Endowment for the Humanities</a>.
        <br/>
        Copyright © 2005 -&#x20;
        <script type="text/javascript">
          var currentDate = new Date();
          document.write(currentDate.getFullYear());
        </script>
        <br/>
        <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">
          <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nd/4.0/80x15.png"/>
        </a>
        <br/>
        Unless otherwise noted, the DHQ web site and all DHQ published content are published under a
        <a rel="license" href="http://creativecommons.org/licenses/by-nd/4.0/">Creative Commons Attribution-NoDerivatives 4.0 International License</a>.
        Individual articles may carry a more permissive license, as described in the footer for the individual article, and in the article’s metadata.
      </div>
      <img style="max-width:200px;float:right;" src="https://www.neh.gov/sites/default/files/styles/medium/public/2019-08/NEH-Preferred-Seal820.jpg?itok=VyHHX8pd"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
