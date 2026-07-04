       identification division.
       program-id. loginform.

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
           move "Login" to page-title
           move "pages/login.html" to page-template
           call 'renderpage' using page-ctx cgictx
           goback.

       end program loginform.
