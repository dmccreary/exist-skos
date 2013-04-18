xquery version "1.0";
import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";

declare namespace sk = "https://github.com/dmccreary/skos";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

(: recursive function to list all sub-requirements of a requirement 
   The first call should pass a $depth of 1 :)
declare function local:sub-req($concept-id as xs:string, $depth as xs:integer, $show-as as xs:boolean) as node()* {
   let $app-collection := $style:db-path-to-app 
   let $data-collection := '/db/apps/skos/data'
   let $current-concept := collection($data-collection)/skos:concept[skos:id=$concept-id]
   
   return
   if ($current-concept[skos:follow != 'no-follow'])
   then
    <ul>
       <li>
          <a href="view-concept.xq?id={$concept-id}">{$current-concept//skos:perfLabel/text()}</a> 
          ({$concept-id})
          - 
          {$current-concept/skos:definition/text()}
       </li>
       { (: Check any other terms in the collection have our element as a broader term :)
       if (exists(collection($data-collection)/skos:concept[skos:broader/@id=$concept-id]) and $depth < 10)
         then (
            (: Find all requirements that are sub-requirements of this requirement. :)
            for $concept in collection($data-collection)/skos:concept[skos:broader/@id=$concept-id]
                order by lower-case($concept/skos:perfLabel/text())
                return
                local:sub-req(xs:string($concept/id/text()), $depth + 1, $show-as)
             )
         else ()
         }
    </ul>
    else ()
};

let $title := 'Concept Hierarchy Report'

(: if no starting point ID is specificed, then just start at ID = 1 :)
let $id := request:get-parameter('id', '1')
let $show-arch-sig-string := request:get-parameter('show-as', 'false')
let $show-arch-sig := xs:boolean(if ($show-arch-sig-string = 'true') then true() else false())

let $app-collection := $style:db-path-to-app
let $data-collection := concat($app-collection, '/data')

(: concept-hierarchy.xq
   recursive decent of hierarchy by looking for all concept that have the current concept as a borader term
   Author: Dan McCreary
   Date: 10-25-2007
   Modified: 2-20-2009
:)

(: make sure we have one and only one root element (where the parent ID is 0 :)
let $root := collection($data-collection)/skos:concept[skos:id=$id]
let $root-count := count($root)

return
(: check for required parameters :)
if ($root-count ne 1)
    then
        <error>
            <message>Must have exactly one root node with an ID of {$id}.  Found {$root-count}</message>
        </error>
    else
   
let $total-count := count(collection($data-collection)/skos:concept)

let $content :=
<div class="content">
        Found {$total-count} concepts in {$style:db-path-to-app}<br/>

        {local:sub-req($id, 1, false() )}
        
        <a href="../edit/edit.xq?new=true">New Concept</a>
</div>


return style:assemble-page($title, $content)