       identification division.
       program-id. postnewget.

       data division.
       working-storage section.
       copy "thevars.cpy".
       01 nav-html pic x(512).
       01 redirect-to pic x(256) value "/login".
       01 cookie-line pic x(256) value spaces.

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           if ctx-session-user = spaces
               call 'cgiredirect' using redirect-to cookie-line
               goback
           end-if
           call 'cgihtmlhdr'
           call 'navbuild' using cgictx nav-html
           move spaces to the-vars
           move "page_title" to SSR-varname(1)
           move "New post" to SSR-varvalue(1)
           move "page_body" to SSR-varname(2)
           move
               "<form method='post' action='/posts/new'><label>Title <input name='title' required maxlength='40'></label><br><label>Body <textarea name='body' required maxlength='120'></textarea></label><br><button type='submit'>Save</button></form>"
               to SSR-varvalue(2)
           move "nav_user" to SSR-varname(3)
           move nav-html to SSR-varvalue(3)
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program postnewget.
