xquery version "1.0";

let $input := doc('empty-file.xml')
let $xslt-file := doc('test-math-functions.xsl')

return
<results>
   {transform:transform ($input, $xslt-file,())}
</results>