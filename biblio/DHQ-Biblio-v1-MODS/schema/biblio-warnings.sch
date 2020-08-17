<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  
  <ns prefix="mods" uri="http://www.loc.gov/mods/v3"/>
  
  <pattern>
    <rule context="*">
      <assert test="exists(*|text()[normalize-space()])">
        Element '<name/>' has no value.
      </assert>
    </rule>
  </pattern>
  
  <pattern>
    <rule context="mods:name">
      <assert test="exists(mods:namePart)">
        '<name/>' is given with no name part(s).
      </assert>
      <assert test="exists(mods:role)" role="warning">
        '<name/>' is given with no role.
      </assert>
    </rule>
    <rule context="mods:namePart">
      <report test="matches(.,'^.\.?$')" role="warning">
        '<name/>' has only initial.
      </report>
    </rule>
  </pattern>
  
</schema>