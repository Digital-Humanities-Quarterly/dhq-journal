<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">

<title>Diagnostic utility Schematron</title>
  
  <p>For ad-hoc diagnostics of DHQ articles to support regression testing of stylesheets
     under development.</p>
 
  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <ns prefix="cc" uri="http://web.resource.org/cc/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>

   
  <pattern>
    <!--<rule context="tei:said">
      <report test="true()"><name/> element found</report>
    </rule>-->
    <rule context="tei:cit | tei:ref | tei:quote">
      <report test="matches(.,'^&#xa;')"><value-of select="name(.)"/> starts with LF character</report>
      <report test="matches(.,'&#xa;\s*$')"><value-of select="name(.)"/> ends with LF character</report>
    </rule>
    <!--<rule context="tei:quote">
      <report test="matches(.,'&#xa;')"><name/> contains LF character</report>
    </rule>-->
  </pattern>
  
</schema>
