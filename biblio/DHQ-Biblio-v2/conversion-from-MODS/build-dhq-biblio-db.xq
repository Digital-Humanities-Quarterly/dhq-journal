declare namespace dhq = "http://digitalhumanities/dhq/ns/xquery/util";
declare default element namespace "http://digitalhumanities.org/dhq/ns/biblio";

let $biblioAll := doc('file:/C:/Work/Projects/DHQ/Biblio/DHQBiblio-generate/dhqBiblio-all.xml')

for $biblio in $biblioAll/*/*
let $name := $biblio/@ID/concat(.,'.xml')
 return
 (: db:add('dhq-Biblio-NG',$biblio,$name) :)
 $biblio
 
