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
 return wisdom-neo4j:return-twiml($response//speech/string())
};

declare function wisdom-neo4j:return-twiml($speech as xs:string) as element(Response)
{
  <Response>
    <Say voice="woman" language="en">{$speech}</Say>
  </Response>
};
