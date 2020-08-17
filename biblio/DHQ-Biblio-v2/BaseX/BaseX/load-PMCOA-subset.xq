declare option output:item-separator '\n';

(:for $i in (1 to 134131)[. mod 135 eq 0]
let $d := db:open('PMC-OA')[$i]:)

(:<fileList dir="F:\Data\PMC-OA"> {
file:list('F:\Data\PMC-OA', true(), '*.nxml') ! <file>{.}</file>
}</fileList>:)

(:db:create('PMCOA-selection',
  file:list('F:\Data\PMC-OA', true(), '*.nxml')[position() mod 740 eq 0]
  ! ('F:\Data\PMC-OA\' || .) ):)

(:return db:add('PMCOA-selection', $d, document-uri($d)):)
 
(: <file>AAPS_J\AAPS_J_2008_Apr_25_10(2)_229-241.nxml</file> :)

let $dirs := doc('file:/F:Data/PMC-OA/fileList-grouped.xml')/*/dir
for $d in $dirs
where (number($d/@fileCount) ! (. lt 1000 and . gt 500))
order by number($d/@fileCount) descending
return $d/string-join((@name,@fileCount),':')