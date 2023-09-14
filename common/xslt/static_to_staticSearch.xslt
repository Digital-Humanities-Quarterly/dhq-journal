<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
  exclude-result-prefixes="#all"
  version="3.0">
  <!--
    This was my 1st crack at preparing a DHQ article HTML file to be served by
    the UVic Endings Project Static Search system.
    (See, e.g. https://endings.uvic.ca/staticSearch/docs/howDoIUseIt.html.)
    INPUT: A single HTML file from the generated static-site
    2nd INPUT: The file at the same path with the same name but ends in ".xml"
    OUTPUT: A copy of the input HTML with extra metadata inserted.
  -->
  <!--
    E.g.:
    $ cd /path/to/dhq-journal/
    $ time ant -lib common/lib generateSite
    $ cd ../dhq-static/dhq/vol/
    $ time rm ./*/*/*/*_new.html
      ; for f in ./*/*/*/*.html
      ; do n="$(dirname $f)/$(basename $f .html)_new.html"
      ; echo "=========$f → $n:"
      ; rm $n ; saxon.bash ~/Documents/dhq-journal/common/xslt/static_to_staticSearch.xslt $f > $n
      ; done
    Although this is a pretty slow way to do it, as it means spinning up the java VM over 660 times.
    Thus I am about to re-write this to read all "[0-9].html" files in the input directory at once
    (and their corresponding ".xml" files) and write output to a "_uvepss.html" or some such file.
  -->
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="src_input_fn" select="replace( base-uri(/),'\.html$','.xml')"/>
  <xsl:variable name="src" select="document($src_input_fn)" as="document-node()"/>
  
  <xsl:template match="/">
    <xsl:text>&#x0A;</xsl:text>
    <xsl:comment expand-text="yes"> generated {current-dateTime()} by {static-base-uri()} </xsl:comment>
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <xsl:template match="html:meta">
    <xsl:copy-of select="."/>
    <meta name="article type" class="staticSearch_desc" content="{$src/*/tei:teiHeader//dhq:articleType}"/>
    <meta name="date of publication" class="staticSearch_date" content="{$src/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date/@when}"/>
    <meta name="volume" class="staticSearch_num" content="{$src/*/tei:teiHeader//tei:idno[@type eq 'volume']}"/>
    <meta name="issue"  class="staticSearch_num" content="{$src/*/tei:teiHeader//tei:idno[@type eq 'issue']}"/>
  </xsl:template>

</xsl:stylesheet>
