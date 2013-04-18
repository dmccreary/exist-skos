xquery version "1.0";

(: general utilities functions - not to be included by other modules :)

module namespace util2 = "http://danmccreary.com/util2";
(:
import module namespace util2 = "http://danmccreary.com/util2" at "util2.xqm";
:)

declare variable $util2:home-collection := '/db/apps/skos';
declare variable $util2:data-collection := concat($util2:home-collection, '/data');
declare variable $util2:unit-test-collection := concat($util2:home-collection, '/unit-tests');
declare variable $util2:unit-test-results := concat($util2:unit-test-collection, '/test-results.xml');

declare function util2:substring-before-last-slash($in as xs:string?) as xs:string {  
   if (matches($in, '/'))
     then replace ($in, '^(.*)/.*', '$1')
     else ()
};
 
declare function util2:substring-after-last-slash($in as xs:string?) as xs:string {
   replace ($in, '^.*/', '')
};

declare function util2:substring-before-last($in as xs:string?, $delim as xs:string) as xs:string {
   if (matches($in, $delim))
   then replace($in,
            concat('^(.*)', $delim,'.*'),
            '$1')
   else ''
};

declare function util2:substring-after-last($in as xs:string?, $delim as xs:string) as xs:string {
   replace ($in,concat('^.*',$delim),'')
 } ;
 
(: create all the collections in a path if they do not exist and report results :)
(: this must be run aa an admin user :)
declare function util2:mkdirs-r($done as xs:string?, $todo as xs:string?) as node()* {
(: create a sequence of tokens between the slashes.  $step[1] is null since the first char is '/' :)
let $steps := tokenize($todo, '/')
return
if (count($steps) ge 2)
    then
        (let $first := $steps[2]
         let $rest := substring-after($todo, '/')
         let $path := concat($done, '/', $first)
         let $check-path :=
            if (xmldb:collection-available($path))
               then false()
               else (
                     xmldb:login(util2:substring-before-last-slash($path), 'admin', 'admin123'),
               xmldb:create-collection(util2:substring-before-last-slash($path), util2:substring-after-last-slash($path))
               )
         return
              (
                 <checking>{$path}{' '}{if ($check-path = true()) then 'created' else 'ok' }</checking>,
                 util2:mkdirs-r($path, $rest)
               )
          )
    else ()
};

declare function util2:mkdirs($collection-path as xs:string) as node()* {
   util2:mkdirs-r((), $collection-path)
};

(: returns true if the current user is in the dba group :)
declare function util2:is-dba() as xs:boolean {
   let $current-user := xmldb:get-current-user()
   let $list-of-groups := xmldb:get-user-groups($current-user)
   return
      if ($list-of-groups = 'dba')
         then true()
         else false()
};

(: looking for a file called test-status.xml that has the following struture:
<test-results>
    <test>
        <file>01-ft-client-module-load-test.xq</file>
        <desc>ft-client module loaded and functions.</desc>
        <category>module-load</category>
        <status>pass</status>
    </test>
</test-results>
:)
declare function util2:test-status() as node() {
let $collection := $util2:unit-test-collection
let $test-status-path := concat($collection, '/test-status.xml')
let $tests := doc($test-status-path)//test

(: don't show the index or non-xquery or html files :)
let $filtered-files :=
   for $file in xmldb:get-child-resources( $collection )
   return
     if (not($file='index.xq') and (ends-with($file, '.xq') or ends-with($file, '.xql') or ends-with($file, '.html')))
             then $file
             else ()
             
(: the default order is by last update :)
let $sort := request:get-parameter('sort', 'last-modified')

let $sorted-files :=
   if ($sort = 'last-modified')
   then
        for $file in $filtered-files
        order by xs:dateTime(xmldb:last-modified($collection, $file)) descending
        return
           $file
     else if ($sort = 'pass-fail')
        then
        for $file in $filtered-files
        let $test := $tests[file=$file]
        order by $test/status/text()
        return
           $file
           (: the fall through default is by file name :)
     else
       for $file in $filtered-files
        order by $file
        return
           $file
   
return
<div class="content">
      Unit tests in {$util2:unit-test-collection} sorted by 
      {if ($sort = 'last-modified') then 'Last Modified'
      else if ($sort = 'pass-fail') then 'Pass Fail'
      else 'File Name'
     }
      <table class="datatable span-24">
         <thead>
            <tr>
               <th class="span-5 row1">File <a href="{request:get-uri()}?sort=name">Sort</a> </th>
               <th class="span-10 row1">Description</th>
               <th class="span-1 row1">Status <a href="{request:get-uri()}?sort=pass-fail">Sort</a></th>
               <th class="span-2 row1">Modified <a href="{request:get-uri()}?sort=last-modified">Sort</a></th>
            </tr>
         </thead>
      {for $file at $count in $sorted-files
         let $test := $tests[file=$file]
         return
             <tr>
                {if ($count mod 2)
                    then attribute class {'odd'}
                    else attribute class {'even'}
                 }
                <td style="text-align:left;"><a href="{$file}">{$file}</a></td>
                <td style="text-align:left;">{$test/desc/text()}</td>
                <td style="text-align:center;">
                 {if ($test/status/text() = 'fail') 
                    then <span class="fail">fail</span>
                    else <span class="pass">pass</span>
                 }
                </td>
                <td style="text-align:left;">{util2:us-dateTime(xmldb:last-modified($collection, $file))}</td>
             </tr>
      }
      </table>
   Test Status at <a href="/rest{$test-status-path}">{$test-status-path}</a>
</div>
};

(: converts dates from YYYYMM format to MMM-YY format :)
declare function util2:us-dateTime($inany) as xs:string {
let $in := xs:string($inany)
(: months in title case :)
let $month-seq-tc := ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
(: let $month-seq-uc := ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC') :)
(: The new year is created by taking the $in, old date, and starting at the third char - get the next two chars  :)
let $year := substring($in, 1, 4)
let $new-month-int := xs:integer(substring($in, 6, 2))
let $day-of-month := xs:integer(substring($in, 9, 2))
let $new-month-name := $month-seq-tc[$new-month-int]
let $time := substring($in, 12, 8)
let $us-hours := util2:us-hours-from-iso-hours($time)
return concat($new-month-name, ' ', $day-of-month , ', ', $year, ' ', $us-hours)
};

(: takes in a string like "13:29:45" and returns " 1:29:45pm" :)
declare function util2:us-hours-from-iso-hours($iso-hours as xs:string) as xs:string {
let $int := xs:integer(substring($iso-hours, 1, 2))
return
let $us-hours :=
    if ($int eq 0)
      then '12'
    
    else if ($int le 9)
      then concat(' ', substring($iso-hours, 2, 1))
    
    else if ($int le 12)
        then string($int)
        
    else string($int - 12)
           
let $am-pm :=
  if ($int le 11) 
     then 'am' 
     else 'pm'
     
return concat($us-hours, substring($iso-hours, 3, 8), $am-pm)
};

(: recursive function for showing the differences between sorted lists :)
declare function util2:merge($a as xs:string*, $b as xs:string* )  as item()* {
   if (empty($a) and empty ($b)) 
       then ()
       else
          if (empty ($b) or $a[1] lt $b[1])
            then (<div class="left">{$a[1]}</div>, util2:merge(subsequence($a, 2), $b))
            else if (empty ($a) or $a[1] gt $b[1])
                then  (<div class="right">{$b[1]}</div>, util2:merge($a, subsequence($b,2)))  
                else  (<div class="match">{$a[1]}</div>, util2:merge(subsequence($a,2), subsequence($b,2)))
};

(: recursive function for showing the differences between sorted lists :)
declare function util2:merge-elements($a as xs:string*, $b as xs:string* )  as item()* {
   if (empty($a) and empty ($b)) 
       then ()
       else
          if (empty ($b) or $a[1] lt $b[1])
            then (<div class="left">{$a[1]/text()}</div>, util2:merge(subsequence($a, 2), $b))
            else if (empty ($a) or $a[1] gt $b[1])
                then  (<div class="right">{$b[1]/text()}</div>, util2:merge($a, subsequence($b,2)))  
                else  (<div class="match">{$a[1]/text()}</div>, util2:merge(subsequence($a,2), subsequence($b,2)))
};

(: This function takes a general purpose code-table file and prepars it for loading into an XForms application.
   It prepends the null-value item with the label "Select an Item" as the first item
   Note that it also strips out the hints and defintions from the internal code table lists.
   Only the elements that are needed by the select elements are used.
   Also note that the items remain in document order.  No sorting is done in the list, although that funciton
   could be added.  :)
   
declare function util2:add-null-selection-to-code-table($code-table as node()) as node() {
<code-table>
   {$code-table/name}
   <items>
      <item>
          <label>Select an Item...</label>
          <value/>
      </item>
      {for $item in $code-table/items/item
         return
         <item>
            {$item/label}
            {$item/value}
            {$item/function-called}
            {$item/error}
         </item>
       }
   </items>
</code-table>
};

(: XML to XHTML for display in browser dispatcher :)
declare function util2:xml-to-html($input as node()*, $depth as xs:integer) as item()* {
let $left-margin := concat('margin-left: ', ($depth * 5), 'px' )
for $node in $input
   return 
      typeswitch($node)
        case text() return normalize-space(<span class="d">{$node}</span>)
        case element()
           return
              <div class="element" style="{$left-margin}">
                    <span class="t">&lt;{name($node)}</span>
                    { (: for each attribute create two spans for the name and value :)
                     for $att in $node/@*
                        return
                           (
                              <span class="an">{' '} {name($att)}=</span>,
                              <span class="av">"{string($att)}"</span>
                           )
                    }
                    {normalize-space(<span class="t">&gt;</span>)}
                    { (: now get the sub elements :)
                       for $c in $node
                          return util2:xml-to-html($c/node(), $depth + 1)
                    }
                    <span class="t">&lt;/{name($node)}&gt;</span>
             </div> 
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return $node
};



