xquery version "3.1";

(:  LIBRARIES  :)
  import module namespace provxq="http://digitalhumanities.org/dhq/ns/prov" 
    at "../apps/lib/prov.xql";
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace biblio="http://digitalhumanities.org/dhq/biblio-qa/prov#";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace prov="http://www.w3.org/ns/prov#";
  declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
(:  OPTIONS  :)
  declare option output:indent "yes";

(:~
  Test script as I build out functions in the PROV library.
  
  @author Ashley M. Clark
  2019-10
 :)
 
(:  VARIABLES  :)
  

(:  FUNCTIONS  :)
  

(:  MAIN QUERY  :)

let $e1id := xs:QName('biblio:brown2018')
let $entity1 :=
  provxq:entity($e1id, <prov:label xml:lang="en">This is a label</prov:label>)
let $e2id := xs:QName('biblio:brown2018a')
let $entity2 :=
  provxq:entity($e2id, "This is also a label", 'biblio-working', (), ())
let $activity :=
  provxq:activity(xs:QName('biblio:edit01'), (), (:current-dateTime:)(), "modification")
let $agent1 :=
  provxq:agent(xs:QName('biblio:aclark'), "Ashley Clark", (), ('prov:person'(:, 'prov:softwareAgent':)), ()(:, true():))
let $relations := (
    provxq:was-started-by((), $activity, $e1id, (), current-dateTime(), ()),
    provxq:was-derived-from((), $entity2, $entity1, ()(:$activity:), (), (), <prov:type>prov:Revision</prov:type>),
    provxq:was-invalidated-by((), $entity1, $activity),
    provxq:was-associated-with(xs:QName('biblio:assoc01'), $activity, $agent1),
    provxq:was-attributed-to((), $e2id, $agent1)
  )
let $specialization :=
  provxq:specialization-of($entity2, $e1id)
let $components := (
    namespace biblio { "http://digitalhumanities.org/dhq/biblio-qa/prov#" }, 
    $entity1, $entity2, (:$activity,:) $specialization, $agent1, $relations[2], $relations[last()]
  )
return
  provxq:document($components)
