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
    <rule context="*[exists(@ID)]">
      <let name="rivals" value="($allEntries except .)[@ID eq current()/@ID]"/>
      <assert test="empty($rivals)">
        ID '<value-of select="@ID"/>' is also assigned to another entry; see &#x20;
        <value-of select="biblio:report-entries($rivals)"/>
      </assert>
      <assert test="exists((biblio:author|biblio:editor|biblio:creator)[normalize-space(.)])">
        Biblio <name/> has no author, editor or creator
      </assert>

      <let name="starts-okay" value="matches(@ID,'^[a-z]')"/>
      <assert test="$starts-okay">Biblio @ID does not start with a plain Latin lower-case letter (a-z)</assert>
      <assert role="warning" test="not($starts-okay) or matches(@ID,'^\p{Ll}+(-\p{Ll}+)?(\d{4}[a-z]?)?$')">Biblio @ID doesn't follow conventional form</assert>
    </rule>
    
     <rule context="*[exists(@ID)]/biblio:title">
      <let name="allOtherEntries" value="$allEntries except .."/>
      <let name="flattened" value="biblio:flatten-string(.)"/>
      <let name="dupe-checking" value="not(../@check-title-dupe='no')"/>
        <!-- $ilk is all entries with the same title ... when we are dupe checking (only) -->
      <let name="ilk" value="$allOtherEntries[biblio:title/biblio:flatten-string(.) = $flattened][$dupe-checking]"/>
      <!--<report test="true()">Boo!</report>-->
      <assert role="warning" test="empty($ilk)">
        <value-of select="name(.)"/> has a title similar to another entry's. Look in
        <value-of select="biblio:report-entries($ilk)"/>
      </assert>
    </rule>
     
     <rule context="biblio:BiblioSet">
        <assert test="exists(*)">BiblioSet has no items</assert>
        <assert test="not(@ready='true') or not(.//@ready='false')">BiblioSet is marked as 'ready' but it contains things marked not ready.</assert>
        <assert test="not(. is /*) or @ready='true' or not(matches(document-uri(/),'Biblio\-[A-Z]\.xml$'))" role="warning">
           "Biblio A-Z" files should be marked as ready (or expect failures in reallocation).
        </assert>
     </rule>
  </pattern>
  
   
  <pattern>
     <rule context="biblio:title">
        <report test="matches(.,'\.\s*$')" role="warning">Title ends with a period</report>
        <report test="matches(.,',\s*$')" role="warning">Title ends with a comma</report>
     </rule>
     
     <rule context="biblio:fullName[normalize-space(.)] | biblio:familyName[normalize-space(.)]">
        <assert test="string-length(.) gt 1"><name/> '<value-of select="."/>' appears implausible</assert>
     </rule>
     <rule context="biblio:fullName | biblio:familyName | biblio:givenName | biblio:corporateName">
        <assert test="matches(.,'\S')"><name/> must have content</assert>
     </rule>
     <rule context="biblio:publication">
        <assert test="exists(*)"><name/> should not be empty (it is optional)</assert>
     </rule>
  </pattern>
</schema>