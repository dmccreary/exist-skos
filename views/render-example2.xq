declare namespace gs = "https://github.com/dmccreary/graph2svg";
declare option exist:serialize "method=xml media-type=image/svg+xml";

let $app-collection := '/db/apps/graph2svg/'
let $xslt-collection := concat($app-collection, 'xslt/')
let $example-collection := concat($app-collection, 'examples/')

(: file name including suffix :)
let $example := request:get-parameter("example",())
let $input-chart-path := concat($example-collection, $example)

return
  if (not(doc-available($input-chart-path)))
     then
       <error>
         <message>Error: Input Document Not Found!</message>
         <example-collection>{$example-collection}</example-collection>
         <input-example-parameter>{$example}</input-example-parameter>
         <input-chart-path>{$input-chart-path}</input-chart-path>
      </error> else (: continue :)

let $input-chart := doc($input-chart-path)/*
let $chart-root-element-name := name($input-chart)

(: use a different XSLT file for different data types :)
let $transform-path := 
      if      ($chart-root-element-name='osgr') then doc(concat($xslt-collection, 'xosgr2svg.xsl'))
      else if ($chart-root-element-name='msgr') then doc(concat($xslt-collection, 'xmsgr2svg.xsl'))
      else if ($chart-root-element-name='xygr') then doc(concat($xslt-collection, 'xxygr2svg.xsl'))
      else 'error unknown chart root element'
      
return
   if ($input-chart and doc-available($transform-path))
      then
        <svg:svg width="500px" height="400px">
          {transform:transform ($input-chart, $transform-path,())}
        </svg:svg>
      else
      <error>
         <example-collection>{$example-collection}</example-collection>
         <input-example-parameter>{$example}</input-example-parameter>
         <transform-path>{$transform-path}</transform-path>
         <input-chart-nodes>{count($input-chart//node())}</input-chart-nodes>
         
      </error>