import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
declare namespace sk = "https://github.com/dmccreary/skos";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $concept-id := request:get-parameter('id', '')
let $app-collection := $style:app-collection
let $data-collection := concat($app-collection, '/data')
let $concept := collection($data-collection)/skos:concept[skos:id=$concept-id]
let $concept-name := $concept//skos:prefLabel/text()
let $title := concat('Validate Concept ', $concept-name)

let $app-collection := '/db/apps/skos/'
let $data-collection := concat($app-collection, '/data')
let $schema-collection := concat($app-collection, 'schemas')



let $schema-path := xs:anyURI(concat($schema-collection, '/skos-db.xsd'))

let $clear := validation:clear-grammar-cache()
let $valid := validation:validate($concept, $schema-path)

let $content :=
<div class="content">
   Validating concept {$concept-name} ({$concept-id}) against XML Schema {$schema-path}.
   {if ($valid)
      then <div class="success">The concept {$concept-name} is valid against schema {$schema-path}</div>
      else 
        <div class="fail">The concept {$concept-name} is NOT valid against schema {$schema-path}.<br/>
        <br/>
        Validation Report:
          {validation:validate-report($concept, $schema-path)}
        </div>
   }
   

</div>

return style:assemble-page($title, $content)