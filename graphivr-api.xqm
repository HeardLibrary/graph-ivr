(:~
 : This module contains the interface for the GraphIVR telephony application. The interface is composed of a series of RESTXQ annotations.
 : @author Clifford B. Anderson
 :)
module namespace graphivr-api= "http://library.vanderbilt.edu/graphivr/api";

import module namespace graphivr-web = "http://library.vanderbilt.edu/graphivr/web" at "graphivr-web.xqm";
import module namespace graphivr-neo4j = "http://library.vanderbilt.edu/graphivr/neo4j" at "graphivr-neo4j.xqm";

(:~
 : Generates a welcome page in HTML for cosmetic purposes
 : @return HTML page
 :)
declare
  %rest:path("")
  %output:method("html")
  %output:omit-xml-declaration("no")
  function graphivr-api:start-website() as element(html)
{
  graphivr-web:start-website()
};

(:~
 : Generates a welcome page in HTML for cosmetic purposes
 : @return HTML page
 :)
declare
  %rest:path("/rss")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  function graphivr-api:generate-rss() as element(rss)
{
  graphivr-web:generate-rss("graphivr")
};


(:~
 : Returns the initial greeting from Node ID 0 in TWIML XML.
 : @return response element
 :)
declare
  %rest:path("/node")
  %rest:GET
  function graphivr-api:say-hello() as element(Response)
{
   graphivr-api:get-node-by-id(0)
};

(:~
 : Returns the speech attribute from the selected node in TWIML XML.
 : @return response element
 :)
declare
  %rest:path("/node/{$id}")
  %rest:GET
  function graphivr-api:get-node-by-id($id as xs:integer) as element(Response)
{
  graphivr-neo4j:get-node-by-id($id)
};

(:~
 : Traverses the starting node to an adjacent node by following the selected edge.
 : @return response element
 :)
declare
  %rest:path("/traverse/{$id}")
  %rest:query-param("Digits", "{$digits}")
  %rest:GET
  function graphivr-api:get-node-by-node($id as xs:integer, $digits as xs:string) as element(Response)
{
  graphivr-neo4j:traverse-node-by-relationship-id($id, $digits)
};


(:~
 : Traverses the starting node to an adjacent node by following the selected edge.
 : @return response element
 :)
declare
  %updating
  %rest:path("/record/{$id}")
  %rest:query-param("CallSid", "{$CallSid}")
  %rest:query-param("Digits", "{$Digits}")
  %rest:query-param("From", "{$From}")
  %rest:query-param("CallerName", "{$CallerName}")
  %rest:query-param("Name", "{$Name}")
  %rest:query-param("RecordingUrl", "{$RecordingUrl}")
  %rest:GET
  function graphivr-api:record-information($id as xs:integer, $CallSid as xs:string, $CallerName as xs:string?, $Digits as xs:string, $From as xs:string?, $Name as xs:string?, $RecordingUrl as xs:string?) as element(Response)
{
  graphivr-neo4j:record-information($id, $CallSid, $CallerName, $Digits, $From, $Name, $RecordingUrl)
};
