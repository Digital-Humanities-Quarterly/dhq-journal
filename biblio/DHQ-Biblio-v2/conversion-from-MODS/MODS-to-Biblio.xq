(: Converts old Biblio MODS records into new DHQ Biblio format.
   Runs in BaseX (tested in v7.7)
   Wendell Piez, July-August 2013 :)

declare namespace dhq    = "http://digitalhumanities.org/dhq/ns/xquery/util";
declare namespace mods   = "http://www.loc.gov/mods/v3";
declare namespace biblio = "http://digitalhumanities.org/dhq/ns/biblio";

declare option db:chop 'no';
declare option output:separator '\n';


(: Recursively processes an XSLT pipeline as a sequence of XSLT references (passed in as a list of strings) :)
declare function dhq:run-xslt-pipeline($source as document-node(),
                                       $stylesheets as xs:string*,
                                       $params as map(*)? )
                 as document-node() {
   if (empty($stylesheets)) then $source
   else
      let $intermediate := dhq:run-xslt($source, $stylesheets[1], $params)
      return 
         if (exists($intermediate/EXCEPTION)) then $intermediate
         else dhq:run-xslt-pipeline($intermediate, remove($stylesheets,1),$params)
};

(: for robustness of execution, to catch Saxon errors and avoid BaseX runtime errors :)
declare function dhq:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { (# db:chop "yes"  #) { xslt:transform($source, $stylesheet, $params ) } }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};

let $xsltPath       := "file:/C:/Work/Projects/DHQ/Biblio/SVN/biblio/DHQ-Biblio-v2/transitional/"
let $extractXSLT    := $xsltPath || "dhqBiblio-extract.xsl"    (: extracts and maps MODS data to DHQ Biblio format :)
let $ameliorateXSLT := $xsltPath || "dhqBiblio-ameliorate.xsl" (: restructures and improves Biblio data :)
let $normalizeXSLT  := $xsltPath || "dhqBiblio-normalize.xsl"  (: normalizes Biblio reference types - only for diagnostics :)

let $pipeline := ( $extractXSLT,
                   $ameliorateXSLT [true()],
                   $normalizeXSLT  [false()])

let $biblioSet :=
  db:open('dhq_biblio_out')/

  dhq:run-xslt-pipeline(.,$pipeline, map { })

(: let $resultfile := 'file:///C:/Work/Projects/DHQ/Biblio/DHQBiblio-generate/dhqBiblio-all.xml':)

 (: $biblioSet//contributor/..:)

  (: file:write($resultfile,$biblioSet) :)
  
for $entry in $biblioSet/*/biblio:*
let $entryDoc := document { $entry }
return
  db:add('dhq-Biblio-NG',$entryDoc,$entry/@biblioID/concat(.,'.xml'))
  


(:  distinct-values($biblioSet/*//publication/string-join((*/name()[not(.=('author','editor','contributor','etal','title','additionalTitle'))]),'-')):)


 (: //mods:*/ancestor::*/@biblio-ID :)
