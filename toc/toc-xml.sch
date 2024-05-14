<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  <!--<sch:let name="toc-article-group-types" value="('editorials', 'articles', 'reviews', 'case_studies', 'frontmatter', 'issues', 'posters')"/>-->
  
  <sch:pattern>
    <!-- <sch:rule context="list">
      <sch:assert test="@id = $toc-article-group-types">list/@id is not one of 
        <sch:value-of select="string-join(for $t in ($toc-article-group-types) return concat('''',$t,''''), ', ')"/></sch:assert>
      <sch:report test="@id = preceding-sibling::*/@id">list/@id '<sch:value-of select="@id"/>' already appears
      inside this <sch:value-of select="name(..)"/>.</sch:report>
    </sch:rule>
    -->
    
    <sch:rule context="editors">
      <sch:assert test="matches(@n,'^[1-9]\d*$')">editors/@n must be 1 or more (whole numbers) - count the editors. (No leading zeros or extra space.)</sch:assert>
    </sch:rule>
    
    <sch:rule context="item">
      <sch:let name="expected-filepath" value="@id[matches(.,'^\c+')]/resolve-uri(concat('../articles/',.,'/',.,'.xml'),document-uri(/))"/>
      <sch:assert test="exists($expected-filepath)">Can't construct a path to a file from @id value '<sch:value-of select="@id"/>'</sch:assert>
      <sch:assert test="empty($expected-filepath) or unparsed-text-available($expected-filepath)">File not found at <sch:value-of select="$expected-filepath"/></sch:assert>
      <sch:assert test="empty($expected-filepath) or not(unparsed-text-available($expected-filepath)) or doc-available($expected-filepath)">File at <sch:value-of select="$expected-filepath"/> will not parse</sch:assert>
    </sch:rule>
    
  </sch:pattern>
  
</sch:schema>