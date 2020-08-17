<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:dhqBiblio="http://digitalhumanities.org/dhq/ns/biblio"
   xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
   exclude-result-prefixes="#all"
   version="2.0">

   <!--element.Artwork
| element.BlogEntry
-->
   

   <xsl:strip-space elements="*"/>
   
   <xsl:preserve-space elements="title additionalTitle"/>
   
   
   <!--
      element.Book =
        element Book {
          attribute-model.item,
          attribute issuance { 'monographic' },
          element-model.contributors,
          element-model.title,
          element-model.published,
          element totalPages { text }?,
          url?,
          note* }
   -->
   
   <!-- Book should look like:
          Author/contributors (authors unless empty(author), then editors/translators )
          Title
          Contributor gloss (editors or translators when exists(author)
          Publication
          Pages
          URL
   -->
   
   <!-- element.Thesis =
  element Thesis {
    attribute-model.item,
    attribute issuance { 'monographic'},
    author,
    title,
    place,
    date,
    url*,
    note* }
    
  -->
   
   <xsl:template match="Book | Thesis | VideoGame | WebSite | Artwork | BlogEntry" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <xsl:call-template   name="dhqBiblio:initial-contributor-sentence"/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence"                 select="title, additionalTitle"/>
            <xsl:call-template   name="dhqBiblio:more-contributors-sentences"/>
            <xsl:apply-templates mode="dhqBiblio:publisher-sequence"          select="."/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="totalPages, url"/>
            <!-- note not emitted -->
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <!-- 
      element.BookInSeries =
        element BookInSeries {
          attribute-model.item,
          attribute issuance { 'monographic' | 'continuing' },
          element-model.contributors,
          element-model.title,
          element.bookSeries,
          element totalPages { text }?,
          url? }
  -->
   <xsl:template match="BookInSeries" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <xsl:call-template   name="dhqBiblio:initial-contributor-sentence"/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence"                  select="title, additionalTitle, formalID"/>
            <xsl:call-template name="dhqBiblio:more-contributors-sentences"/>
            <xsl:apply-templates mode="#current"                               select="series"/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence"                  select="totalPages, url"/>
            <!-- note not emitted -->
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>


   <!-- element.BookSection =
  element BookSection {
    attribute-model.item,
    element-model.contributors,
    element-model.title,
    element book {
      attribute issuance { 'continuing' | 'monographic' },
      element-model.contributors,
      element-model.title,
      ( element-model.published |
        element.bookSeries),
      element totalPages { text }? },
    element-model.pages?,
    url?,
    note* }
   -->
   
   <xsl:template match="BookSection" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <xsl:call-template   name="dhqBiblio:initial-contributor-sentence"/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence"                  select="title, additionalTitle, formalID"/>
            <xsl:call-template   name="dhqBiblio:more-contributors-sentences"/>
            <xsl:apply-templates mode="#current"                               select="book">
               <xsl:with-param name="label">In </xsl:with-param>
            </xsl:apply-templates>
            <xsl:call-template   name="dhqBiblio:page-range"/>
            <xsl:apply-templates mode="dhqBiblio:as-sentence"                  select="url"/>
            <!-- note not emitted -->
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   

   <!-- 
element.JournalArticle =
  element JournalArticle {
    attribute-model.item,
    attribute issuance { 'monographic' | 'continuing' },
    element-model.contributors,
    element-model.title,
    element journal {
      attribute issuance { 'continuing' },
      element-model.title,
      volume?,
      issue?,
      date? },
    element-model.pages?,
    url?,
    note* }
-->

   <xsl:template match="JournalArticle" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <xsl:call-template name="dhqBiblio:initial-contributor-sentence"/>
            
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="title, additionalTitle, formalID"/>
            <xsl:call-template name="dhqBiblio:more-contributors-sentences"/>
            <xsl:apply-templates mode="#current"              select="journal"/>
            <!--<xsl:call-template   name="dhqBiblio:page-range"/>-->
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="url"/>
            <!-- note not emitted -->
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <!-- element.ConferencePaper =
element ConferencePaper {
    attribute-model.item,
    attribute issuance { 'monographic' },
    element-model.contributors,
    element-model.title,
    element conference {
      element name { text }?,
      date?,
      element sponsor { text }? }?,
    element publication {
      attribute issuance { 'monographic' | 'continuing' },
      element-model.title?,
      volume?,
      issue?,
      element-model.published }?,
    element-model.pages?,
    url? }    
  -->

   <xsl:template match="ConferencePaper" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <xsl:call-template name="dhqBiblio:initial-contributor-sentence"/>
            
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="title, additionalTitle, formalID"/>
            <xsl:call-template name="dhqBiblio:more-contributors-sentences"/>
            <xsl:apply-templates mode="#current"              select="conference, publication"/>
            <!--<xsl:call-template   name="dhqBiblio:page-range"/>-->
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="url"/>
            <!-- note not emitted -->
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="*" mode="dhqBiblio:ChicagoLoose">
      <xsl:call-template name="dhqBiblio:make-bibl-div">
         <xsl:with-param name="sentence-sequence"  as="element(dhqBiblio:sentence)*">
            <dhqBiblio:sentence>Warning: Biblio formatting not applied</dhqBiblio:sentence>
            <xsl:apply-templates mode="dhqBiblio:as-sentence" select="*"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <!--<xsl:template match="series" mode="dhqBiblio:ChicagoLoose">
      <dhqBiblio:sentence>
         <xsl:call-template name="dhqBiblio:contributor-sequence">
            <xsl:with-param name="invert-leading-name" select="false()"/>
                  <xsl:with-param name="who"
                     select="author, (editor|contributor)[empty(../author)], translator[empty(../(author|editor|contributor))], etal"
                  />
         </xsl:call-template>
         <xsl:value-of select="title/', '"/><!-\- inserting a space if there's a title -\->
         <!-\- RNC constrains to a single title -\->
         <xsl:apply-templates select="title"/>
      </dhqBiblio:sentence>
      <xsl:apply-templates  mode="dhqBiblio:as-sentence" select="additionalTitle, formalID"></xsl:apply-templates>
      <xsl:call-template name="dhqBiblio:more-contributors-sentences"/>
      <xsl:apply-templates select="." mode="dhqBiblio:publisher-sequence"/>
   </xsl:template>-->
   
   <xsl:template match="series | book" mode="dhqBiblio:ChicagoLoose">
      <xsl:param name="label"/><!-- Pass in a $label as a text node for 'In' -->
      <dhqBiblio:sentence>
         <xsl:copy-of select="$label"/>
         <xsl:variable name="contributors">
         <xsl:call-template name="dhqBiblio:contributor-sequence">
            <xsl:with-param name="invert-leading-name" select="false()"/>
                  <xsl:with-param name="who"
                     select="author, (editor|contributor)[empty(../author)], translator[empty(../(author|editor|contributor))], etal"
                  />
         </xsl:call-template>
         </xsl:variable>
         <xsl:copy-of select="$contributors"/>
         <xsl:value-of select="if (exists(title) and normalize-space($contributors)) then ', ' else ''"/><!-- inserting a delimiter if needed -->
         <!-- RNC constrains to a single title -->
         <xsl:apply-templates select="title"/>
      </dhqBiblio:sentence>
      <xsl:apply-templates  mode="dhqBiblio:as-sentence" select="additionalTitle, formalID"></xsl:apply-templates>
      <xsl:call-template name="dhqBiblio:more-contributors-sentences"/>
      <xsl:apply-templates select="." mode="dhqBiblio:publisher-sequence"/>
      <!-- Handle book/totalPages? -->
   </xsl:template>
   
   <xsl:template match="journal | publication" mode="dhqBiblio:ChicagoLoose">
      <!-- wrapped in a single sentence 
             journal (title, volume?, issue?, date?)
             (startingPage, endingPage?)?
           element publication {
             attribute issuance { 'monographic' | 'continuing' },
             element-model.title?,
             volume?,
             issue?,
             element-model.published }?,    
      -->
      <!-- Not handling additionalTitle inside journal -->
      <dhqBiblio:sentence>
         <xsl:apply-templates mode="dhqBiblio:publication"
            select="title, self::publication/additionalTitle, volume, issue, date, following-sibling::startingPage"/>         
      </dhqBiblio:sentence>
      <xsl:apply-templates mode="dhqBiblio:as-sentence" select="formalID"/>
   </xsl:template>
   
   <!-- element conference {
     title { text },
     date?,
     element sponsor { text }? } -->
   
   <xsl:template match="conference" mode="dhqBiblio:ChicagoLoose">
      <xsl:if test="normalize-space(.)">
         <dhqBiblio:sentence>
            <xsl:text>Presented at </xsl:text>
            <xsl:apply-templates mode="dhqBiblio:publication" select="title, sponsor, date"/>
         </dhqBiblio:sentence>
      </xsl:if>
   </xsl:template>
   <!--
      element.bookSeries =
        element series {
          attribute issuance { 'monographic' | 'continuing' },
          element-model.contributors,
          element-model.title,
          element-model.published }
   -->
   
   <xsl:template name="dhqBiblio:initial-contributor-sentence">
      <!-- Emits the lead string of contributors (authors or editors/translators)
           in sequence, in source document order, first one listed surname/givennames -->
      <dhqBiblio:sentence>
            <xsl:call-template name="dhqBiblio:contributor-sequence">
               <xsl:with-param name="who"
                  select="(creator|author), (editor|contributor)[empty(../(creator|author))], translator[empty(../(creator|author|editor|contributor))], etal"
               />
            </xsl:call-template>
      </dhqBiblio:sentence>
   </xsl:template>
   
   <xsl:template name="dhqBiblio:contributor-sequence">
      <xsl:param name="who" as="element()*"/>
      <xsl:param name="invert-leading-name" select="true()"/>
      <xsl:variable name="who-but-etal" select="$who except ($who/self::etal)"/>
      <!-- we should get either author* or (editor|contributor)* or translator* with etal? -->
      <xsl:for-each select="$who-but-etal">
         <xsl:variable name="p" select="position()"/>
         <xsl:choose>
            <xsl:when test="$p eq 1"/>
            <xsl:when test="$p eq last()"> and </xsl:when>
            <!-- when $p is 2, any comma is provided with position 1 -->
            <xsl:when test="$p gt 2">, </xsl:when>
            <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="$invert-leading-name and ($p eq 1)">
               <xsl:apply-templates select="familyName | fullName | corporateName" mode="dhqBiblio:item-contributors"/>
               <xsl:for-each select="givenName">
                  <xsl:for-each select="following-sibling::familyName">
                     <xsl:text>, </xsl:text>
                  </xsl:for-each>
                  <xsl:apply-templates select="." mode="dhqBiblio:item-contributors"/>
               </xsl:for-each>
               <xsl:if test="exists(($who-but-etal)[$p + 1])">,</xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="*" mode="dhqBiblio:item-contributors"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="$who/self::etal">
         <xsl:text>, et al.</xsl:text>
      </xsl:for-each>
      <xsl:for-each-group select="$who/(self::editor|self::contributor)" group-by="true()">
         <xsl:text>, ed</xsl:text>
         <xsl:if test="count(current-group()) gt 1">s</xsl:if>
         <xsl:text>.</xsl:text>
      </xsl:for-each-group>
      <xsl:for-each-group select="$who/self::translator" group-by="true()">
         <xsl:text>, trans.</xsl:text>
      </xsl:for-each-group>
   </xsl:template>

   <xsl:template name="dhqBiblio:medial-contributor-sequence">
      <xsl:param name="who" as="element()*"/>
      <!-- we should get either author* or (editor|contributor)* or translator* with etal? -->
      <xsl:for-each select="$who">
         <xsl:variable name="p" select="position()"/>
         <xsl:choose>
            <xsl:when test="$p eq 1"/>
            <xsl:when test="$p eq last()"> and </xsl:when>
            <!-- when $p is 2, any comma is provided with position 1 -->
            <xsl:when test="$p gt 2">, </xsl:when>
            <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
         </xsl:choose>
         <!-- All the matched elements have element contents; we do not want stray text -->
         <xsl:apply-templates select="*" mode="dhqBiblio:item-contributors"/>
      </xsl:for-each>
   </xsl:template>
   
   
   <xsl:template name="dhqBiblio:more-contributors-sentences">
      <!-- Emits any editors, contributors or translators iff no authors or creators are found, grouping
           them by type. Contributors are treated like editors. ('contributor' should not appear in valid data.) -->
      <xsl:for-each-group select="(creator|author)/../(editor|contributor|translator)"
         group-by="exists(self::translator)">
         <dhqBiblio:sentence>
               <xsl:choose>
                  <xsl:when test="current-grouping-key()">Translated by </xsl:when>
                  <xsl:otherwise>Edited by </xsl:otherwise>
               </xsl:choose>
            <xsl:for-each select="current-group()">
               <xsl:variable name="p" select="position()"/>
               <xsl:choose>
                  <xsl:when test="$p eq 1"/>
                  <xsl:when test="$p eq last()"> and </xsl:when>
                  <!-- when $p is 2, any comma is provided with position 1 -->
                  <xsl:when test="$p gt 2">, </xsl:when>
                  <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
               </xsl:choose>
               <!-- All the matched elements have element contents; we do not want stray text -->
               <xsl:apply-templates select="*" mode="dhqBiblio:item-contributors"/>
            </xsl:for-each>
<!--               <xsl:call-template name="dhqBiblio:medial-contributor-sequence">
                  <xsl:with-param name="who" select="current-group()"/>
               </xsl:call-template>-->
         </dhqBiblio:sentence>
      </xsl:for-each-group>
   </xsl:template>
   
   
   <xsl:template match="givenName | familyName | fullName | corporateName" mode="dhqBiblio:item-contributors">
      <xsl:if test="position() gt 1">
         <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="*" mode="dhqBiblio:as-sentence">
      <dhqBiblio:sentence>
         <xsl:apply-templates select="."/>
      </dhqBiblio:sentence>
   </xsl:template>
   
   <xsl:template match="*" mode="dhqBiblio:publication">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="."/>
   </xsl:template>
   
   <xsl:template match="additionalTitle" mode="dhqBiblio:publication">
      <!-- additionalTitle doesn't appear in journal, but it may appear in ConferencePaper/publication -->
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>)</xsl:text>
   </xsl:template>
   
   <xsl:template match="issue" mode="dhqBiblio:publication">
      <xsl:if test="exists(preceding-sibling::volume)">
         <xsl:text>:</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="."/>
   </xsl:template>
   
   <xsl:template match="conference/title | conference/additionalTitle | conference/formalID" mode="dhqBiblio:publication">
      <xsl:apply-templates select="."/>
   </xsl:template>
   
   <xsl:template match="conference/sponsor" mode="dhqBiblio:publication">
      <xsl:if test="position() gt 1">, sponsored by </xsl:if>
      <xsl:apply-templates select="."/>
   </xsl:template>
   
   <xsl:template match="date" mode="dhqBiblio:publication">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>)</xsl:text>
   </xsl:template>
   
   <xsl:template match="startingPage" mode="dhqBiblio:publication">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="dhqBiblio:page-range"/>
   </xsl:template>
   
   <xsl:template match="startingPage" mode="dhqBiblio:page-range">
      <xsl:text>p</xsl:text>
      <xsl:if test="exists(following-sibling::endingPage)">p</xsl:if>
      <xsl:text>. </xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:for-each select="following-sibling::endingPage">
         <xsl:text>-</xsl:text>
         <xsl:apply-templates select="."/>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="dhqBiblio:page-range">
      <xsl:for-each select="startingPage">
      <dhqBiblio:sentence>
         <xsl:apply-templates select="." mode="dhqBiblio:page-range"/>
      </dhqBiblio:sentence>
      </xsl:for-each>
   </xsl:template>

   <xsl:template match="title | additionalTitle">
      <em class="title">
         <xsl:apply-templates/>
      </em>
   </xsl:template>
   
   <xsl:template
      match="JournalArticle/title | JournalArticle/additionaltitle |
      ConferencePaper/title | ConferencePaper/additionaltitle |
      BookSection/title | BookSection/additionaltitle">
      <xsl:text>&#8220;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#8221;</xsl:text>
   </xsl:template>
   
   <xsl:template match="title/q | additionalTitle/q">
      <xsl:variable name="alreadyQuoted" select="exists(../(parent::JournalArticle|parent::ConferencePaper|parent::BookSection))"/>
      <xsl:value-of select="if ($alreadyQuoted) then '&#8216;' else '&#8220;'"/>
      <span class="q">
         <xsl:apply-templates/>
      </span>
      <xsl:value-of select="if ($alreadyQuoted) then '&#8217;' else '&#8221;'"/>
      <xsl:text>&#8221;</xsl:text>
   </xsl:template>
   
   <xsl:template match="i">
      <i>
         <xsl:apply-templates/>
      </i>
   </xsl:template>
   
   <xsl:template match="totalPages">
      <xsl:apply-templates/>
      <xsl:text> pages</xsl:text>
   </xsl:template>

   <xsl:template match="url">
      <a href="{.}">
         <xsl:apply-templates/>
      </a>
   </xsl:template>
   
   <xsl:template match="Book | WebSite | Artwork | BlogEntry | book | series" mode="dhqBiblio:publisher-sequence">
      <dhqBiblio:sentence>
         <xsl:apply-templates select="place, publisher, date" mode="#current"/>
      </dhqBiblio:sentence>
   </xsl:template>
   
   <xsl:template match="Thesis" mode="dhqBiblio:publisher-sequence">
      <dhqBiblio:sentence>
         <xsl:text>Thesis</xsl:text>
         <xsl:if test="exists(place | publisher | date)">, </xsl:if>
         <xsl:apply-templates select="place, publisher, date" mode="#current"/>
      </dhqBiblio:sentence>
   </xsl:template>
   
   <xsl:template match="VideoGame" mode="dhqBiblio:publisher-sequence">
      <dhqBiblio:sentence>
         <xsl:text>Video Game</xsl:text>
         <xsl:if test="exists(place | publisher | date)">, </xsl:if>
         <xsl:apply-templates select="place, publisher, date" mode="#current"/>
      </dhqBiblio:sentence>
   </xsl:template>
   
   <xsl:template match="place" mode="dhqBiblio:publisher-sequence">
      <xsl:apply-templates mode="#current"/>
      <xsl:if test="not(position() eq last())">: </xsl:if>
   </xsl:template>
   
   <xsl:template match="publisher" mode="dhqBiblio:publisher-sequence">
      <xsl:apply-templates mode="#current"/>
      <xsl:if test="not(position() eq last())">, </xsl:if>
   </xsl:template>
   
   <xsl:template match="date" mode="dhqBiblio:publisher-sequence">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   
   <xsl:template name="dhqBiblio:make-bibl-div">
      <xsl:param name="sentence-sequence" as="element(dhqBiblio:sentence)*"/>
      <div class="bibl dhqBiblio{local-name()}">
         <xsl:for-each select="$sentence-sequence[matches(.,'\S')]">
            <!--<xsl:variable name="string" select="normalize-space(.)"/>-->
            <xsl:if test="position() gt 1">
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:copy-of select="child::node()" copy-namespaces="no"/>
            <xsl:if test="not(matches(string(.),'[!\?\.]\s*$'))">.</xsl:if>
         </xsl:for-each>
      </div>
   </xsl:template>
   
   
   
   <!--<xsl:template name="dhqBiblio:emit-sentence">
      <xsl:param name="in" as="node()*"/>
      <dhqBiblio:sentence>
        <xsl:sequence select="$in"/>
      </dhqBiblio:sentence>
   </xsl:template>-->

   
   
   <!--
      element-model.contributors =
        ( # element contributor { givenName, familyName }* |
          author |
          editor )*,
          translator*,
          etal?-->
   
   <!-- element-model.title =
    title, additionalTitle*, formalID*
    
    element-model.published =
    place?, publisher?, date?


  -->

</xsl:stylesheet>

