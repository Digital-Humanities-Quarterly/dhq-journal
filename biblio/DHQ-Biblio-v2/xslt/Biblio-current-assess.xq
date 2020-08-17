declare default element namespace "http://digitalhumanities.org/dhq/ns/biblio";

let $current-files := collection('file:/E:/Data/DHQ/SVN/dhq/trunk/biblio/DHQ-Biblio-v2/data/current')
(:let $merging-files := collection('file:/E:/Data/DHQ/SVN/dhq/trunk/biblio/DHQ-Biblio-v2/data/current/merging')
let $legacy-files := collection('file:/E:/Data/DHQ/SVN/dhq/trunk/biblio/DHQ-Biblio-v2/data/current/legacy'):)

return 


for $b in $current-files/BiblioSet/*
let $id := $b/@ID
group by $id
return
  (if (count($b) gt 1) then $id else ())
