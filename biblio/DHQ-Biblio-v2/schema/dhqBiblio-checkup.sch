<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
<!-- 
  
  For this to run, your environment must support:
    Schematron with foreign namespace elements
    XSLT 2.0
  
  -->

  <xsl:include href="dhqBiblio-schematron-util.xsl"/>
   
  <ns prefix="biblio" uri="http://digitalhumanities.org/dhq/ns/biblio"/>
  
  <let name="filePath" value="'../data/current'"/>
  
  <let name="file" value="/"/>
  
  <let name="documentSet" value="collection(concat($filePath,'?select=*.xml;recurse=yes;on-error=ignore'))
    [not(document-uri(.) = document-uri($file))] | $file"/>
  
  <!--<pattern>
    <rule context="/*">
      <report test="true()">
        Found <value-of select="count($documentSet/*/*)"/> entries
      </report>
    </rule>
  </pattern>-->
  
  <let name="allEntries" value="$documentSet//*[exists(@ID)]"/>
  
  <pattern>
    <rule context="*[exists(@ID)]">
      <!--<report test="true()">I see 
        <value-of select="count($allEntries)"/> entries; they are <value-of select="dhq:emit-sequence(distinct-values($allEntries/name()),'and')"/>/>
      </report>-->
      <!--<report test="true()">
        <value-of select="count($allEntries[@ID eq current()/@ID])"/>
      </report>-->
      <let name="rivals" value="($allEntries except .)[@ID eq current()/@ID]"/>
      <assert test="empty($rivals)">
        dhqID '<value-of select="@ID"/>' is also assigned to another entry; see
        <value-of select="biblio:report-entries($rivals)"/>
      </assert>
      
    </rule>
    
     <rule context="*[exists(@ID)]/biblio:title">
      <let name="allOtherEntries" value="$allEntries except .."/>
        <let name="flattened" value="biblio:flatten-string(.)"/>
        <let name="ilk" value="$allOtherEntries[biblio:title/biblio:flatten-string(.) = $flattened]"/>
      <!--<report test="true()">Boo!</report>-->
      <assert role="warning" test="empty($ilk)">
        <value-of select="name(.)"/> has a title similar to another entry's. Look in
         <value-of select="biblio:report-entries($ilk)"/>
      </assert>
    </rule>
  </pattern>

  
</schema>