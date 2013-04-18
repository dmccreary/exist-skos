import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
declare namespace sk = "https://github.com/dmccreary/skos";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $concept-id := request:get-parameter('id', '')
let $app-collection := '/db/apps/skos/'
let $data-collection := concat($app-collection, 'data')
let $concept := collection($data-collection)/skos:concept[skos:id=$concept-id]
let $title := concat('View Concept ', $concept//skos:prefLabel/text())

return
let $content :=
<div class="content">
     {for $element in $concept/*
     let $element-name := string(node-name($element))
     return
     <div class="element">
        <span class="element-name">{name($element)}</span> {' '}
        { if ($element-name = 'narrower' or $element-name = 'broader')
        then 
          <a href="view-concept.xq?id={$element/@id/string()}">{$element/text()}</a>
        else
          <span class="element-value">{$element/text()}</span>
        }
     </div>
     }
</div>

return style:assemble-page($title, $content)