<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  
  <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <sch:ns prefix="dhq" uri="http://www.digitalhumanities.org/ns/dhq"/>
  <sch:ns prefix="cc"  uri="http://web.resource.org/cc/"/>
  <sch:ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  <sch:ns prefix="xs"  uri="http://www.w3.org/2001/XMLSchema"/>
  
  <sch:let name="lang-codes" value="/*/tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident/string()"/>
  
  <sch:let name="lang-roles" value="('original','translation','translation_stub')"/>

  <!-- 20170515 wap
    
  Rules governing usage of @xml:lang on 'title' and 'text' elements
  
  * Report an error when a teiHeader has no profileDesc/langUsage/language descendants
  
  * Report an error when no langUsage/language element has @extent = 'original'
  
  * Report an error when a langUsage/language has any @extent but 'original', 'translation', or 'translation_stub' (an extensible list)
  
  * Report a warning when language/@ident is anything but a two-letter lower-case alphabetic code. (Note: schema may also validate this lexical form)
  
  * Report an error if any language/@ident is the same as a preceding sibling language/@ident
  
  * Report an error for any fileDesc/titleStmt that is missing titles assigned to given values of profileDesc/langUsage/language/@ident
  
  * Report an error if any title/@xml:lang is the same as a preceding sibling title/@xml:lang
  
  * Report an error for any title/@xml:lang that is not also given as profileDesc/langUsage/language/@ident
  
  * Report a warning on any @xml:lang on any title outside fileDesc/titleStmt
  
  * Report an error for any 'text' element that is both inside a group, and has a group (this ensures that only top-level text elements have group children)
  
  * Report an error for any 'text' element that has neither an @xml:lang, nor a 'group' child, if more than one language is declared for the article (as profileDesc/langUsage/language) - with an indication of the expected languages

  * Report an error for any 'text' element that has no 'group' child, unless its @xml:lang corresponds to one of the language codes declared
  
  * Report an error for any 'text' element that has both a 'group' child, and an @xml:lang
  
  -->
  <sch:pattern>
    <sch:rule context="tei:teiHeader">
      <sch:assert test="tei:profileDesc/tei:langUsage/tei:language">At least one language must be given in the profileDesc/langUsage</sch:assert>
    </sch:rule>
    
    <sch:rule context="tei:teiHeader/tei:profileDesc/tei:langUsage">
      <sch:assert test="tei:language/@extent='original'">At least one language must have @extent='original'</sch:assert>
    </sch:rule>
    <sch:rule context="tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language">
      <sch:assert test="@extent=$lang-roles">Unknown language/@extent '<sch:value-of select="@extent"/>'; should be one of
        <sch:value-of select="string-join($lang-roles,', ')"/></sch:assert>
      <sch:assert role="warning" test="matches(@ident,'^[a-z][a-z]$')">language code '<sch:value-of select="@ident"/>' should be two lower-case alphabetic characters</sch:assert>
      <sch:report test="@ident = preceding-sibling::*/@ident">language/@ident '<sch:value-of select="@ident"/>' appears repeatedly</sch:report>
    </sch:rule>
    
    <sch:rule context="tei:fileDesc/tei:titleStmt">
      <sch:let name="here" value="."/>
      <sch:let name="dropped-codes" value="$lang-codes[not(.=$here/tei:title/@xml:lang)]"/>
      <sch:let name="plural" value="if (count($dropped-codes) gt 1 ) then 's' else ''"/>
      <sch:assert test="empty($dropped-codes)">title<sch:value-of select="$plural"/> missing for
        language<sch:value-of select="$plural"/>:
        <sch:value-of select="string-join($dropped-codes, ' ')"/>
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:fileDesc/tei:titleStmt/tei:title">
      <sch:assert test="@xml:lang=$lang-codes">title/@xml:lang is expected to be a language given in profileDesc/langUsage: 
        <sch:value-of select="string-join($lang-codes, ' ')"/>
      </sch:assert>
      <sch:report test="@xml:lang=preceding-sibling::tei:title/@xml:lang">title/@xml:lang is repeated</sch:report>
    </sch:rule>
    
    <sch:rule context="tei:title">
      <sch:assert role="warning" test="empty(@xml:lang)">@xml:lang unexpected on title (outside the fileDesc/titleStmt)</sch:assert>
    </sch:rule>
    
    
    <sch:rule context="tei:text">
      <sch:assert test="empty(parent::tei:group) or empty(child::tei:group)">Inside a group, a text (element) may not have a group.</sch:assert>
      <sch:assert test="exists(tei:group|@xml:lang) or (count($lang-codes) le 1)">Inside 'text', a 'group' is expected to accommodate languages <sch:value-of select="string-join($lang-codes,', ')"/></sch:assert>
      <sch:assert test="exists(tei:group) or @xml:lang=$lang-codes">@xml:lang should be one of <sch:value-of select="string-join($lang-codes,', ')"/></sch:assert>
      <sch:report test="exists(tei:group) and exists(@xml:lang)">@xml:lang unexpected on text containing a group</sch:report>
      <sch:report test="@xml:lang = preceding-sibling::*/@xml:lang">text/@xml:lang '<sch:value-of select="@xml:lang"/>' appears repeatedly</sch:report>
    </sch:rule>
    
  </sch:pattern>
</sch:schema>