<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  queryBinding="xslt2">

<!-- this schematron checks to see whether the validation is pointing to a local schema or to the public version on the web; since the authoring template points to a web-accessible schema, we need to check to be sure we've changed the schema reference to point locally during our internal workflow -->

   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <ns prefix="cc"  uri="http://web.resource.org/cc/"/>
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <ns prefix="xs"  uri="http://www.w3.org/2001/XMLSchema"/>
  
  <pattern id="top-level">
<!-- Cannot put up with hrefs to http: in
      <?oxygen RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"?>
      <?oxygen SCHSchema="../../common/schema/dhqTEI-ready.sch"?>
      <?xml-model href="../../toc/toc-xml.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    
    -->
    <!--<?oxygen RNGSchema="../../common/schema/DHQauthor-TEI.rng" type="xml"?>
    <?oxygen SCHSchema="../../common/schema/dhqTEI-ready.sch"?>-->
    <rule context="/processing-instruction()">
      <report test="matches(.,'(RNGSchema|SCHSchema|href)=&quot;http')" role="warning">
        Processing instruction points to the Internet - this file will not be portable.
      </report>
      
    </rule>
  </pattern>

  
</schema>
