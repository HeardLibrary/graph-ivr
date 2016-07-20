(:~
 : This module contains functions for interacting with Neo4J
 : @author Clifford B. Anderson
 :)
module namespace wisdom-neo4j= "http://library.vanderbilt.edu/wisdom/neo4j";

declare variable $wisdom-neo4j:endpoint as xs:string := "http://wisdom:BY0GTs9f73FmLDK3oFdG@wisdom.sb10.stations.graphenedb.com:24789/db/data/transaction/commit";

declare function wisdom-neo4j:http-request($json as xs:string) as document-node()? {
  let $request :=
    <http:request method='post' href="{$wisdom-neo4j:endpoint}">
      <http:body method="text" media-type='application/json'>
        {$json}
      </http:body>
   </http:request>
  let $response:= http:send-request($request)
  let $headers := $response[1]
  let $body := $response[2]
  where $headers/@status/fn:data() = "200"
  return $body
};

declare function wisdom-neo4j:get-node-by-id($id as xs:integer) as element(Response)?
{
 let $json := '{
    "statements" : [ {
      "statement" : "match (a {id:' || $id || '}) return a"
    } ]
  }'
 let $speech := wisdom-neo4j:http-request($json)//speech/string()
 return wisdom-neo4j:return-twiml($id, $speech)
};

declare function wisdom-neo4j:traverse-node-by-relationship-id($id as xs:integer, $digits as xs:integer) as element(Response)
{
 let $json := '{
   "statements" : [ {
      "statement": "match (a {id:' || $id || '})-[r {event:' || $digits || '}]->(c) return c.id"
   } ]
 }'
 let $destination-node := wisdom-neo4j:http-request($json)//_[@type="number"]/text()
 return wisdom-neo4j:get-node-by-id($destination-node)
};

declare function wisdom-neo4j:return-twiml($id as xs:integer, $speech as xs:string) as element(Response)
{
  <Response>
    <Gather action="/telephony/traverse/{$id}" method="GET">
        <Say voice="woman" language="en">{$speech}</Say>
    </Gather>
   <Say>We did not receive any input. Goodbye!</Say>
 </Response>
};
