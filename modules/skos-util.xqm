xquery version "3.0";

module namespace skos-util = "http://danmccreary.com/skos-util";
(:
import module namespace skos-util = "http://danmccreary.com/skos-util" at "../modules/skos-util.xqm";
:)

declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare variable $skos-util:app-home-collection := '/db/apps/skos';
declare variable $skos-util:data-collection := concat($skos-util:app-home-collection, '/data');

(: returns a sequence of concepts :)
declare variable $skos-util:concepts := collection($skos-util:data-collection)/skos:concept;

(: returns a sequence of concepts that are the direct decendents of a term :)
declare function skos-util:narrower-terms($id as xs:string) as node()* {
  $skos-util:concepts[skos:broader/@id=$id]
};

declare function skos-util:broader-terms($id as xs:string) as node()* {
  $skos-util:concepts[skos:narrower/@id=$id]
};
