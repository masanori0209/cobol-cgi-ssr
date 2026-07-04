       identification division.
       program-id. about.

       data division.
       working-storage section.
       copy "pagectx.cpy".

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           move spaces to page-ctx
           move "About this demo" to page-title
           move
               "<p>POST form, cookie session, indexed file under data/posts.dat.</p>"
               to page-body
           call 'renderpage' using page-ctx cgictx
           goback.

       end program about.
