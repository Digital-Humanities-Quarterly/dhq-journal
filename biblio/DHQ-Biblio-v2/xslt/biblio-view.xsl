<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
   xmlns:biblio="http://digitalhumanities.org/dhq/ns/biblio"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="#all">
   
   
<!-- Debug comparison
     Write Biblio proof stylesheet (shows entries from an article,
       calling rendition logi).
       
   -->
   <!-- DHQ Biblio view stylesheet - shows HTML of a DHQ article bibliography,
        with listings from Biblio (linked and potentially linked) -->
   <xsl:import href="xpath-write.xsl"/>   

   <xsl:include href="dhqBiblio-ChicagoLoose-html.xsl"/>
   
   <xsl:variable name="biblioPath">../data/current</xsl:variable>
   
   <xsl:variable name="allBiblio">
      <xsl:sequence select="collection(concat($biblioPath,'?select=*.xml;recurse=yes;on-error=ignore'))/biblio:BiblioSet/*"></xsl:sequence>
   </xsl:variable>

   <xsl:template match="/">
     <xsl:variable name="articleNo" select="replace(document-uri(/),'.*/(.+)\.xml$','$1')"/>
     <xsl:variable name="articleTitle" select="/TEI/teiHeader/fileDesc/titleStmt/title"/>
      <html>
         <head>
            <title>
               <xsl:text>DHQ Biblio View - </xsl:text>
               <xsl:value-of select="document-uri(.)"/>
            </title>
            <script src="js/jquery-1.10.2.min.js">
               <xsl:comment> script </xsl:comment>
            </script>
            <script src="js/biblioView.js">
               <xsl:comment> script</xsl:comment>
            </script>
            
            <xsl:copy-of select="$css"/>
         </head>
         <body>
            <h3>
               <xsl:text>Bibl lookup: article </xsl:text>
               <xsl:value-of select="$articleNo"/>
            </h3>
            <xsl:for-each select="$articleTitle">
               <h2>
                  <xsl:apply-templates/>
               </h2>
            </xsl:for-each>
            <xsl:call-template name="insertInstructions">
               <xsl:with-param name="articleNo" select="$articleNo"/>
               <xsl:with-param name="articleTitle" select="$articleTitle"/>
            </xsl:call-template>
            
            <p><xsl:text>Comparing with </xsl:text>
            <xsl:value-of select="count($allBiblio/*)"/>
            <xsl:text> entries in Biblio.</xsl:text></p>
            <xsl:apply-templates select="/*/text/back/listBibl"/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template name="insertInstructions">
      <xsl:param name="articleNo"/>
      <xsl:param name="articleTitle"/>
      <h3 class="button">
         <button class="toggle" style="display: none">Hide Key</button>
         <button class="toggle">Show Key</button>
      </h3>

      <div class="key toggle" style="display:none">
         <div class="Biblio">
            <div class="biblPath">
               <h4>XPath/to/bibl (in the article)</h4>
            </div>
            <div class="synopsis">
               <div class="matched">
                  <div class="source-bibl">
                     <p><code>bibl</code> element content from article</p>
                  </div>
                  <div class="biblio-listing">
                     <p class="biblioSynopsis">Display of listing found in Biblio</p>
                  </div>
               </div>
            </div>
            <p class="more">[Notice of similar but unmatched entries]</p>
            <h3 class="button">
               <button class="toggle" style="display: none">Hide Detail</button>
               <button class="toggle">Show Detail</button>
            </h3>
            <table class="detail toggle" style="display: none">
               <tbody>
                  <tr>
                     <th>Biblio ID</th>
                     <th>criterion</th>
                     <th>Biblio entry</th>
                  </tr>
                  <tr class="row1">
                     <td class="biblioID">ID of entry</td>
                     <td class="label">Matching ID<br class="br"/><span class="similarity"
                           >Similarity metric</span></td>
                     <td class="content">Full display of Biblio entry (whose ID
                        matches the key value). Presumably formatted: glitches will
                     reflect data errors or processing bugs).</td>
                  </tr>
                  <tr class="row0">
                     <td class="biblioID">ID of entry</td>
                     <td class="label">
                        <span class="similarity">Similarity metric</span>
                     </td>
                     <td class="content">Full (unformatted) display of Biblio entry (unmatched but
                        similar)</td>
                  </tr>
                  <tr class="row1">
                     <td class="biblioID">ID of entry</td>
                     <td class="label">
                        <span class="similarity">Similarity metric</span>
                     </td>
                     <td class="content">Full (unformatted) display of Biblio entry (unmatched but
                        similar)</td>
                  </tr>
               </tbody>
            </table>
         </div>
      </div>


      <h3 class="button">
         <button class="toggle" style="display: none">Hide Instructions</button>
         <button class="toggle">Show Instructions</button>
      </h3>

      <div class="instructions toggle" style="display: none">
         <h2>Instructions</h2>
         <p>This document lists bibliography entries (<code>bibl</code> elements inside
               <code>text/back/listBibl</code>) in DHQ article <xsl:value-of select="$articleNo"/>
               (“<xsl:apply-templates select="$articleTitle"/>”), resolving them against entries in
            the <b>Biblio</b> system. In any of these <code>bibl</code> elements, the
               <code>@key</code> attribute should correspond with the <code>@ID</code> of an entry
            in Biblio.</p>
         <div>
            <h4>Purple frame</h4>
            <p>These show <code>bibl</code> elements that have no keys into Biblio, or whose keys do
               not correspond with Biblio listings. The link is broken. But Biblio also has no similar entries.</p>
            <p>You have a choice:</p>
            <ul>
               <li>Add a Biblio entry for the item and set the <code>bibl/@key</code> to its
                  <code>@ID</code>;</li>
               <li>Or, mark the <code>bibl</code> with <code>@key="[unlisted]"</code> (with the
                  brackets). This indicates that the local listing, not the Biblio listing, should
                  be used in the article. (You should only do this in cases where you have
                  reasonable confidence the citation will never appear anywhere else.)</li>
            </ul>
         </div>
         <div>
            <h4>Amber frame</h4>
            <p>These show <code>bibl</code> elements whose keys do
               not correspond with Biblio listings. The link is broken. However, Biblio has similar entries,
               as shown in the detail listing; open this to see whether one of these is the correct
               one.</p>
         </div>
         <div>
            <h4>Red frame</h4>
            <p>These show where Biblio has a corresponding listing, but it appears incorrect. (The
               link is not broken, but the similarity metric between the Biblio entry and the <code>bibl</code>
               is uncomfortably low.) Check it (also inspecting any listings shown in the
               detail listing), proceeding as with missing links (amber frame).</p>
            <p>Note that since similarity metrics can be lower than the threshold even when the item is 
               correctly linked, not all of these entries are marked incorrectly.</p>
         </div>
         <div>
            <h4>Orange frame (rare)</h4>
            <p>These show where the <code>bibl</code> has <code>@key='[unlisted]'</code>, but the
               analysis detects a similar entry (or more than one; they will appear in the detail
               view). Since these will usually be false hits (similar but not the same), you can 
               ignore these unless they should actually be linked.</p>
         </div>
         <div>
            <h4>Plain frames</h4>
            <p>Neither an amber or a red box shows if the listing (a) is found in Biblio by its
                  <code>@key</code>, and (b) its similarity metric with the Biblio entry found is
               high enough, or (c) the item is marked (has a <code>@key</code> value as) "[unlisted]"
               and no similar entries were found in Biblio.
               This does not mean that the listing is correct! These should also be
               confirmed by inspection, especially when there are other Biblio entries found with
               high-enough similarity metrics (shown in the detail listing) to be displayed.</p>
         </div>
         <div>
            <h4>Similarity metrics</h4>
            <p>This analysis uses a crude similarity metric to guess whether article
                  <code>bibl</code> elements and Biblio entries look the same. The metric is
               calculated by looking at unique tokens (words) in both, removing stop words (common
               words like 'if' and 'and'; this reduces noise), and dividing the number of unique
               tokens found in <i>both</i> listings by the unique tokens found in <i>either</i>
               listing. (This is called the "Jaccard similarity".)</p>
            <p>If the listings are identical, we get 1, since neither has words not also found in
               the other. If they are completely different (i.e. they have no words in common except
               stop words), we get 0.</p>
            <p>The analysis considers two listings with a similarity metric of 0.8 or above to be
               "good enough" not to be flagged. It considers two listings with a metric of 0.3 or
               above to be similar enough to be displayed in the detail view. These thresholds can
               be adjusted to make the analysis more or less sensitive.</p>
         </div>
         <div>
            <h4>Path to <code>bibl</code></h4>
            <p>At upper right, a unique XPath for the <code>bibl</code> element is given. With the
               document open, use this expression in an XPath query box in your editor to locate the
                  <code>bibl</code> element.</p>
         </div>
      </div>
   </xsl:template>
   
   <xsl:template match="listBibl">
      <div class="listBibl">
         <xsl:apply-templates select="bibl"/>
      </div>
   </xsl:template>
   
   <xsl:template match="bibl[@dhq:key='[unlisted]']" priority="10"/>
   
   <xsl:template match="bibl" priority="1">
      <xsl:variable name="views" as="element()?">
         <xsl:apply-templates select="." mode="views"/>
      </xsl:variable>
      <div class="Biblio">
         <div class="biblPath">
            <h4>
               <xsl:apply-templates select="." mode="xpath"/>
            </h4>
         </div>
         <div class="synopsis">
            <div class="matched">
               <xsl:variable name="bibl" select="."/>
               <xsl:choose>
                  <xsl:when test="@key = '[unlisted]' and empty($views)">
                     <xsl:attribute name="class">unlisted</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="@key = '[unlisted]'">
                     <xsl:attribute name="class">matchedUnlisted</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="empty($views)">
                     <xsl:attribute name="class">unknown</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="empty($views/dhq:view/@class = 'id-match')">
                     <xsl:attribute name="class">unmatched</xsl:attribute>
                  </xsl:when>
                  <xsl:when
                     test="empty($views/dhq:view[@class = 'id-match']/*[dhq:bibl-jaccard(., $bibl)[3] gt 0.8])">
                     <!--dhq:jaccard(
                     dhq:distinct-tokens(string(.)),
                     dhq:distinct-tokens(string($views/dhq:view[@class='id-match']/*)))-->
                     <xsl:attribute name="class">mismatched</xsl:attribute>
                  </xsl:when>
               </xsl:choose>
               <div class="source-bibl">
                  <p>
                     <xsl:apply-templates mode="display"/>
                  </p>
               </div>
               <div class="biblio-listing">
                  <!--<xsl:apply-templates select="$views/dhq:view[@class='id-match']"
                  mode="biblio-synopsis"/>-->
                  <xsl:apply-templates select="$views/dhq:view[@class = 'id-match']" mode="display"/>
                  <xsl:if test="empty($views/dhq:view[@class = 'id-match'])">
                     <p class="no-match">
                        <xsl:choose>
                           <xsl:when test="@key = '[unlisted]'">Article <code>bibl</code> is marked as "unlisted"</xsl:when>
                           <xsl:when test="empty(@key)">Article <code>bibl</code> has no
                              <code>@key</code></xsl:when>
                           <xsl:otherwise>
                              <xsl:text>No Biblio entry has @ID='</xsl:text>
                              <xsl:value-of select="@key"/>
                              <xsl:text>'</xsl:text>
                           </xsl:otherwise>
                        </xsl:choose>
                     </p>
                  </xsl:if>
               </div>
            </div>
            <xsl:if test="empty($views)">
               <p class="more">[No Biblio items appear to be similar]</p>
            </xsl:if>
            <xsl:for-each-group select="$views/dhq:view[@class = 'similar']" group-by="true()">
               <p class="more">
                  <xsl:text>[Biblio</xsl:text>
                  <xsl:value-of
                     select="
                        if ($views/dhq:view/@class = 'id-match') then
                           ' also'
                        else
                           ''"/>
                  <xsl:text> has </xsl:text>
                  <xsl:value-of select="count(current-group())"/>
                  <xsl:text> similar </xsl:text>
                  <xsl:value-of
                     select="
                        if (count(current-group()) eq 1) then
                           'entry'
                        else
                           'entries'"/>
                  <xsl:text>]</xsl:text>
               </p>
            </xsl:for-each-group>
         </div>
         <xsl:if test="exists($views)">
            <h3 class="button">
               <button class="toggle" style="display: none">Hide Detail</button>
               <button class="toggle">Show Detail</button>
            </h3>
            <xsl:apply-templates select="$views"/>
         </xsl:if>
      </div>
   </xsl:template>
   
   <xsl:template match="biblio:*" mode="contributor-name" as="element()">
      <xsl:variable name="invert" select="position() eq 1 and exists(biblio:givenName)"/>
      <dhq:name>
         <xsl:if test="$invert">
            <xsl:attribute name="inverted">yes</xsl:attribute>
         </xsl:if>
         <xsl:for-each select="biblio:givenName[not($invert)]">
            <xsl:apply-templates select="."/>
            <xsl:text> </xsl:text>
         </xsl:for-each>
         <xsl:apply-templates select="biblio:corporateName | biblio:fullName | biblio:familyName"/>
         <xsl:for-each select="biblio:givenName[$invert]">
            <xsl:text>, </xsl:text>
            <xsl:apply-templates select="."/>
         </xsl:for-each>
      </dhq:name>
   </xsl:template>
   
   <!--<xsl:template mode="display" match="*[@rend='italic']">
      <i>
         <xsl:apply-templates/>
      </i>
   </xsl:template>
   
   <xsl:template mode="display" match="*[@rend='quotes']">
      <xsl:text>&#8220;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#8221;</xsl:text>
   </xsl:template>
   
   -->
   
   
   <xsl:template match="biblio:author" mode="name-group-label"/>
   
   <xsl:template match="biblio:editor" mode="name-group-label">
      <xsl:param name="plural" select="false()"/>
      <xsl:text> (ed</xsl:text>
      <xsl:if test="$plural">s</xsl:if>
      <xsl:text>.)</xsl:text>
   </xsl:template>
   
   <xsl:template match="biblio:translator" mode="name-group-label">
      <xsl:text> (trans.)</xsl:text>
   </xsl:template>
   
   <xsl:template match="biblio:creator" mode="name-group-label">
         <xsl:param name="plural" select="false()"/>
         <xsl:text> (creator</xsl:text>
         <xsl:if test="$plural">s</xsl:if>
         <xsl:text>)</xsl:text>
      </xsl:template>
      
   <xsl:template match="biblio:contributor" mode="name-group-label">
      <xsl:param name="plural" select="false()"/>
      <xsl:text> (contributor</xsl:text>
      <xsl:if test="$plural">s</xsl:if>
      <xsl:text>)</xsl:text>
   </xsl:template>
   
   <xsl:template match="bibl" mode="views">
      <xsl:variable name="bibl" select="."/>
      <xsl:variable name="views" as="element()*">
         <xsl:apply-templates select="key('biblio-by-ID',@key,$allBiblio)" mode="biblioID-entry">
            <xsl:with-param name="bibl" select="."/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$allBiblio/*" mode="similar-entry">
            <xsl:with-param name="bibl" select="."/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:if test="exists($views)">
         <views xmlns="http://www.digitalhumanities.org/ns/dhq">
            <xsl:sequence select="$views"/>
         </views>
         <!--<xsl:if test="count($views/*[@class='id-match']) gt 1">
            <xsl:message>
               
               <xsl:value-of select="count($views/*[@class='id-match'])"/>
            </xsl:message>
         </xsl:if>-->
      </xsl:if>
   </xsl:template>
      
   <xsl:template match="biblio:*" mode="biblioID-entry">
      <xsl:param name="bibl" required="yes"/>
      <xsl:variable name="jaccard"
         select="dhq:bibl-jaccard(.,$bibl)"/>
      <view xmlns="http://www.digitalhumanities.org/ns/dhq" class="id-match"
         intersect="{$jaccard[1]}" union="{$jaccard[2]}" similarity="{$jaccard[3]}">
         <xsl:copy-of select="."/>
      </view>
   </xsl:template>
   
   <xsl:template match="biblio:*" mode="similar-entry">
      <xsl:param name="bibl" required="yes"/>
      <!--<xsl:variable name="entryTokens" select="dhq:distinct-tokens(string(.))"/>
      <xsl:variable name="biblTokens"  select="dhq:distinct-tokens(string($bibl))"/>
      <xsl:variable name="intersect" select="$entryTokens[.=$biblTokens]"/>
      <xsl:variable name="union"     select="distinct-values(($entryTokens,$biblTokens))"/>-->
      <xsl:variable name="jaccard"
         select="dhq:bibl-jaccard(.,$bibl)"/>
      <xsl:if test="$jaccard[3] ge 0.3 and not($bibl/@key = @ID)">
      <view xmlns="http://www.digitalhumanities.org/ns/dhq" class="similar"
         intersect="{$jaccard[1]}" union="{$jaccard[2]}" similarity="{$jaccard[3]}">
         <xsl:copy-of select="."/>
      </view>
      </xsl:if>
   </xsl:template>
   
   
<!-- Functions for matching. -->
   
   <xsl:key name="biblio-by-ID" match="biblio:*" use="@ID"/>
      
   <!-- saxon:memo-function gets this from over 100 seconds to about 5 seconds.
        It is supported in Saxon EE and Saxon PE. -->
   <xsl:function name="dhq:distinct-tokens" as="xs:string*"
      saxon:memo-function="yes" xmlns:saxon="http://saxon.sf.net/">
      <xsl:param name="s" as="xs:string"/>
      <xsl:sequence select="distinct-values(tokenize(lower-case($s),'[\s\p{P}]+'))[normalize-space(.)][not(.=$stopWords)]"/>
   </xsl:function>
   
   <xsl:function name="dhq:round1000th" as="xs:double"
      saxon:memo-function="yes" xmlns:saxon="http://saxon.sf.net/">
      <xsl:param name="n" as="xs:double"/>
      <xsl:sequence select="round($n * 1000) div 1000"/>
   </xsl:function>
   
   <xsl:function name="dhq:bibl-jaccard" as="xs:double+" saxon:memo-function="yes"
      xmlns:saxon="http://saxon.sf.net/">
      <xsl:param name="biblioEntry" as="element()"/>
      <xsl:param name="bibl"        as="element(bibl)"/>
      <xsl:variable name="entryTokens" select="dhq:distinct-tokens(string-join($biblioEntry//text(),' '))"/>
      <xsl:variable name="biblTokens"  select="dhq:distinct-tokens(string-join($bibl//text(),' '))"/>
      <xsl:variable name="intersect"   select="$entryTokens[.=$biblTokens]"/>
      <xsl:variable name="union"       select="distinct-values(($entryTokens,$biblTokens))"/>
      <xsl:variable name="jaccard"     select="dhq:round1000th(count($intersect) div count($union))"/>
      
      <xsl:sequence select="count($intersect), count($union), $jaccard"/>
      
      <!--<xsl:if test="$bibl/@key='cecire2011b' and $biblioEntry/@ID='cecire2011b'">
         <xsl:message>
            <xsl:text>Biblio entry tokens: '</xsl:text>
            <xsl:value-of select="$entryTokens" separator="', '"/>
            <xsl:text>'; bibl tokens: '</xsl:text>
            <xsl:value-of select="$biblTokens" separator="', '"/>
            <xsl:text>'</xsl:text>
            
         </xsl:message>
      </xsl:if>-->
      
   </xsl:function>

   <!--<xsl:function name="dhq:jaccard" as="xs:double"
      saxon:memo-function="yes" xmlns:saxon="http://saxon.sf.net/">
      <xsl:param name="t1" as="xs:string*"/>
      <xsl:param name="t2" as="xs:string*"/>
      <xsl:variable name="intersect" select="$t1[.=$t2]"/>
      <xsl:variable name="union"     select="distinct-values(($t1,$t2))"/>
      <xsl:sequence                  select="count($intersect) div count($union)"/>
   </xsl:function>-->
   
   
   <!-- Functions for display  -->
   
   <xsl:function name="dhq:emit-name-sequence" as="xs:string">
      <!-- emits a sequence of names as an 'and' sequence; but
           punctuation is adjusted for internals -->
      <xsl:param name="names" as="element()*"/>
      <xsl:variable name="nameStrings" as="xs:string*">
         <!-- add an extra comma after the first inverted name if there is only a second name following -->
         <xsl:sequence select="concat($names[1], if ($names[1]/@inverted='yes' and exists($names[2]) and empty($names[3])) then ',' else '')"/>
         <xsl:sequence select="remove($names,1)/string()"/>
      </xsl:variable>
     <xsl:sequence select="dhq:emit-sequence($nameStrings,'and')"/>   
   </xsl:function>
   
   <xsl:function name="dhq:emit-sequence" as="xs:string">
      <xsl:param name="strings" as="xs:string*"/>
      <xsl:param name="conjunction" as="xs:string"/>
      <xsl:value-of>
         <xsl:for-each select="$strings">
            <xsl:choose>
               <xsl:when test="position() eq 1"/>
               <xsl:when test="position() eq last()">
                  <xsl:value-of select="concat(' ',$conjunction,' ')"/>
               </xsl:when>
               <xsl:otherwise>, </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
         </xsl:for-each>
      </xsl:value-of>
   </xsl:function>
   <!-- Processing views for display  -->
   
   <xsl:template match="dhq:views">
      <table class="detail toggle" style="display: none">
         <tr>
            <th>Biblio ID</th>
            <th>criterion</th>
            <th>Biblio entry</th>
         </tr>
         <xsl:apply-templates/>
      </table>
   </xsl:template>
   
   <xsl:template match="dhq:view">
      <tr class="row{count(.|preceding-sibling::*) mod 2}">
         <td class="biblioID">
            <xsl:value-of select="biblio:*/@ID"/>
         </td>
         <xsl:apply-templates select="." mode="label"/>
         <td class="content">
            <xsl:apply-templates mode="display"/>
         </td>         
      </tr>
   </xsl:template>
   
   <xsl:template match="dhq:view[@class='id-match']" mode="label">
      <td class="label">Matching ID<br class="br"/>
      <span class="similarity">
         <xsl:text>Similarity </xsl:text>
         <xsl:apply-templates select="." mode="show-similarity"/>
      </span>
      </td>
   </xsl:template>
   
   
   <xsl:template match="dhq:view[@class='similar']" mode="label">
      <td class="label">
         <span class="similarity">
            <xsl:text>Similarity </xsl:text>
            <xsl:apply-templates select="." mode="show-similarity"/>
         </span>
      </td>
   </xsl:template>
   
   
   <xsl:template match="dhq:view" mode="show-similarity">
      <xsl:value-of select="concat(@similarity, ' (',@intersect,'/',@union, ')')"/>
   </xsl:template>
  
   
   <xsl:template match="dhq:view/biblio:*" mode="display">
      <xsl:apply-templates select="." mode="dhqBiblio:ChicagoLoose"
         xmlns:dhqBiblio="http://digitalhumanities.org/dhq/ns/biblio"
      />
   </xsl:template>
   
   <xsl:template match="biblio:*" mode="display">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="* | text()[matches(.,'\S')]" mode="#current"/>
      <!--<span class="tag">] </span>-->
   </xsl:template>
   
   <xsl:variable name="css">
      <style type="text/css">
         
         body { background-color: skyblue }
         
         div.instructions  { padding: 0.5em; margin: 1em 0px; border: thin solid black;
           background-color: lemonchiffon; font-size: 90% }
         div.instructions * { margin: 0px }
         div.instructions p, div.instructions > div { margin-top: 0.5em }
         div.instructions > div { border-left: thin dotted black;
           margin-top: 0.5em; padding-left: 0.5em }
           
         div.Biblio { padding: 0.5em; margin: 1em 0px; background-color: white }
         div.Biblio > *:first-child { margin-top: 0px }
         
         code, pre {  font-family: Consolas, monospace }
         
         .biblPath { margin: 0.5em 0px; font-family: Consolas, monospace;
           font-weight: normal; font-size: 80%; float: right; clear: both }
         .biblPath h4 { margin: 0px }
         
         .synopsis { margin: 0.5em 0px; clear: both }
         .synopsis * { margin: 0px }

         .synopsis > div { border: thin solid grey; padding: 0.5em }
         .synopsis > .matchedUnlisted { border: medium solid darkorange }
         .synopsis > .mismatched { border: medium solid #C24641 /* cherry red */ }
         .synopsis > .unmatched  { border: medium solid #FFDB58 /* mustard orange */ }
         .synopsis > .unknown   { border: medium solid purple }
         
         .synopsis > div p,
         div .bibl { padding-left: 2em; text-indent: -2em; font-family: sans-serif }
         
         .source-bibl { border-bottom: thin dotted grey; padding-bottom: 0.25em; margin-bottom: 0.25em }
         
         p.no-match { font-weight: bold }
         .no-bold { font-weight: normal }
         .detail { margin-top: 0.5em; width: 100% }
         .detail td { border-top: thin solid black }
         
         h3.button { margin: 0px }
         
         p.more { margin: 0.5em 0px; font-size: 90%; font-style: italic }
         
         th { font-family: sans-serif; font-size: 80%; text-align: left; padding-left: 0.5em }
         td { vertical-align: text-top; padding: 0.5em }
         
         .row1 { background-color: cornsilk }
         
         .biblioID, .id { font-weight: bold; font-size: smaller; font-family: sans-serif }
         
         td.label     { width: 15% }
         td.biblioID  { width: 10% }
         td.content   { width: 75% }
         
         span.biblioID { padding-right: 1em }

         span.similarity { font-family: sans-serif; font-size: 80% } 
         .tag { color: darkorange; font-size: 80%; font-family: sans-serif }
         
      </style>
   </xsl:variable>
   
   <!-- Words to be eliminated for similarity comparison, as too common.
        From http://norm.al/2009/04/14/list-of-english-stop-words/ -->
   <xsl:variable name="stopWords" as="element()+">
      <w>ed</w>
      <w>eds</w>
      <w>trans</w>
      
      <!--<w>a</w>
      <w>b</w>
      <w>c</w>
      <w>d</w>
      <w>e</w>
      <w>f</w>
      <w>g</w>
      <w>h</w>
      <w>i</w>
      <w>j</w>
      <w>k</w>
      <w>l</w>
      <w>m</w>
      <w>n</w>
      <w>o</w>
      <w>p</w>
      <w>q</w>
      <w>r</w>
      <w>s</w>
      <w>t</w>
      <w>u</w>
      <w>v</w>
      <w>w</w>
      <w>x</w>
      <w>y</w>
      <w>z</w>-->
      
      <w>a</w>
      <w>about</w>
      <w>above</w>
      <w>across</w>
      <w>after</w>
      <w>afterwards</w>
      <w>again</w>
      <w>against</w>
      <w>all</w>
      <w>almost</w>
      <w>alone</w>
      <w>along</w>
      <w>already</w>
      <w>also</w>
      <w>although</w>
      <w>always</w>
      <w>am</w>
      <w>among</w>
      <w>amongst</w>
      <w>amoungst</w>
      <w>amount</w>
      <w>an</w>
      <w>and</w>
      <w>another</w>
      <w>any</w>
      <w>anyhow</w>
      <w>anyone</w>
      <w>anything</w>
      <w>anyway</w>
      <w>anywhere</w>
      <w>are</w>
      <w>around</w>
      <w>as</w>
      <w>at</w>
      <w>back</w>
      <w>be</w>
      <w>became</w>
      <w>because</w>
      <w>become</w>
      <w>becomes</w>
      <w>becoming</w>
      <w>been</w>
      <w>before</w>
      <w>beforehand</w>
      <w>behind</w>
      <w>being</w>
      <w>below</w>
      <w>beside</w>
      <w>besides</w>
      <w>between</w>
      <w>beyond</w>
      <w>bill</w>
      <w>both</w>
      <w>bottom</w>
      <w>but</w>
      <w>by</w>
      <w>call</w>
      <w>can</w>
      <w>cannot</w>
      <w>cant</w>
      <w>co</w>
      <w>computer</w>
      <w>con</w>
      <w>could</w>
      <w>couldnt</w>
      <w>cry</w>
      <w>de</w>
      <w>describe</w>
      <w>detail</w>
      <w>do</w>
      <w>done</w>
      <w>down</w>
      <w>due</w>
      <w>during</w>
      <w>each</w>
      <w>eg</w>
      <w>eight</w>
      <w>either</w>
      <w>eleven</w>
      <w>else</w>
      <w>elsewhere</w>
      <w>empty</w>
      <w>enough</w>
      <w>etc</w>
      <w>even</w>
      <w>ever</w>
      <w>every</w>
      <w>everyone</w>
      <w>everything</w>
      <w>everywhere</w>
      <w>except</w>
      <w>few</w>
      <w>fifteen</w>
      <w>fify</w>
      <w>fill</w>
      <w>find</w>
      <w>fire</w>
      <w>first</w>
      <w>five</w>
      <w>for</w>
      <w>former</w>
      <w>formerly</w>
      <w>forty</w>
      <w>found</w>
      <w>four</w>
      <w>from</w>
      <w>front</w>
      <w>full</w>
      <w>further</w>
      <w>get</w>
      <w>give</w>
      <w>go</w>
      <w>had</w>
      <w>has</w>
      <w>hasnt</w>
      <w>have</w>
      <w>he</w>
      <w>hence</w>
      <w>her</w>
      <w>here</w>
      <w>hereafter</w>
      <w>hereby</w>
      <w>herein</w>
      <w>hereupon</w>
      <w>hers</w>
      <w>herse”</w>
      <w>him</w>
      <w>himse”</w>
      <w>his</w>
      <w>how</w>
      <w>however</w>
      <w>hundred</w>
      <w>i</w>
      <w>ie</w>
      <w>if</w>
      <w>in</w>
      <w>inc</w>
      <w>indeed</w>
      <w>interest</w>
      <w>into</w>
      <w>is</w>
      <w>it</w>
      <w>its</w>
      <w>itse”</w>
      <w>keep</w>
      <w>last</w>
      <w>latter</w>
      <w>latterly</w>
      <w>least</w>
      <w>less</w>
      <w>ltd</w>
      <w>made</w>
      <w>many</w>
      <w>may</w>
      <w>me</w>
      <w>meanwhile</w>
      <w>might</w>
      <w>mill</w>
      <w>mine</w>
      <w>more</w>
      <w>moreover</w>
      <w>most</w>
      <w>mostly</w>
      <w>move</w>
      <w>much</w>
      <w>must</w>
      <w>my</w>
      <w>myse”</w>
      <w>name</w>
      <w>namely</w>
      <w>neither</w>
      <w>never</w>
      <w>nevertheless</w>
      <w>next</w>
      <w>nine</w>
      <w>no</w>
      <w>nobody</w>
      <w>none</w>
      <w>noone</w>
      <w>nor</w>
      <w>not</w>
      <w>nothing</w>
      <w>now</w>
      <w>nowhere</w>
      <w>of</w>
      <w>off</w>
      <w>often</w>
      <w>on</w>
      <w>once</w>
      <w>one</w>
      <w>only</w>
      <w>onto</w>
      <w>or</w>
      <w>other</w>
      <w>others</w>
      <w>otherwise</w>
      <w>our</w>
      <w>ours</w>
      <w>ourselves</w>
      <w>out</w>
      <w>over</w>
      <w>own</w>
      <w>part</w>
      <w>per</w>
      <w>perhaps</w>
      <w>please</w>
      <w>put</w>
      <w>rather</w>
      <w>re</w>
      <w>same</w>
      <w>see</w>
      <w>seem</w>
      <w>seemed</w>
      <w>seeming</w>
      <w>seems</w>
      <w>serious</w>
      <w>several</w>
      <w>she</w>
      <w>should</w>
      <w>show</w>
      <w>side</w>
      <w>since</w>
      <w>sincere</w>
      <w>six</w>
      <w>sixty</w>
      <w>so</w>
      <w>some</w>
      <w>somehow</w>
      <w>someone</w>
      <w>something</w>
      <w>sometime</w>
      <w>sometimes</w>
      <w>somewhere</w>
      <w>still</w>
      <w>such</w>
      <w>system</w>
      <w>take</w>
      <w>ten</w>
      <w>than</w>
      <w>that</w>
      <w>the</w>
      <w>their</w>
      <w>them</w>
      <w>themselves</w>
      <w>then</w>
      <w>thence</w>
      <w>there</w>
      <w>thereafter</w>
      <w>thereby</w>
      <w>therefore</w>
      <w>therein</w>
      <w>thereupon</w>
      <w>these</w>
      <w>they</w>
      <w>thick</w>
      <w>thin</w>
      <w>third</w>
      <w>this</w>
      <w>those</w>
      <w>though</w>
      <w>three</w>
      <w>through</w>
      <w>throughout</w>
      <w>thru</w>
      <w>thus</w>
      <w>to</w>
      <w>together</w>
      <w>too</w>
      <w>top</w>
      <w>toward</w>
      <w>towards</w>
      <w>twelve</w>
      <w>twenty</w>
      <w>two</w>
      <w>un</w>
      <w>under</w>
      <w>until</w>
      <w>up</w>
      <w>upon</w>
      <w>us</w>
      <w>very</w>
      <w>via</w>
      <w>was</w>
      <w>we</w>
      <w>well</w>
      <w>were</w>
      <w>what</w>
      <w>whatever</w>
      <w>when</w>
      <w>whence</w>
      <w>whenever</w>
      <w>where</w>
      <w>whereafter</w>
      <w>whereas</w>
      <w>whereby</w>
      <w>wherein</w>
      <w>whereupon</w>
      <w>wherever</w>
      <w>whether</w>
      <w>which</w>
      <w>while</w>
      <w>whither</w>
      <w>who</w>
      <w>whoever</w>
      <w>whole</w>
      <w>whom</w>
      <w>whose</w>
      <w>why</w>
      <w>will</w>
      <w>with</w>
      <w>within</w>
      <w>without</w>
      <w>would</w>
      <w>yet</w>
      <w>you</w>
      <w>your</w>
      <w>yours</w>
      <w>yourself</w>
      <w>yourselves</w>
   </xsl:variable>
   
   <xsl:template mode="xpath" match="bibl[@key='[unlisted]']" priority="3">
      <xsl:text>/descendant::bibl[@key='[unlisted]'][</xsl:text>
      <xsl:number count="bibl[@key='[unlisted]']" level="any"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   
   <xsl:template mode="xpath" match="bibl[exists(@key)]" priority="2">
      <xsl:text>//bibl</xsl:text>
      <xsl:text>[@key='</xsl:text>
      <xsl:value-of select="@key"/>
      <xsl:text>']</xsl:text>
   </xsl:template>
   
   <xsl:template mode="xpath" match="bibl[normalize-space(@xml:id)]">
      <xsl:text>//bibl</xsl:text>
      <xsl:text>[@xml:id='</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text>']</xsl:text>
   </xsl:template>
   
   <!--<xsl:template match="biblio:*" mode="biblio-synopsis">
      <p class="biblioSynopsis">
         <xsl:variable name="contributors" select="biblio:author | biblio:translator | biblio:editor | biblio:creator | biblio:contributor"/>
         <xsl:for-each-group select="$contributors" group-by="name(.)">
            <xsl:variable name="names" as="element()*">
               <xsl:apply-templates select="current-group()" mode="contributor-name"/>
            </xsl:variable>
            <xsl:value-of select="dhq:emit-name-sequence($names)"/>
            <xsl:apply-templates select="." mode="name-group-label">
               <xsl:with-param name="plural" select="count(current-group()) gt 1"/>
            </xsl:apply-templates>
            <xsl:choose>
               <xsl:when test="position() eq last()">
                  <xsl:if test="not(ends-with(dhq:emit-name-sequence($names),'.'))">.</xsl:if>
               </xsl:when>
               <xsl:otherwise>;</xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
         </xsl:for-each-group>
         <xsl:apply-templates select="biblio:title, (biblio:date,*/biblio:date)[1]" mode="#current"/>
      </p>
   </xsl:template>-->
   
   <!--<xsl:template match="biblio:title" mode="biblio-synopsis">
      <b><xsl:apply-templates/></b>
   </xsl:template>
   
   <xsl:template match="biblio:date" mode="biblio-synopsis">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
   </xsl:template>-->
   
   
</xsl:stylesheet>