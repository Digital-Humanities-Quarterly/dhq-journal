<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron">

  <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>

  <let name="TEI-elements" value="document('DHQauthor-TEI.rng')//rng:element"/>

  <pattern>
    <rule context="tei:gi[@scheme='TEI']">
      <assert test=". = $TEI-elements/@name"><value-of select="."/> does not
        appear in the DHQ-TEI schema</assert>
    </rule>
  </pattern>
</schema>
