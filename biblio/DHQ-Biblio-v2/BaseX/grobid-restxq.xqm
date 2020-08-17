(:
 : 
 
 
 :)

module namespace page = 'http://basex.org/modules/web-page';

import module namespace sk = "http://wendellpiez.com/ns/DocSketch" at "../xquery/docsketch.xqm";

(: declare default element namespace "http://www.w3.org/1999/xhtml"; :)
declare namespace svg = "http://www.w3.org/2000/svg";

declare %rest:path("Grobid/{$citation}")
        %output:method("xml")
        %output:omit-xml-declaration("no")
  function page:grobid-citation($citation as xs:string) {
  
  let $request := <http:request href="http://192.168.0.172:8080/api/processCitation" method="post">
                    <http:body media-type="application/x-www-form-urlencoded">citations={ $citation }</http:body>
                  </http:request>
                  
  return <response>{ http:send-request($request) }</response> 
  
};

 (: 
          
          
  return http:send-request($request); :)

  (: cast HTML into XHTML namespace before delivering...
  return sk:run-xslt($html,(sk:fetch-xslt('xhtml-ns.xsl')),())
  :)



