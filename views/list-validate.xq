import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
declare namespace sk = "https://github.com/dmccreary/skos";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";


let $app-collection := '/db/apps/skos/'
let $data-collection := concat($app-collection, 'data')
let $schema-collection := concat($app-collection, 'schemas')

let $title := 'List Validations'

let $schema := concat($schema-collection, 'skos-db.xsd')

let $content :=
<div class="content">
     <ol>
        {for $file-name in xmldb:get-child-resources($data-collection)
           let $concept := doc(concat($data-collection, '/', $file-name))/*
           let $concept-id := $concept//*:id
           let $valid := validation:validate($concept, $schema)
           order by $file-name
           return
             <li>
               <a href="view-concept.xq?id={$concept/skos:id/text()}">{$concept//skos:prefLabel/text()} ({$concept-id}) </a> {' '} 
               {if ($valid)
                  then
                    <span class="success">Valid</span>
                 else 
                   <span class="failure">Fail</span>
               }
               {' '} <a href="validate-concept.xq?id={$concept-id}">details</a> {' '} {$file-name}
            </li>
         }
     </ol>
</div>

return style:assemble-page($title, $content)