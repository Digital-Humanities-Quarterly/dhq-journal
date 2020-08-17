<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  queryBinding="xslt2">


  <p>Checking a DHQ TEI article against Biblio.</p>

  <p>This checks a number of constraints on DHQauthor articles that we can't or
    don't want to check in the main schema, either because they interrogate
    attribute values (for example to check cross-referencing), or because they
    are not absolute rules, or they entail complex dependencies of one kind or
    another.</p>

  <!-- to do: migrate the old dhq-ready Schematron code into this -->
  <!-- Also check DHQ-TEI-diagnostic.sch for rules that should be
       in here -->

  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <ns prefix="cc"  uri="http://web.resource.org/cc/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="xs"  uri="http://www.w3.org/2001/XMLSchema"/>
  
  
   <let name="filePath" value="'../../biblio/DHQ-Biblio-v2/data/current'"/>
   
   <let name="file" value="/"/>
   
   <let name="allBiblio" value="collection(concat($filePath,'?select=*.xml;recurse=yes;on-error=ignore'))/*/*"/>
   
   <pattern>
      <rule context="tei:listBibl/tei:bibl">
         <assert test="exists(@key)" role="warning">No key is given for bibl.</assert>
         <assert test="empty(@key) or (@key = ('[unlisted]',$allBiblio/@ID))">No item with @ID
            of '<value-of select="@key"/>' is found in Biblio.</assert>
      </rule>
   </pattern>   

</schema>
