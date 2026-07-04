       identification division.
       program-id. postslist.

       data division.
       working-storage section.
       copy "thevars.cpy".
       01 filled-count pic 9(4).
       01 var-slot pic 9(4).

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           call 'cgihtmlhdr'
           move spaces to the-vars
           call 'postlistfill' using the-vars filled-count
           move filled-count to var-slot
           add 1 to var-slot
           move "page_title" to SSR-varname(var-slot)
           move "Posts (indexed file)" to SSR-varvalue(var-slot)
           add 1 to var-slot
           move "session_user" to SSR-varname(var-slot)
           move ctx-session-user to SSR-varvalue(var-slot)
           add 1 to var-slot
           move "page_template" to SSR-varname(var-slot)
           move "posts/list.cow" to SSR-varvalue(var-slot)
           add 1 to var-slot
           move "extra_css" to SSR-varname(var-slot)
           move
               ".posts-table { margin-top: 0.5rem; }"
               to SSR-varvalue(var-slot)
           add 1 to var-slot
           move "page_script" to SSR-varname(var-slot)
           move "pages/posts.js" to SSR-varvalue(var-slot)
           add 1 to var-slot
           move "page_body" to SSR-varname(var-slot)
           move spaces to SSR-varvalue(var-slot)
           call 'ssrtemplate' using the-vars "layout.cow"
           goback.

       end program postslist.
