(:~
 : This module contains functions for interacting with Neo4J
 : @author Clifford B. Anderson
 :)
module namespace wisdom-neo4j= "http://library.vanderbilt.edu/wisdom/neo4j";

declare function wisdom-neo4j:get-node-by-id($id as xs:integer) as element(Response)?
{
  let $endpoint := "http://wisdom:BY0GTs9f73FmLDK3oFdG@wisdom.sb10.stations.graphenedb.com:24789/db/data/transaction/commit"
  let $json := '{
    "statements" : [ {
      "statement" : "match (a {id:' || $id || '}) return a"
    } ]
  }'
  let $request := http:send-request(
      <http:request method='post' href="{$endpoint}">
        <http:body media-type='application/json'>
          {$json}
        </http:body>
     </http:request>
  )
 let $headers := $request[1]
 let $response := $request[2]
 return wisdom-neo4j:return-twiml($id, $response//speech/string())
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

declare function wisdom-neo4j:traverse-node-by-relationship-id($id as xs:integer, $digits as xs:integer) as element(Response)
{
  let $endpoint := "http://wisdom:BY0GTs9f73FmLDK3oFdG@wisdom.sb10.stations.graphenedb.com:24789/db/data/transaction/commit"
  let $json := '{
   "statements" : [ {
      "statement": "match (a {id:'|| $id ||'})-[r {event:' || $digits || '}]-(c) return c.id"
   } ]
 }'
  let $request := http:send-request(
      <http:request method='post' href="{$endpoint}">
        <http:body media-type='application/json'>
          {$json}
        </http:body>
     </http:request>
  )
 let $headers := $request[1]
 let $response := $request[2]
 let $destination-node := $response//_[@type="number"]/text()
 return wisdom-neo4j:get-node-by-id($destination-node)
};
