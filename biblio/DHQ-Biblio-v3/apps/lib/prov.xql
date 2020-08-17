xquery version "3.1";

  module namespace provxq="http://digitalhumanities.org/dhq/ns/prov";
(:  LIBRARIES  :)
(:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace dbib="http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace http="http://expath.org/ns/http-client";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace prov="http://www.w3.org/ns/prov#";
  declare namespace request="http://exquery.org/ns/request";

(:~
  Functions for expressing provenance through the W3C PROV data model and the PROV-XML schema.
  
  @author Ashley M. Clark, for Digital Humanities Quarterly
  @see https://www.w3.org/TR/prov-xml/
  2019-10
 :)
 
(:  VARIABLES  :)
  

(:  FUNCTIONS  :)
  
  (:~
    Construct a PROV-XML document from any given PROV expressions.
    
    @param components Any number of XML nodes which should be included in the document.
   :)
  declare function provxq:document($components as node()*) {
    element prov:document {
      attribute xsi:schemaLocation { 
        "http://www.w3.org/ns/prov# http://www.w3.org/ns/prov-core.xsd" 
      },
      if ( $components[self::text()] ) then $components
      else
        (: Add some newlines before each <prov:entity>, for readability. :)
        for tumbling window $w in $components
          start $s at $s-pos when $s-pos eq 1 or $s[self::prov:entity]
        return 
          if ( $s[self::prov:entity] ) then
            ( '&#x0A;&#x0A;', $w )
          else $w
    }
  };
  
 (:  PROV STRUCTURAL COMPONENTS  :)
  
  (:~
    Identify an activity.
    
    @param id A unique QName identifier.
    @param start-time An optional date and time at which the activity started.
    @param end-time An optional date and time at which the activity ended.
    @param label Any number of labels (QName, string, or <prov:label>).
    @return a custom <prov:activity>
   :)
  declare function provxq:activity($id as xs:QName, $start-time as xs:dateTime?, $end-time as xs:dateTime?, 
     $label as item()*) {
    provxq:activity($id, $start-time, $end-time, $label, (), (), ())
  };
  
  (:~
    Identify an activity.
    
    @param id A unique QName identifier.
    @param start-time An optional date and time at which the activity started.
    @param end-time An optional date and time at which the activity ended.
    @param label Any number of labels (QName, string, or <prov:label>).
    @param location Any number of location data (QName, string, or <prov:location>).
    @param type Any number of categorization data (QName, string, or <prov:type>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:activity>
   :)
  declare function provxq:activity($id as xs:QName, $start-time as xs:dateTime?, $end-time as xs:dateTime?, 
     $label as item()*, $location as item()*, $type as item()*, $additional-elements as element()*) {
    element prov:activity {
      provxq:set-prov-id($id),
      provxq:tag('startTime', $start-time),
      provxq:tag('endTime', $end-time),
      provxq:tag('label', $label),
      provxq:tag('location', $location),
      provxq:tag('type', $type),
      $additional-elements
    }
  };
  
  
  (:~
    Identify an agent.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @return a custom <prov:agent>
   :)
  declare function provxq:agent($id as xs:QName, $label as item()*) {
    provxq:agent($id, $label, (), (), (), true())
  };
  
  
  (:~
    Identify an agent. Besides the generic <prov:agent>, the subclasses <prov:organization>, <prov:person>, and 
    <prov:softwareAgent> are available by passing the relevant subclass through the $type parameter.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @param location Any number of location data (QName, string, or <prov:location>).
    @param type Any number of categorization data (QName, string, or <prov:type>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:agent>, <prov:organization>, <prov:person>, or <prov:softwareAgent>
   :)
  declare function provxq:agent($id as xs:QName, $label as item()*, $location as item()*, $type as item()*, 
     $additional-elements as element()*) {
    provxq:agent($id, $label, $location, $type, $additional-elements, false())
  };
  
  (:~
    Identify an agent. Besides the generic <prov:agent>, the subclasses <prov:organization>, <prov:person>, and 
    <prov:softwareAgent> are available by passing the relevant subclass through the $type parameter. The generic 
    tag can be preserved by setting $suppress-subclassing to false.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @param location Any number of location data (QName, string, or <prov:location>).
    @param type Any number of categorization data (QName, string, or <prov:type>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @param suppress-subclassing Whether or not to convert a PROV subclass from a <prov:type> to a wrapper tag.
    @return a custom <prov:agent>, <prov:organization>, <prov:person>, or <prov:softwareAgent>
   :)
  declare function provxq:agent($id as xs:QName, $label as item()*, $location as item()*, $type as item()*, 
     $additional-elements as element()*, $suppress-subclassing as xs:boolean) {
    let $subclasses := 
      if ( $suppress-subclassing ) then ()
      else ('prov:organization', 'prov:person', 'prov:softwareAgent')
    let $typeMap := provxq:tag-type($type, 'prov:agent', $subclasses)
    return
      element { $typeMap?('gi') } {
        provxq:set-prov-id($id),
        provxq:tag('label', $label),
        provxq:tag('location', $location),
        $typeMap?('types'),
        $additional-elements
      }
  };
  
  (:~
    Identify an entity.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @return a custom <prov:entity>
   :)
  declare function provxq:entity($id as xs:QName, $label as item()*) {
    provxq:entity($id, $label, (), (), ())
  };
  
  (:~
    Identify an entity. Besides the generic <prov:entity>, the subclasses <prov:bundle>, <prov:collection>, 
    <prov:emptyCollection>, and <prov:plan> are available by passing the relevant subclass through the $type 
    parameter.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @param location Any number of location data (QName, string, or <prov:location>).
    @param type Any number of categorization data (QName, string, or <prov:type>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:entity>, <prov:bundle>, <prov:collection>, <prov:emptyCollection>, or <prov:plan>
   :)
  declare function provxq:entity($id as xs:QName, $label as item()*, $location as item()*, $type as item()*, 
     $additional-elements as element()*) {
    provxq:entity($id, $label, $location, $type, $additional-elements, false())
  };
  
  (:~
    Identify an entity. Besides the generic <prov:entity>, the subclasses <prov:bundle>, <prov:collection>, 
    <prov:emptyCollection>, and <prov:plan> are available by passing the relevant subclass through the $type 
    parameter. The generic tag can be preserved by setting $suppress-subclassing to false.
    
    @param id A unique QName identifier.
    @param label Any number of labels (QName, string, or <prov:label>).
    @param location Any number of location data (QName, string, or <prov:location>).
    @param type Any number of categorization data (QName, string, or <prov:type>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @param suppress-subclassing Whether or not to convert a PROV subclass from a <prov:type> to a wrapper tag.
    @return a custom <prov:entity>, <prov:bundle>, <prov:collection>, <prov:emptyCollection>, or <prov:plan>
   :)
  declare function provxq:entity($id as xs:QName, $label as item()*, $location as item()*, $type as item()*, 
     $additional-elements as element()*, $suppress-subclassing as xs:boolean) {
    let $subclasses := 
      if ( $suppress-subclassing ) then ()
      else ('prov:bundle', 'prov:collection', 'prov:emptyCollection', 'prov:plan')
    let $typeMap := provxq:tag-type($type, 'prov:entity', $subclasses)
    return
      element { $typeMap?('gi') } {
        provxq:set-prov-id($id),
        provxq:tag('label', $label),
        provxq:tag('location', $location),
        $typeMap?('types'),
        $additional-elements
      }
  };
  
  
 (:  PROV RELATIONS  :)
  
  (:~
    Express that one entity shares all aspects of another, as well as other, unique aspects.
    
    @param specific-entity The entity which is the specialization (QName, string, <prov:entity>, or any Entity subclass).
    @param general-entity The generic entity (QName, string, <prov:entity>, or any Entity subclass).
    @return a custom <prov:specializationOf>
   :)
  declare function provxq:specialization-of($specific-entity as item(), $general-entity as item()) {
    element prov:specializationOf {
      provxq:point-to('prov:specificEntity', $specific-entity),
      provxq:point-to('prov:generalEntity', $general-entity)
    }
  };
  
  (:~
    Express that an agent had some association with, or responsibility for, an activity.
    
    @param id An optional unique identifier for this expression.
    @param activity The previously-identified activity (QName, string, or <prov:activity>).
    @param agent An optional previously-identified agent (QName, string, <prov:agent>, or any Agent subclass).
    @return a custom <prov:wasAssociatedWith> expression
   :)
  declare function provxq:was-associated-with($id as xs:QName?, $activity as item(), $agent as item()?) {
    provxq:was-associated-with($id, $activity, $agent, (), ())
  };
  
  (:~
    Express that an agent had some association with, or responsibility for, an activity.
    
    @param id An optional unique identifier for this expression.
    @param activity The previously-identified activity (QName, string, or <prov:activity>).
    @param agent An optional previously-identified agent (QName, string, <prov:agent>, or any Agent subclass).
    @param plan An optional previously-identified plan which defines steps taken in the activity (QName, string, <prov:entity>, or any Entity subclass).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasAssociatedWith> expression
   :)
  declare function provxq:was-associated-with($id as xs:QName?, $activity as item(), $agent as item()?, 
     $plan as item()?, $additional-elements as element()*) {
    element prov:wasAssociatedWith {
      provxq:set-prov-id($id),
      provxq:point-to('prov:activity', $activity),
      provxq:point-to('prov:agent', $agent),
      provxq:point-to('prov:plan', $plan),
      $additional-elements
    }
  };
  
  (:~
    Express that an entity's generation was in some way associated with an agent.
    
    @param id An optional unique identifier for this expression.
    @param entity The previously-identified entity (QName, string, <prov:entity>, or any Entity subclass).
    @param agent The previously-identified agent (QName, string, <prov:agent>, or any Agent subclass).
    @return a custom <prov:wasAttributedTo> expression
   :)
  declare function provxq:was-attributed-to($id as xs:QName?, $entity as item(), $agent as item()) {
    provxq:was-attributed-to($id, $entity, $agent, ())
  };
  
  (:~
    Express that an entity's generation was in some way associated with an agent.
    
    @param id An optional unique identifier for this expression.
    @param entity The previously-identified entity (QName, string, <prov:entity>, or any Entity subclass).
    @param agent The previously-identified agent (QName, string, <prov:agent>, or any Agent subclass).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasAttributedTo> expression
   :)
  declare function provxq:was-attributed-to($id as xs:QName?, $entity as item(), $agent as item(), 
     $additional-elements as element()*) {
    element prov:wasAttributedTo {
      provxq:set-prov-id($id),
      provxq:point-to('prov:entity', $entity),
      provxq:point-to('prov:agent', $agent),
      $additional-elements
    }
  };
  
  (:~
    Express that one entity was derived from another.
    
    @param id An optional unique identifier for this expression.
    @param generated-entity The previously-identified derived entity (QName, string, <prov:entity>, or any Entity subclass).
    @param used-entity The previously-identified source entity (QName, string, <prov:entity>, or any Entity subclass).
    @return a custom <prov:wasDerivedFrom> expression
   :)
  declare function provxq:was-derived-from($id as xs:QName?, $generated-entity as item(), $used-entity as item()) {
    provxq:was-derived-from($id, $generated-entity, $used-entity, (), (), (), (), true())
  };
  
  (:~
    Express that one entity was derived from another.
    
    @param id An optional unique identifier for this expression.
    @param generated-entity The previously-identified derived entity (QName, string, <prov:entity>, or any Entity subclass).
    @param used-entity The previously-identified source entity (QName, string, <prov:entity>, or any Entity subclass).
    @param activity An optional, previously-identified activity (QName, string, or <prov:activity>).
    @return a custom <prov:wasDerivedFrom> expression
   :)
  declare function provxq:was-derived-from($id as xs:QName?, $generated-entity as item(), $used-entity as item(), 
     $activity as item()?) {
    provxq:was-derived-from($id, $generated-entity, $used-entity, $activity, (), (), (), true())
  };
  
  (:~
    Express that one entity was derived from another. Besides the generic <prov:wasDerivedFrom>, the subclasses 
    <prov:hadPrimarySource>, <prov:wasQuotedFrom>, and <prov:wasRevisionOf> are available by passing the relevant 
    subclass as a <prov:type> in the $additional-elements parameter.
    
    @param id An optional unique identifier for this expression.
    @param generated-entity The previously-identified derived entity (QName, string, <prov:entity>, or any Entity subclass).
    @param used-entity The previously-identified source entity (QName, string, <prov:entity>, or any Entity subclass).
    @param activity An optional, previously-identified activity (QName, string, or <prov:activity>).
    @param generation An optional, previously-identified Generation relationship (QName, string, or <prov:wasGeneratedBy>).
    @param usage An optional, previously-identified Usage relationship (QName, string, or <prov:used>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasDerivedFrom>, <prov:hadPrimarySource>, <prov:wasQuotedFrom>, or <prov:wasRevisionOf> expression
   :)
  declare function provxq:was-derived-from($id as xs:QName?, $generated-entity as item(), $used-entity as item(), 
     $activity as item()?, $generation as item()?, $usage as item()?, $additional-elements as element()*) {
    provxq:was-derived-from( $id, $generated-entity, $used-entity, 
      $activity, $generation, $usage, $additional-elements, false() 
    )
  };
  
  (:~
    Express that one entity was derived from another. Besides the generic <prov:wasDerivedFrom>, the subclasses 
    <prov:hadPrimarySource>, <prov:wasQuotedFrom>, and <prov:wasRevisionOf> are available by passing the relevant 
    subclass as a <prov:type> in the $additional-elements parameter. The generic tag can be preserved by setting 
    $suppress-subclassing to false.
    
    @param id An optional unique identifier for this expression.
    @param generated-entity The previously-identified derived entity (QName, string, <prov:entity>, or any Entity subclass).
    @param used-entity The previously-identified source entity (QName, string, <prov:entity>, or any Entity subclass).
    @param activity An optional, previously-identified activity (QName, string, or <prov:activity>).
    @param generation An optional, previously-identified Generation relationship (QName, string, or <prov:wasGeneratedBy>).
    @param usage An optional, previously-identified Usage relationship (QName, string, or <prov:used>).
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @param suppress-subclassing Whether or not to convert a PROV subclass from a <prov:type> to a wrapper tag.
    @return a custom <prov:wasDerivedFrom>, <prov:hadPrimarySource>, <prov:wasQuotedFrom>, or <prov:wasRevisionOf> expression
   :)
  declare function provxq:was-derived-from($id as xs:QName?, $generated-entity as item(), $used-entity as item(), 
     $activity as item()?, $generation as item()?, $usage as item()?, $additional-elements as element()*, 
     $suppress-subclassing as xs:boolean) {
    let $relationSubclasses := map {
        'prov:PrimarySource': 'prov:hadPrimarySource',
        'prov:Quotation': 'prov:wasQuotedFrom',
        'prov:Revision': 'prov:wasRevisionOf'
      }
    let $subclasses := 
      if ( $suppress-subclassing ) then ()
      else map:keys($relationSubclasses)
    let $typeMap := 
      provxq:tag-type($additional-elements[self::prov:type], 'prov:wasDerivedFrom', $subclasses)
    let $useGi := $typeMap?('gi')
    let $useGi := 
      if ( not($suppress-subclassing) and $useGi = $subclasses ) then
        $relationSubclasses?($useGi)
      else $useGi
    return
      element { $useGi } {
        provxq:set-prov-id($id),
        provxq:point-to('prov:generatedEntity', $generated-entity),
        provxq:point-to('prov:usedEntity', $used-entity),
        provxq:point-to('prov:activity', $activity),
        $typeMap?('types'),
        $additional-elements[not(self::prov:type)]
      }
  };
  
  (:~
    Express that an activity was ended in response to an entity's generation.
    
    @param id An optional unique identifier for this expression.
    @param activity A previously-identified activity (QName, string, or <prov:activity>).
    @param trigger An optional, previously-identified entity which was generated before this activity ended (QName, string, <prov:entity>, or Entity subclass).
    @return a custom <prov:wasEndedBy> expression
   :)
  declare function provxq:was-ended-by($id as xs:QName?, $activity as item(), $trigger as item()?) {
    provxq:was-ended-by($id, $activity, $trigger, (), (), ())
  };
  
  (:~
    Express that an activity was ended in response to an entity's generation.
    
    @param id An optional unique identifier for this expression.
    @param activity A previously-identified activity (QName, string, or <prov:activity>).
    @param trigger An optional, previously-identified entity which was generated before this activity began (QName, string, <prov:entity>, or Entity subclass).
    @param ender An optional, previously-identified activity during which the trigger entity was created (QName, string, or <prov:activity>).
    @param time An optional date and time at which the activity ended.
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasEndedBy> expression
   :)
  declare function provxq:was-ended-by($id as xs:QName?, $activity as item(), $trigger as item()?, 
     $ender as item()?, $time as xs:dateTime?, $additional-elements as element()*) {
    element prov:wasStartedBy {
      provxq:set-prov-id($id),
      provxq:point-to('prov:activity', $activity),
      provxq:point-to('prov:trigger', $trigger),
      provxq:point-to('prov:ender', $ender),
      provxq:tag('prov:time', $time),
      $additional-elements
    }
  };
  
  (:~
    Express that an entity was rendered invalid, expired, or destroyed by an activity.
    
    @param id An optional unique identifier for this expression.
    @param entity The previously-identified entity (QName, string, <prov:entity>, or any Entity subclass).
    @param activity An optional, previously-identified activity (QName, string, or <prov:activity>).
    @return a custom <prov:wasInvalidatedBy> expression
   :)
  declare function provxq:was-invalidated-by($id as xs:QName?, $entity as item(), $activity as item()?) {
    provxq:was-invalidated-by($id, $entity, $activity, (), ())
  };
  
  (:~
    Express that an entity was rendered invalid, expired, or destroyed by an activity.
    
    @param id An optional unique identifier for this expression.
    @param entity The previously-identified entity (QName, string, <prov:entity>, or any Entity subclass).
    @param activity An optional, previously-identified activity (QName, string, or <prov:activity>).
    @param time An optional date and time at which the entity was invalidated.
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasInvalidatedBy> expression
   :)
  declare function provxq:was-invalidated-by($id as xs:QName?, $entity as item(), $activity as item()?, 
     $time as xs:dateTime?, $additional-elements as element()*) {
    element prov:wasInvalidatedBy {
      provxq:set-prov-id($id),
      provxq:point-to('prov:entity', $entity),
      provxq:point-to('prov:activity', $activity),
      provxq:tag('time', $time),
      $additional-elements
    }
  };
  
  (:~
    Express that an activity was started in response to an entity's generation.
    
    @param id An optional unique identifier for this expression.
    @param activity A previously-identified activity (QName, string, or <prov:activity>).
    @param trigger An optional, previously-identified entity which was generated before this activity began (QName, string, <prov:entity>, or Entity subclass).
    @return a custom <prov:wasStartedBy> expression
   :)
  declare function provxq:was-started-by($id as xs:QName?, $activity as item(), $trigger as item()?) {
    provxq:was-started-by($id, $activity, $trigger, (), (), ())
  };
  
  (:~
    Express that an activity was started in response to an entity's generation.
    
    @param id An optional unique identifier for this expression.
    @param activity A previously-identified activity (QName, string, or <prov:activity>).
    @param trigger An optional, previously-identified entity which was generated before this activity began (QName, string, <prov:entity>, or Entity subclass).
    @param starter An optional, previously-identified activity during which the trigger entity was created (QName, string, or <prov:activity>).
    @param time An optional date and time at which the activity began.
    @param additional-elements Any number of elements, not necessarily in the PROV namespace, which contribute useful information.
    @return a custom <prov:wasStartedBy> expression
   :)
  declare function provxq:was-started-by($id as xs:QName?, $activity as item(), $trigger as item()?, 
     $starter as item()?, $time as xs:dateTime?, $additional-elements as element()*) {
    element prov:wasStartedBy {
      provxq:set-prov-id($id),
      provxq:point-to('prov:activity', $activity),
      provxq:point-to('prov:trigger', $trigger),
      provxq:point-to('prov:starter', $starter),
      provxq:tag('time', $time),
      $additional-elements
    }
  };
  
  
 (:  SUPPORT FUNCTIONS  :)
  
  (: Given a QName, construct a namespace declaration. :)
  declare %private function provxq:declare-namespace($name as xs:QName) {
    let $nsUri := namespace-uri-from-QName($name)
    let $nsPrefix := prefix-from-QName($name)
    return 
      if ( exists($nsPrefix) ) then
        namespace { $nsPrefix } { $nsUri }
      else ()
  };
  
  (: Determine if an item is (or can be reasonably cast as) a QName. :)
  declare %private function provxq:is-likely-QName($text as item()) {
    $text instance of xs:QName 
    or (
      $text castable as xs:QName 
      and namespace-uri-from-QName(xs:QName($text)) ne xs:anyURI('')
    )
  };
  
  (: Given a relation's tag name, try to create a pointer to a structural component. :)
  declare %private function provxq:point-to($gi as xs:string, $model as item()?) {
    if ( not(exists($model)) ) then ()
    else
      let $useRef :=
        (: If $model is an element, try to find an attribute containing an identifier. :)
        if ( $model instance of element() ) then
          let $idref :=
            if ( $model/@prov:id ) then $model/@prov:id
            else if ( $model/@xml:id ) then $model/@xml:id
            else if ( $model/@id ) then $model/@id
            else $model/normalize-space(.)
          let $ns := 
            namespace-uri-for-prefix(substring-before($idref, ':'), $model)
          let $qname := QName($ns, $idref)
          return provxq:set-prov-idref($qname)
        (: Accept QName identifiers. :)
        else if ( provxq:is-likely-QName($model) ) then
          provxq:set-prov-idref(xs:QName($model))
        (: Try to treat $model as a string. :)
        else if ( $model instance of xs:string or $model castable as xs:string ) then
          attribute prov:ref { $model }
        (: Return an empty sequence, preventing the use of @prov:ref. :)
        else ()
      return
        element { provxq:set-tagname($gi) } {
          $useRef
        }
  };
  
  (: Try to create an @prov:id, as well as a namespace declaration, from a QName. :)
  declare %private function provxq:set-prov-id($id as xs:QName?) as item()* {
    if ( exists($id) ) then 
      ( provxq:declare-namespace($id), attribute prov:id { $id } )
    else ()
  };
  
  (: Try to create an @prov:ref, as well as a namespace declaration, from a QName. :)
  declare %private function provxq:set-prov-idref($idref as xs:QName?) as item()* {
    if ( exists($idref) ) then 
      ( provxq:declare-namespace($idref), attribute prov:ref { $idref } )
    else ()
  };
  
  (: Given a tag name, ensure that it has a namespace prefix. If not, "prov:" is added. :)
  declare %private function provxq:set-tagname($gi as xs:string) {
    if ( matches($gi, '^prov:') ) then $gi
    else if ( contains($gi, ':') ) then $gi
    else concat('prov:',$gi)
  };
  
  (: Generate an element with the given tag name for each item in $values. Items can be elements, QNames, or 
    strings; otherwise, they are not included. :)
  declare %private function provxq:tag($gi as xs:string, $values as item()*) as node()* {
    for $val in $values
    return
      if ( $val instance of element() 
         and exists($val[self::prov:*][local-name(.) eq $gi]) ) then
        $val
      else if ( provxq:is-likely-QName($val) ) then
        element { provxq:set-tagname($gi) } {
          attribute xsi:type { 'xs:QName' },
          $val
        }
      else if ( $val instance of xs:string or $val castable as xs:string ) then
        element { provxq:set-tagname($gi) } { $val }
      else ()
  };
  
  (: Given a sequence of type values and some expected PROV classes, determine whether there exists one type which 
    might require the generic tag name to be overridden by a specialized one. :)
  declare %private function provxq:tag-type($values as item()*, $class as xs:string, 
     $subclasses as xs:string*) as map(*) {
    let $parsedValues := provxq:tag('type', $values)
    let $ofClass := $parsedValues[text() = $subclasses]
    let $replaceClass := count($ofClass) eq 1
    return
      if ( count($ofClass) eq 1 ) then
        map {
          'gi': $ofClass/text(),
          'types': $parsedValues[not(text() eq $ofClass/text())]
        }
      (: If there's zero OR more than one PROV subclass type, fall back on the generic class. :)
      else
        map {
          'gi': $class,
          'types': $parsedValues
        }
  };
