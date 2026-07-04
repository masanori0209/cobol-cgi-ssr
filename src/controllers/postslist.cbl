       identification division.
       program-id. postslist.

       data division.
       working-storage section.
       copy "thevars.cpy".
       01 list-html pic x(4096).
       01 compact-list pic x(2048).
       01 nav-html pic x(512).
       01 body-extra pic x(512).

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           move
               "<table><thead><tr><th>ID</th><th>Title</th></tr></thead><tbody>"
               & "<tr><td>1</td><td><a href='/posts/1'>CGI was SSR from the beginning</a></td></tr>"
               & "<tr><td>2</td><td><a href='/posts/2'>Routing costs more than rendering</a></td></tr>"
               & "<tr><td>3</td><td><a href='/posts/3'>VOS3 EOL is a different migration</a></td></tr>"
               & "</tbody></table>"
               to list-html
           call 'cgihtmlhdr'
           call 'navbuild' using cgictx nav-html
           if ctx-session-user not = spaces
               move "<p><a href='/posts/new'>Create a post</a></p>" to body-extra
           else
               move "<p>Login to create posts.</p>" to body-extra
           end-if
           move spaces to the-vars
           move "page_title" to SSR-varname(1)
           move "Posts (indexed file)" to SSR-varvalue(1)
           move "page_body" to SSR-varname(2)
           move function trim(list-html trailing) to compact-list
           move spaces to SSR-varvalue(2)
           string
               function trim(body-extra trailing) delimited by size
               compact-list delimited by size
               into SSR-varvalue(2)
           move "nav_user" to SSR-varname(3)
           move nav-html to SSR-varvalue(3)
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program postslist.
