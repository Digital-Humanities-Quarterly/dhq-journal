<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dhq="http://digitalhumanities.org/dhq/ns/biblio/util"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:dhxo="http://digitalhumanities.org/dhq/ns/xonomy-rng"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  
<!--  PARAMETERS  -->
<!--  VARIABLES  -->
  <xsl:variable name="biblio-schema" select="doc('../dhqBiblio.rng')"/>
  <xsl:variable name="valid-elements" as="xs:string*">
    <xsl:variable name="allElements" select="$biblio-schema//rng:element/@name/data(.)"/>
    <xsl:copy-of select="distinct-values($allElements)"/>
  </xsl:variable>
  <xsl:variable name="biblio-items" 
    select="$biblio-schema//rng:element[dhxo:class/@key[matches(.,'\.BiblioItem$')]]
                            /@name/data(.)"/>
  <xsl:variable name="genres" 
    select="$biblio-schema//rng:element[dhxo:class/@key[matches(.,'\.(Biblio|Macro)Item$')]]
                            /@name/data(.)"/>
  <xsl:variable name="contributors" 
    select="$biblio-schema//rng:element[dhxo:class/@key[ends-with(.,'.Contributor')]]
                            /@name/data(.)"/>
  
  
<!--  TEMPLATES  -->
  
  <xsl:template match="*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:variable name="results">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:copy-of select="$results"/>
  </xsl:template>
  
  <!-- If the input document includes a BiblioSet, wrap the results of validation. -->
  <xsl:template match="BiblioSet[dhq:is-ready(.)]" name="process-set">
    <xsl:param name="isOuterSet" select="true()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="results" as="node()*">
      <xsl:call-template name="sort-biblio-set">
        <xsl:with-param name="isOuterSet" select="false()" tunnel="yes"/>
        <xsl:with-param name="isImpliedReady" select="true()" tunnel="yes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="validResults" select="$results[dhq:is-ready(.)]" as="node()?"/>
    <xsl:variable name="invalidResults" as="node()*">
      <xsl:variable name="allInvalidSets" select="$results[not(dhq:is-ready(.))]"/>
      <xsl:for-each select="$allInvalidSets">
        <!-- If a BiblioSet is itself invalid, copy it forward without condensing its results. -->
        <xsl:copy-of select="if ( dhq:is-invalid(.) ) then . else *"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <!-- If this BiblioSet is the root Set with both valid and invalid items, replace this node with a 
        "ready" BiblioSet inside an explicitly not-ready Set. -->
      <xsl:when test="$isOuterSet and count($results) gt 1">
        <xsl:message terminate="no" select="count($results)"></xsl:message>
        <BiblioSet ready="false">
          <xsl:copy-of select="$validResults"/>
          <!-- We don't need a nested BiblioSet for the invalid results. -->
          <xsl:copy-of select="$invalidResults"/>
        </BiblioSet>
      </xsl:when>
      <!-- If this BiblioSet is the child of a not-ready Set, and there are no valid items, create an 
        empty, "ready" BiblioSet. -->
      <xsl:when test="not($isOuterSet) and parent::BiblioSet[not(dhq:is-ready(.))] and not(exists($validResults))">
        <BiblioSet ready="true">
          <xsl:call-template name="prevent-self-closing"/>
        </BiblioSet>
        <xsl:copy-of select="$results"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$results"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Items are not processed when their parent BiblioSet is not marked for publication. -->
  <xsl:template match="BiblioSet[not(dhq:is-ready(.))]">
    <xsl:param name="isImpliedReady" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="results" as="node()*">
      <xsl:apply-templates mode="copy">
        <xsl:with-param name="isOuterSet" select="false()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="validSets" select="$results[self::BiblioSet][dhq:is-ready(.)]" as="node()*"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- BiblioSets nested inside a "ready" BiblioSet must also be marked as "ready". -->
      <xsl:if test="$isImpliedReady">
        <xsl:call-template name="convey-warning">
          <xsl:with-param name="message">BiblioSets nested inside a “ready” BiblioSet must also be marked as “ready.”</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <!-- Valid BiblioSets are condensed into a single ready Set at the top of this BiblioSet. -->
      <xsl:if test="$validSets">
        <BiblioSet ready="true">
          <xsl:copy-of select="$validSets/node()"/>
        </BiblioSet>
      </xsl:if>
      <!-- Invalid or unvalidated Biblio items become direct children of this BiblioSet. -->
      <xsl:copy-of select="$results[self::BiblioSet][not(dhq:is-ready(.))]/* 
                         | $results[self::*][not(self::BiblioSet)]"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="BiblioSet/BiblioSet[not(*)]" priority="20"/>
  
  <!-- All elements should be represented in the Biblio schema. -->
  <xsl:template match="*[not(local-name(.) = $valid-elements)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="convey-warning">
        <xsl:with-param name="message">“<xsl:value-of select="local-name()"/>” is not a valid Biblio element.</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Test for the generic, genre-less placeholder elements. -->
  <xsl:template match="BiblioItem | macroItem" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="convey-warning">
        <xsl:with-param name="message">“<xsl:value-of select="local-name()"/>” is not a valid genre.</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Significant text is not allowed as the child of container elements (items, contributors). -->
  <xsl:template match="*[local-name() = ($genres, $contributors)][text()[matches(.,'\S')]]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="convey-warning">
        <xsl:with-param name="message">All words in “<xsl:value-of select="local-name()"/>” must be wrapped.</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Titles, dates and notes must not be empty. -->
  <xsl:template match="title[normalize-space(.) eq ''] 
                      | date[normalize-space(.) eq ''] 
                      | note[normalize-space(.) eq '']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="convey-warning">
        <xsl:with-param name="message">“<xsl:value-of select="local-name()"/>” must not be empty.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="prevent-self-closing"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Ensure that there's only one @ID inside a Biblio item. -->
  <xsl:template match="@ID[parent::*[ancestor::*[@ID][not(self::BiblioSet)]]]" priority="5">
    <xsl:copy/>
    <xsl:call-template name="convey-warning">
      <xsl:with-param name="message">There should not be two ID attributes within a single Biblio item.</xsl:with-param>
      <xsl:with-param name="for-attribute" select="true()"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- <biblioRef>s are copied forward. -->
  <xsl:template match="BiblioSet/biblioRef">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
<!-- COPY MODE -->
  
  <!-- Ready BiblioSets should be processed with the default mode. -->
  <xsl:template match="BiblioSet[dhq:is-ready(.)]" mode="copy">
    <xsl:param name="isImpliedReady" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:choose>
      <!-- Since only not-ready BiblioSets trigger "copy" mode, we can be sure that if $isImpliedReady 
        has been thrown, we are in an erroneous Set, and should continue copying nodes. -->
      <xsl:when test="$isImpliedReady">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process-set"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
<!--  TEMPLATES, NAMED  -->
  
  <!-- Create an attribute to carry validation warnings back to the Xonomy interface. -->
  <xsl:template name="convey-warning">
    <xsl:param name="for-attribute" select="false()" as="xs:boolean"/>
    <xsl:param name="message" as="xs:string"/>
    <xsl:variable name="messageAttr">
      <xsl:text>validation-message</xsl:text>
      <xsl:value-of select="if ( $for-attribute ) then concat('-', name(.)) else ()"/>
    </xsl:variable>
    <xsl:attribute name="{$messageAttr}">
      <xsl:value-of select="$message"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- The Xonomy editor makes all empty elements into self-closing tags. To prevent this behavior (and 
    allow drag-and-drop and inline editing), insert a text node that is a single space. -->
  <xsl:template name="prevent-self-closing">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- Sort the children of a BiblioSet into groups of valid and invalid Biblio items. Items from nested 
    BiblioSets bubble up into a single BiblioSet representing the given validity status. -->
  <xsl:template name="sort-biblio-set">
    <xsl:variable name="results" as="node()*">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="validResults" as="node()*">
      <xsl:copy-of select="$results[self::BiblioSet][dhq:is-ready(.)]/*"/>
      <xsl:copy-of select="$results[self::*[not(self::BiblioSet)]]
                                   [not(dhq:has-warnings(.))]"/>
    </xsl:variable>
    <xsl:variable name="invalidResults" as="node()*">
      <xsl:copy-of select="$results[self::BiblioSet][not(dhq:is-ready(.)) and not(dhq:is-invalid(.))]/*"/>
      <xsl:copy-of select="$results[self::*][dhq:is-invalid(.) or dhq:has-warnings(.)]"/>
    </xsl:variable>
    <xsl:if test="$validResults">
      <BiblioSet ready="true">
        <xsl:copy-of select="$validResults"/>
      </BiblioSet>
    </xsl:if>
    <xsl:if test="$invalidResults">
      <BiblioSet ready="false">
        <xsl:copy-of select="$invalidResults"/>
      </BiblioSet>
    </xsl:if>
  </xsl:template>
  
  
<!--  FUNCTIONS  -->
  
  <!-- Decide if a portion of an XML tree has validation messages. -->
  <xsl:function name="dhq:has-warnings" as="xs:boolean">
    <xsl:param name="fragment" as="node()"/>
    <xsl:value-of 
      select="exists($fragment[descendant-or-self::*[dhq:is-invalid(.)]])"/>
  </xsl:function>
  
  <!-- Decide if an element or its attributes are invalid. -->
  <xsl:function name="dhq:is-invalid" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of 
      select="exists($element[@*[starts-with(local-name(), 'validation-message') or local-name() eq 'duplicate-id']])"/>
  </xsl:function>
  
  <!-- Decide if a set should be considered "ready" (as in, for ingestion). -->
  <xsl:function name="dhq:is-ready" as="xs:boolean">
    <xsl:param name="set" as="element(BiblioSet)"/>
    <xsl:value-of select="exists($set[@ready eq 'true'])"/>
  </xsl:function>
  
</xsl:stylesheet>