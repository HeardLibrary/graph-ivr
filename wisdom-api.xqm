(:~
 : This module contains the interface for the Wisdom of the Elders telephony application. The interface is composed of a series of RESTXQ annotations.
 : @author Clifford B. Anderson
 :)
module namespace wisdom-api= "http://library.vanderbilt.edu/wisdom/api";

import module namespace wisdom-web = "http://library.vanderbilt.edu/wisdom/web" at "wisdom-web.xqm";
import module namespace wisdom-neo4j = "http://library.vanderbilt.edu/wisdom/neo4j" at "wisdom-neo4j.xqm";

(:~
 : Generates a welcome page.
 : @return HTML page
 :)
declare
  %rest:path("")
  %output:method("html")
  %output:omit-xml-declaration("no")
  function wisdom-api:start-website() as element(html)
{
  wisdom-web:start-website()
};


(:~
 : This function returns a "Hello, World" in TWIML XML.
 : @return response element
 :)
declare
  %rest:path("/node")
  %rest:GET
  function wisdom-api:hello() as element(Response)
{
   wisdom-api:node(0)
};

declare
  %rest:path("/node/{$id}")
  %rest:GET
  function wisdom-api:node($id as xs:integer) as element(Response)
{
  wisdom-neo4j:get-node-by-id($id)
};

declare
  %rest:path("/traverse/{$id}")
  %rest:query-param("Digits", "{$digits}")
  %rest:GET
  function wisdom-api:node($id as xs:integer, $digits as xs:integer) as element(Response)
{
  wisdom-neo4j:traverse-node-by-relationship-id($id, $digits)
};
