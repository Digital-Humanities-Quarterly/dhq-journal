(: For generating a clean list of DHQ article files for batch processing
   in an oXygen project:
  
   1. Update article count
   2. Run to generate a 'folder' element
   3. Paste (by hand) into the 'projectTree' element
      of an oXygen project file such as DHQarticles.xpr
   4. Open the project in oXygen and validate or transform as needed

Requires XQuery 3.0
wap, 20140325

 :)

<folder name="articles">{
  for $i in (1 to 212)
  let $f := format-number($i,'000000')
  return <file name="{$f}/{$f}.xml"/> }
</folder>