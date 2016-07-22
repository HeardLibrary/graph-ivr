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

declare function wisdom-neo4j:process-audio($choice as element(_)*, $options as element(_)*) as element()*
{
  let $choice-audio :=
    for $say-or-play in $choice
    return
      if ($say-or-play/play) then <Play>{$say-or-play/play/text()}</Play>
      else if ($say-or-play/say) then <Say voice="woman" language="en">{$say-or-play/say/text()}</Say>
      else () (: In case neither say or play properties exist on node, which constitutes an error condition :)
  let $option-audio :=
    for $say-or-play in $options
    return
      if ($say-or-play/play) then <Play>{$say-or-play/play/text()}</Play>
      else if ($say-or-play/say) then <Say voice="woman" language="en">{$say-or-play/say/text()}</Say>
      else () (: error condition :)
  return ($choice-audio, $option-audio)
};

declare function wisdom-neo4j:get-node-by-id($id as xs:integer) as element(Response)?
{
 let $json := '{
    "statements" : [ {
      "statement" : "match (a {id:' || $id || '}) return a, labels(a)"
    } ]
  }'
 let $node := wisdom-neo4j:http-request($json)
 return
   if ($node//row/_[@type="array"]/_/text() = "Record")
   then wisdom-neo4j:gather-recording($id, $node)
   else if ($node//row/_[@type="array"]/_/text() = "Choice")
   then wisdom-neo4j:gather-response($id, $node)
   else () (: error condition :)
};

declare function wisdom-neo4j:gather-recording($id as xs:integer, $node as document-node()?) as element(Response)?
{
  let $choice := $node//row/_
  let $options := wisdom-neo4j:get-node-relationships($id)
  let $audio := wisdom-neo4j:process-audio($choice, $options)
  let $info := $node//info/text()
  return wisdom-neo4j:record-twiml($id, $audio, $info)
};

declare function wisdom-neo4j:gather-response($id as xs:integer, $node as document-node()?) as element(Response)?
{
  let $choice := $node//row/_
  let $options := wisdom-neo4j:get-node-relationships($id)
  let $audio := wisdom-neo4j:process-audio($choice, $options)
  return wisdom-neo4j:return-twiml($id, $audio)
};

declare function wisdom-neo4j:traverse-node-by-relationship-id($incoming-node as xs:integer, $digits as xs:string?) as element(Response)
{
  let $json := '{
    "statements" : [ {
       "statement": "match (a {id:' || $incoming-node || '})-[r {event:' || '''' || $digits || '''' || '}]->(c) return c.id"
    } ]
  }'
 let $destination-node := wisdom-neo4j:http-request($json)//_[@type="number"]/text()
 return
   if (fn:not(fn:empty($destination-node)))
   then wisdom-neo4j:get-node-by-id($destination-node)
   else wisdom-neo4j:get-node-by-id($incoming-node) (: return user to choices if invalid option selected :)
};

declare function wisdom-neo4j:get-node-relationships($id as xs:integer) as element(_)*
{
  let $json := '{
    "statements" : [ {
       "statement": "match (a {id:' || $id || '})-[r]->(c) return r"
    } ]
  }'
 let $results := wisdom-neo4j:http-request($json)//row/_
 for $obj in $results
 order by $obj/event/text()
 return $obj
};

declare function wisdom-neo4j:record-twiml($id as xs:integer, $audio as element()*, $info as xs:string?) as element(Response)
{
  <Response>
    {$audio}
    <Record
        action="/telephony/record/{$id}?Info={$info}"
        method="GET"
        maxLength="20"
        finishOnKey="*"
        />
    <Say voice="woman" language="en">We did not receive any recording.</Say>
</Response>
};

declare function wisdom-neo4j:return-twiml($id as xs:integer, $audio as element()*) as element(Response)
{
  <Response>
    <Gather action="/telephony/traverse/{$id}" method="GET">
        {$audio}
    </Gather>
   <Say voice="woman" language="en">We did not receive any input. Goodbye!</Say>
 </Response>
};
