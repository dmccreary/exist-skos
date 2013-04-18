import module namespace style = "http://danmccreary.com/style" at "modules/style.xqm";

let $title := 'SKOS Manager'

let $content :=
<div class="content">
     <p>This package allows you to manage a concept taxonomy using SKOS.</p>
     <a href="views/list-concepts.xq">List Concepts Alphatetically</a> all concepts in the registry sorter alphabetically be the preferred label.<br/>
     <a href="views/concept-hierarchy.xq">Concept Hierarchy</a> Starting at concept 1<br/>
     <a href="views/list-validate.xq">List validations</a> List validation for all concepts<br/>
     
     <h3>Unit Tests</h3>
     <a href="unit-tests/index.xq">Unit Tests</a> listing of all unit tests.<br/>
     
     <h3>References</h3>
     <a href="http://www.w3.org/2004/02/skos/">SKOS Homepage at the W3C</a><br/>
     <a href="http://www.w3.org/TR/2009/REC-skos-reference-20090818/">SKOS Specification</a><br/>
     
     <p>Please contact Dan McCreary (dan@danmccreary.com) if you have any feedback on this app.</p>
</div>

return style:assemble-page($title, $content)