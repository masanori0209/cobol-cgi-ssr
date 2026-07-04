       identification division.
       program-id. loginform.

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
           move "Login" to SSR-varvalue(1)
           move "page_body" to SSR-varname(2)
           move
               "<form method='post' action='/login'><label>Username <input name='username' required></label> <button type='submit'>Login</button></form>"
               to SSR-varvalue(2)
           move "nav_user" to SSR-varname(3)
           move nav-html to SSR-varvalue(3)
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program loginform.
