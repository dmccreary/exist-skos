declare namespace sk = "https://github.com/dmccreary/skos";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";


let $app-collection := '/db/apps/skos/'
let $data-collection := concat($app-collection, 'data')

let $title := 'List Concepts'

return
<html>
  <head>
     <title>{$title}</title>
  </head>
  <body>
     <h1>{$title}</h1>
     Listing concepts in {$data-collection}
     <ol>
        {for $file-name in xmldb:get-child-resources($data-collection)
           let $doc := doc(concat($data-collection, '/', $file-name))/*
           let $name := $doc//skos:
           return
             <li>
               <a href="view-concept.xq?id={$file-name}">{$file-name} ({$type})</a>
            </li>
         }
     </ol>
  </body>
</html>