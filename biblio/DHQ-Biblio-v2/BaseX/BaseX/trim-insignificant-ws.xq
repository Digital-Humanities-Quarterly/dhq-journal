(: Strips whitespace-only text nodes children from elements deemed
   to be "safe" inasmuch as no elements of their type have
   non-whitespace text node children.
   
   So if 'section' elements have element-only content, they are
   safe and section/text() nodes are stripped.
   
   Also strips comments and PIs. :)

let $safe := 
  for $e in //*
  let $n := name($e)
  group by $n
  return $e[empty($e/text()[normalize-space(.)])]
  
return delete node $safe/text()[not(normalize-space(.))],
       delete node //processing-instruction(),
       delete node //comment(),
       db:optimize('Timesheets')