(:~
 : This module contains functions for interacting with Neo4J
 : @author Clifford B. Anderson
 :)
module namespace graphivr-neo4j= "http://library.vanderbilt.edu/graphivr/neo4j";

declare variable $graphivr-neo4j:endpoint as xs:string := "http://wisdom:BY0GTs9f73FmLDK3oFdG@wisdom.sb10.stations.graphenedb.com:24789/db/data/transaction/commit";

declare function graphivr-neo4j:http-request($json as xs:string) as document-node()? {
  let $request :=
    <http:request method='post' href="{$graphivr-neo4j:endpoint}">
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

declare function graphivr-neo4j:process-audio($choice as element(_)*, $options as element(_)*) as element()*
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

declare function graphivr-neo4j:get-node-by-id($id as xs:integer) as element(Response)?
{
 let $json := '{
    "statements" : [ {
      "statement" : "match (a {id:' || $id || '}) return a, labels(a)"
    } ]
  }'
 let $node := graphivr-neo4j:http-request($json)
 return
   if ($node//row/_[@type="array"]/_/text() = "Record")
   then graphivr-neo4j:gather-recording($id, $node)
   else if ($node//row/_[@type="array"]/_/text() = "Choice")
   then graphivr-neo4j:gather-response($id, $node)
   else if ($node//row/_[@type="array"]/_/text() = "Terminus")
   then graphivr-neo4j:gather-goodbye($node)
   else () (: error condition :)
};

declare function graphivr-neo4j:gather-recording($id as xs:integer, $node as document-node()?) as element(Response)?
{
  let $choice := $node//row/_
  let $options := graphivr-neo4j:get-node-relationships($id)
  let $audio := graphivr-neo4j:process-audio($choice, $options)
  let $name := $node//name/text()
  return graphivr-neo4j:record-twiml($id, $audio, $name)
};

declare function graphivr-neo4j:gather-response($id as xs:integer, $node as document-node()?) as element(Response)?
{
  let $choice := $node//row/_
  let $options := graphivr-neo4j:get-node-relationships($id)
  let $audio := graphivr-neo4j:process-audio($choice, $options)
  return graphivr-neo4j:return-twiml($id, $audio)
};

declare function graphivr-neo4j:gather-goodbye($node as document-node()?) as element(Response)?
{
  let $goodbye := $node//row/_
  let $options := ()
  let $audio := graphivr-neo4j:process-audio($goodbye, $options)
  return graphivr-neo4j:goodbye-twiml($audio)
};


declare function graphivr-neo4j:traverse-node-by-relationship-id($incoming-node as xs:integer, $digits as xs:string?) as element(Response)
{
  let $json := '{
    "statements" : [ {
       "statement": "match (a {id:' || $incoming-node || '})-[r {event:' || '''' || $digits || '''' || '}]->(c) return c.id"
    } ]
  }'
 let $destination-node := graphivr-neo4j:http-request($json)//_[@type="number"]/text()
 return
   if (fn:not(fn:empty($destination-node)))
   then graphivr-neo4j:get-node-by-id($destination-node)
   else graphivr-neo4j:get-node-by-id($incoming-node) (: return user to choices if invalid option selected :)
};

declare function graphivr-neo4j:record-information($id as xs:integer, $CallSid as xs:string, $CallerName as xs:string?, $Digits as xs:string, $From as xs:string?, $Name as xs:string?, $RecordingUrl as xs:string?) as element(Response)
{
  let $call :=
    <call CallSid="{$CallSid}" DateTime="{fn:current-dateTime()}" Name="{$Name}">
      {if ($CallerName) then <CallerName>{$CallerName}</CallerName> else ()}
      <From>{$From}</From>
      <RecordingUrl>{$RecordingUrl}</RecordingUrl>
    </call>
  return
  (
    db:add("graphivr", $call, $CallSid || $Name || ".xml"),
    graphivr-neo4j:traverse-node-by-relationship-id($id, $Digits)
  )
};

declare function graphivr-neo4j:get-node-relationships($id as xs:integer) as element(_)*
{
  let $json := '{
    "statements" : [ {
       "statement": "match (a {id:' || $id || '})-[r]->(c) return r"
    } ]
  }'
 let $results := graphivr-neo4j:http-request($json)//row/_
 for $obj in $results
 order by $obj/event/text()
 return $obj
};

declare function graphivr-neo4j:record-twiml($id as xs:integer, $audio as element()*, $name as xs:string?) as element(Response)
{
  <Response>
    {$audio}
    <Record
        action="/telephony/record/{$id}?Name={$name}"
        method="GET"
        maxLength="20"
        finishOnKey="*"
        />
    <Say voice="woman" language="en">We did not receive any recording.</Say>
</Response>
};

declare function graphivr-neo4j:return-twiml($id as xs:integer, $audio as element()*) as element(Response)
{
  <Response>
    <Gather action="/telephony/traverse/{$id}" method="GET">
        {$audio}
    </Gather>
   <Say voice="woman" language="en">We did not receive any input. Goodbye!</Say>
 </Response>
};

declare function graphivr-neo4j:goodbye-twiml($audio as element()*) as element(Response)
{
 <Response>
    {$audio}
 </Response>
};
