       identification division.
       program-id. loginpost.

       data division.
       working-storage section.
       01 session-op pic x(10) value "CREATE".
       01 field-name pic x(40) value "username".
       01 field-value pic x(256).
       01 redirect-to pic x(256) value "/posts".
       01 cookie-line pic x(256).

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           call 'formget' using cgictx field-name field-value
           move field-value to ctx-session-user
           if ctx-session-user = spaces
               move "/login" to redirect-to
               call 'cgiredirect' using redirect-to cookie-line
               goback
           end-if
           call 'sessionrv' using session-op cgictx
           move spaces to cookie-line
           string
               "Set-Cookie: ssr_sid=" delimited by size
               function trim(ctx-session-id) delimited by space
               "; Path=/" delimited by size
               into cookie-line
           call 'cgiredirect' using redirect-to cookie-line
           goback.

       end program loginpost.
