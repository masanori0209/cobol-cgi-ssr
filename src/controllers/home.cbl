       identification division.
       program-id. home.

       data division.
       working-storage section.
       copy "thevars.cpy".
       01 nav-html pic x(512).

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           call 'cgihtmlhdr'
           call 'navbuild' using cgictx nav-html
           move spaces to the-vars
           move "page_title" to SSR-varname(1)
           move "COBOL CGI SSR demo" to SSR-varvalue(1)
           move "page_body" to SSR-varname(2)
           move
               "<p>GnuCOBOL + CGI generates HTML on every request.</p>"
               to SSR-varvalue(2)
           move "nav_user" to SSR-varname(3)
           move nav-html to SSR-varvalue(3)
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program home.
