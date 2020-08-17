<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xmlns="http://digitalhumanities.org/dhq/ns/biblio"
  xpath-default-namespace="http://digitalhumanities.org/dhq/ns/biblio"
  version="2.0">
  
<!-- Biblio split: splits a Biblio file into result files by 
     initial letter of lead author|editor|creator|contributor -->
  
  <xsl:template match="/*">
    <xsl:for-each-group select="*" group-by="(.//(author|editor|creator|contributor)[normalize-space(.)]/upper-case(substring(normalize-space(.),1,1)),'blank')[1]">
      <xsl:result-document
        href="{resolve-uri(concat('../data/Biblio-',current-grouping-key(),'.xml'),document-uri(/))}"
        indent="yes">
        <xsl:copy-of select="/processing-instruction()"/>
        <BiblioSet>
          <xsl:copy-of select="current-group()"/>
        </BiblioSet>
      </xsl:result-document>
    </xsl:for-each-group>
  </xsl:template>
</xsl:stylesheet>