       identification division.
       program-id. postdetail.

       data division.
       working-storage section.
       copy "thevars.cpy".
       01 req-type pic x(10) value "LOOKUP".
       01 lookup-id pic x(4).
       01 lookup-found pic x(1).
       01 lookup-title pic x(40).
       01 lookup-body pic x(120).
       01 dummy-list pic x(4096).
       01 dummy-add-title pic x(40).
       01 dummy-add-body pic x(120).
       01 dummy-add-id pic x(4).
       01 nav-html pic x(512).
       01 body-buffer pic x(1024).

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           move query-value(1) to lookup-id
           call 'postserv' using
               req-type
               lookup-id lookup-found lookup-title lookup-body
               dummy-list
               dummy-add-title dummy-add-body dummy-add-id
           call 'cgihtmlhdr'
           call 'navbuild' using cgictx nav-html
           move "page_title" to SSR-varname(1)
           move "page_body" to SSR-varname(2)
           move "nav_user" to SSR-varname(3)
           move nav-html to SSR-varvalue(3)
           if lookup-found = "n"
               move "404 Not found" to SSR-varvalue(1)
               move
                   "<p>Unknown post id.</p><p><a href='/posts'>Back to list</a></p>"
                   to SSR-varvalue(2)
           else
               move lookup-title to SSR-varvalue(1)
               string
                   "<article><p>" delimited by size
                   function trim(lookup-body) delimited by space
                   "</p><p><a href='/posts'>Back to list</a></p></article>"
                   delimited by size
                   into body-buffer
               move body-buffer to SSR-varvalue(2)
           end-if
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program postdetail.
