import module namespace sk = "http://wendellpiez.com/ns/DocSketch" at "xquery/docsketch.xqm";

(: declare default element namespace "http://www.w3.org/1999/xhtml"; :)
declare namespace svg = "http://www.w3.org/2000/svg";

let $doc          := db:open("LMNL-samples","Frankenstein.xlmnl")
let $testPipeline :=
  ( sk:fetch-xslt('frankenstein-hierarchies-svg.xsl'),
    sk:fetch-xslt('dhq-docsketch-svg.xsl')[false()]  )

return

sk:run-xslt-pipeline($doc,$testPipeline,())