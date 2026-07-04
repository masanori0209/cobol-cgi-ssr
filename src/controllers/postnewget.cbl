       identification division.
       program-id. postnewget.

       data division.
       working-storage section.
       copy "pagectx.cpy".
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
           move spaces to page-ctx
           move "New post" to page-title
           move
               "<form method='post' action='/posts/new'><label>Title <input name='title' required maxlength='40'></label><br><label>Body <textarea name='body' required maxlength='120'></textarea></label><br><button type='submit'>Save</button></form>"
               to page-body
           call 'renderpage' using page-ctx cgictx
           goback.

       end program postnewget.
