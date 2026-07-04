       identification division.
       program-id. logout.

       data division.
       working-storage section.
       01 session-op pic x(10) value "DELETE".
       01 redirect-to pic x(256) value "/".
       01 cookie-line pic x(256)
           value "Set-Cookie: ssr_sid=; Path=/; Max-Age=0".

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           call 'sessionrv' using session-op cgictx
           call 'cgiredirect' using redirect-to cookie-line
           goback.

       end program logout.
