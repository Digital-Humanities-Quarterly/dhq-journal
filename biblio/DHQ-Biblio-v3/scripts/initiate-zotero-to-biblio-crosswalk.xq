xquery version "3.1";

  (:declare boundary-space preserve;:)
(:  LIBRARIES  :)
  import module namespace mrng="http://digitalhumanities.org/dhq/ns/meta-relaxng"
    at "../apps/lib/relaxng.xql";
(:  NAMESPACES  :)
  declare default element namespace "http://digitalhumanities.org/dhq/ns/biblio";
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace wwp="http://www.wwp.northeastern.edu/ns/textbase";
(:  OPTIONS  :)
  (:declare option output:indent "no";:)

(:~
  
  
  @author Ashley M. Clark
  2020
 :)
 
 declare context item external := doc("../zotero_testing/dhq-biblio_bookChapters.xml");
 
(:  VARIABLES  :)
  declare variable $xsl-crosswalk-location := "../apps/transforms/zotero-tei-to-biblio-items.xsl";


(:  FUNCTIONS  :)
  declare function local:get-corresponding-biblio-genre($biblStruct as element(tei:biblStruct)) {
    let $genreMaps := (
        map {
          'biblioGenre': 'ArchivalItem',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'manuscript' )
            }
        }, map {
          'biblioGenre': 'Artwork',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'artwork' )
            }
        }, map {
          'biblioGenre': 'BlogEntry',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = (
                  'blogPost',
                  'podcast'
                )
            }
        }, map {
          'biblioGenre': 'Book',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'book' )
            }
        }, map {
          'biblioGenre': 'BookInSeries',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = (  (:'book':) )
            }
        }, map {
          'biblioGenre': 'BookSection',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'bookSection' )
            }
        }, map {
          'biblioGenre': 'ConferencePaper',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'conferencePaper' )
            }
        }, map {
          'biblioGenre': 'JournalArticle',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = (
                  'journalArticle',
                  'magazineArticle'
                )
            }
        }, map {
          'biblioGenre': 'Other',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ()
            }
        }, map {
          'biblioGenre': 'PhysicalMedia',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ()
            }
        }, map {
          'biblioGenre': 'Posting',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'forumPost' )
            }
        }, map {
          'biblioGenre': 'PublicGov',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = (
                  'bill',
                  'case',
                  'hearing',
                  'patent'
                )
            }
        }, map {
          'biblioGenre': 'Report',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'report' )
            }
        }, map {
          'biblioGenre': 'Series',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ()
            }
        }, map {
          'biblioGenre': 'Thesis',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'thesis' )
            }
        }, map {
          'biblioGenre': 'VideoGame',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ()
            }
        }, map {
          'biblioGenre': 'WebSite',
          'zoteroType': function($biblStruct as element(tei:biblStruct)) {
              $biblStruct/@type = ( 'webpage' )
            }
        }
      )
    let $proposedGenre := $genreMaps[?zoteroType($biblStruct)][1]?biblioGenre
    return
      if ( exists($proposedGenre) ) then
        $proposedGenre
      else 'BiblioItem'
  };

(:  MAIN QUERY  :)

let $zoteroEntries := //tei:body/tei:listBibl/tei:biblStruct
return
  <BiblioSet>
    <!-- Drop area for harvestable entries. -->
    <BiblioSet ready="true"> </BiblioSet>
    
    {
      for $record in $zoteroEntries
      let $genre := local:get-corresponding-biblio-genre($record)
      return (
          transform( map {
              'stylesheet-location': $xsl-crosswalk-location,
              'source-node': $record,
              'stylesheet-params': map { QName((),'biblio-genre'): $genre }
            })?output,
          text { "&#13;" }
        )
    }
  </BiblioSet>
