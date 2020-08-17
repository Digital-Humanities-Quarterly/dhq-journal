<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xs mods"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  version="2.0"
  >

  <xsl:output indent="yes"/>
  
  <xsl:strip-space elements="*"/>
  
  <xsl:param name="runtime-scope" select="'basex'"/>
  
  <xsl:template match="* | xsl:*" mode="#default copy">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | comment() | processing-instruction()" mode="#default copy">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="text()" mode="#default copy">
    <xsl:copy-of select="normalize-space(string(.))"/>
  </xsl:template>
  
<!--  <xsl:variable name="mapped-genres" as="element()+">
    <genre>Journal Article</genre>
    <genre>Book Section</genre>
  </xsl:variable>
-->  

  <xsl:variable name="mapped-genres" select="(
    'Journal Article','Book','Psellos Book','Book Section', 'Book in Series','Conference Paper',
    'Website','Blog Entry','Artwork','Manuscript','Video Game')"/>
  

  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Journal Article']">
    <JournalArticle>
      <xsl:call-template name="biblioContents"/>
    </JournalArticle>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)=('Book','Psellos Book')]">
    <!-- The so-called 'Psellos Book', DHQ-125, is a book -->
    <Book>
      <xsl:call-template name="biblioContents"/>
    </Book>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Book Section']">
    <BookSection>
      <xsl:call-template name="biblioContents"/>
    </BookSection>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Book in Series']">
    <BookInSeries>
      <xsl:call-template name="biblioContents"/>
    </BookInSeries>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Conference Paper']">
    <ConferencePaper>
      <xsl:call-template name="biblioContents"/>
    </ConferencePaper>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Website']">
    <WebSite>
      <xsl:call-template name="biblioContents"/>
    </WebSite>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Manuscript']">
    <!-- The only Manuscript, DHQ-462, is a PhD thesis. -->
    <Thesis>
      <xsl:call-template name="biblioContents"/>
    </Thesis>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Blog Entry']">
    <BlogEntry>
      <xsl:call-template name="biblioContents"/>
      <!--<xsl:copy-of select="."/>-->
    </BlogEntry>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Artwork']">
    <Artwork>
      <xsl:call-template name="biblioContents"/>
      <!--<xsl:copy-of select="."/>-->
    </Artwork>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Video Game']">
    <VideoGame>
      <xsl:call-template name="biblioContents"/>
      <!--<xsl:copy-of select="."/>-->
    </VideoGame>
  </xsl:template>
  
  <xsl:template name="biblioContents">
    <xsl:apply-templates select="mods:identifier"/>
    <xsl:apply-templates select="mods:originInfo/mods:issuance"/>
    <xsl:apply-templates select="mods:genre | mods:typeOfResource"/>

    <!--<contributors>-->
    <xsl:apply-templates select="mods:name"/>
    <!--</contributors>-->
    <xsl:apply-templates select="mods:titleInfo"/>

    <xsl:apply-templates select="mods:originInfo/(* except mods:issuance)"/>

    <xsl:apply-templates select="mods:relatedItem[@type='host']"/>

    <xsl:apply-templates select="mods:part, mods:location"/>

    <xsl:apply-templates select="mods:subject, mods:physicalDescription"/>

    <xsl:apply-templates select="mods:recordInfo"/>

    <xsl:apply-templates select="mods:abstract | mods:note"/>

    <xsl:apply-templates mode="unmapped"
      select="* except
        ( mods:identifier,
          (mods:genre | mods:typeOfResource),
          mods:name, mods:titleInfo, mods:originInfo,
          mods:relatedItem[@type='host'],
          mods:part, mods:location,
          mods:subject, mods:physicalDescription,
          mods:recordInfo, (mods:abstract | mods:note) )"
    />
  </xsl:template>
  
  <xsl:template match="mods:genre[@authority='biblio'][normalize-space(.) = $mapped-genres]"/>
  
  <xsl:template match="mods:genre[@authority='marcgt']"/>
  
  <xsl:template match="mods:genre[.='PhD Thesis']"/>
  
  <xsl:template match="mods:subject"/>
  
  <xsl:template match="mods:physicalDescription"/>
  
  <!-- Implicit in the genre type -->
  <xsl:template match="mods:typeOfResource"/>
    
  
  <xsl:template match="mods:identifier[@type='biblio']">
    <xsl:attribute name="biblioID" select="replace(.,'\.xml$','')"/>
  </xsl:template>
  
  <!--<xsl:template match="mods:identifier[@type='local']">
    <xsl:attribute name="localID" select="."/>
  </xsl:template>-->
  
  <!-- These are currently only placeholders -->
  <xsl:template match="mods:identifier[@type='dhq']">
    <xsl:if test="normalize-space(.)">
      <xsl:attribute name="dhqID" select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='author-date']">
    <xsl:if test="normalize-space(.)">
      <xsl:attribute name="dhqCode" select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type=('author-date-titleletters','dhqlong')]">
    <xsl:if test="normalize-space(.)">
      <xsl:attribute name="dhqLongCode" select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:name[some $v in mods:namePart
    satisfies matches($v,'^et\s+al\.?$')]" priority="2">
    <etal/>
  </xsl:template>
  
  <xsl:template match="mods:name[@type='conference']">
    <conference>
      <xsl:apply-templates/>
      <!-- acquiring sponsor -->
      <xsl:apply-templates select="../mods:name[@type='corporate']/mods:namePart"/>
      <!-- and sibling date -->
      <xsl:apply-templates select="../mods:part/mods:date"/>
    </conference>
  </xsl:template>
  
  <xsl:template match="mods:name">
    <xsl:element name="{ (mods:role/mods:roleTerm/lower-case(.),'contributor')[1] }">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mods:name[@type='corporate']/mods:namePart">
    <sponsor>
      <xsl:apply-templates/>
    </sponsor>
  </xsl:template>
  
  <!-- called into sibling conference -->
  <xsl:template match="mods:mods[mods:genre[@authority='biblio']/normalize-space(.)='Conference Paper']/mods:name[@type='corporate']"/>
  
  <xsl:template match="mods:role"/>
  
  <xsl:template match="mods:namePart[exists(@type)]">
    <xsl:element name="{@type}Name">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mods:namePart">
    <name>
      <xsl:apply-templates/>
    </name>
  </xsl:template>
  
  <xsl:template match="mods:titleInfo">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']" priority="1">
    <source>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </source>
  </xsl:template>
  
  <xsl:template priority="2" 
    match="mods:relatedItem[@type='host'][mods:originInfo/mods:issuance='continuing']">
    <publication>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </publication>
  </xsl:template>
  
  <xsl:template priority="2" 
    match="mods:relatedItem[@type='host'][mods:originInfo/mods:issuance='monographic']">
    <book>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </book>
  </xsl:template>
  
  <xsl:template priority="3" 
    match="mods:relatedItem[@type='host'][ancestor::mods:mods/mods:genre[@authority='biblio']/normalize-space(.)='Conference Paper']">
    <publication>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </publication>
  </xsl:template>
  
  <xsl:template priority="3" 
    match="mods:relatedItem[@type='host'][ancestor::mods:mods/mods:genre[@authority='biblio']/normalize-space(.)='Book in Series']">
    <series>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </series>
  </xsl:template>
  
  <xsl:template priority="3" 
    match="mods:relatedItem[@type='host'][ancestor::mods:mods/mods:genre[@authority='biblio']/normalize-space(.)='Journal Article']">
    <journal>
      <xsl:apply-templates select="mods:originInfo"/>
      <xsl:apply-templates select="* except mods:originInfo"/>
    </journal>
  </xsl:template>
  
  <xsl:template match="mods:title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  <xsl:template match="mods:subTitle">
    <additionalTitle>
      <xsl:apply-templates/>
    </additionalTitle>
  </xsl:template>
  
  
  <xsl:template match="mods:originInfo">
    <xsl:apply-templates/>  
  </xsl:template>
  
  <xsl:template match="mods:originInfo/mods:issuance">
    <xsl:attribute name="issuance">
      <xsl:apply-templates/>
    </xsl:attribute>  
  </xsl:template>
  
  <!--<xsl:template priority="2" 
    match="mods:relatedItem[@type='host']/mods:originInfo/mods:issuance"/>-->
  
  <xsl:template match="mods:part">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- date acquired into sibling mods:name[@type='conference'] -->
  <xsl:template match="mods:mods[mods:name/@type='conference']/mods:part">
    <xsl:apply-templates select="* except mods:date"/>
  </xsl:template>
  
  <xsl:template match="mods:detail[@type='volume']">
    <volume>
      <xsl:apply-templates/>
    </volume>
  </xsl:template>
  
  <xsl:template match="mods:detail[@type='issue']">
    <issue>
      <xsl:apply-templates/>
    </issue>
  </xsl:template>
  
  <xsl:template match="mods:publisher">
    <publisher>
      <xsl:apply-templates/>
    </publisher>
  </xsl:template>
  
  <xsl:template match="mods:place">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mods:place/mods:placeTerm">
    <place>
      <xsl:apply-templates/>
    </place>
  </xsl:template>
  
  <xsl:template match="mods:date | mods:dateIssued">
    <date>
      <xsl:apply-templates/>
    </date>  
  </xsl:template>
  
  <xsl:template match="mods:extent[@unit='pages']">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mods:extent[@unit='pages']/mods:start">
    <startingPage>
      <xsl:apply-templates/>
    </startingPage>
  </xsl:template>
  
  <xsl:template match="mods:extent[@unit='pages']/mods:end">
    <endingPage>
      <xsl:apply-templates/>
    </endingPage>
  </xsl:template>
  
  <xsl:template match="mods:extent[@unit='pages']/mods:total">
    <totalPages>
      <xsl:apply-templates/>
    </totalPages>
  </xsl:template>

  <xsl:template match="mods:location">
    <xsl:apply-templates/>  
  </xsl:template>
  
  <xsl:template match="mods:url">
    <url>
      <xsl:apply-templates/>
    </url>
  </xsl:template>
  
  
  <xsl:template match="mods:recordInfo">
    <xsl:apply-templates select="." mode="unmapped">
      <xsl:with-param name="in-scope" select="false()"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="mods:note">
    <note>
      <xsl:apply-templates/>
    </note>  
  </xsl:template>
  
  <xsl:template match="mods:abstract">
    <!-- Element 'abstract' has been (ab)used as a bucket placeholder, but we preserve
         it rather than throw it away. -->
    <abstract>
      <xsl:apply-templates/>
    </abstract>  
  </xsl:template>
  
  <xsl:template match="mods:number">
    <xsl:apply-templates/>  
  </xsl:template>
  
  <xsl:template match="mods:mods">
    <xsl:apply-templates select="." mode="unmapped">
      <xsl:with-param name="in-scope" select="$runtime-scope=('basex','fileset')"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="mods:mods" mode="copy">
    <xsl:copy>
      <xsl:copy-of select="mods:genre"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="processing-instruction()[name()='xml-model']"/>
  

  <xsl:template match="*" mode="unmapped">
    <xsl:param name="in-scope" as="xs:boolean" select="true()"/>
    <xsl:if test="$in-scope">
      <xsl:apply-templates select="." mode="copy"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="dhq_biblio">
    <BiblioSet>
      <xsl:apply-templates/>
    </BiblioSet>
  </xsl:template>
</xsl:stylesheet>