<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <!-- 
  
  For this to run, your environment must support:
    Schematron with foreign namespace elements
    XSLT 2.0
  
  -->
  <xsl:include href="dhqBiblio-schematron-util.xsl"/>
   
  <!-- For background checking of Biblio files.
       The scope of the checks is limited to the file itself.
       
       Run dhqBiblio-checkup.sch for final checking against the aggregated data set.
       
       -->
  
  <ns prefix="biblio" uri="http://digitalhumanities.org/dhq/ns/biblio"/>
  
  <let name="allEntries" value="//*[exists(@ID)]"/>
  
  <pattern>
     <rule context="biblio:JournalArticle[exists(@dhqID)]">
        <assert test="matches(biblio:journal/biblio:title,'^Digital\s+Humanities\s+Quarterly$')">
           A @dhqID is assigned, but the journal title is not "Digital Humanities Quarterly".
        </assert>
     </rule> 
     <rule context="biblio:JournalArticle[empty(@dhqID)]">
        <report test="matches(biblio:journal/biblio:title,'DHQ|Digital\s+Humanities\s+Quarterly','i')">
           DHQ is cited but no @dhqID is assigned.
        </report>
     </rule> 
  </pattern>
   
</schema>