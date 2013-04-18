import module namespace skos-util = "http://danmccreary.com/skos-util" at "../modules/skos-util.xqm";

let $title := 'Narrower terms of 1'
return
<testcase name="{$title}" classname="">
  {if (skos-util:narrower-terms('1'))
    then <success>{skos-util:narrower-terms('1')}</success>
    else <failure></failure>
  }
</testcase>