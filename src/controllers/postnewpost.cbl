       identification division.
       program-id. postnewpost.

       data division.
       working-storage section.
       01 req-type pic x(10) value "ADD".
       01 dummy-id pic x(4).
       01 dummy-found pic x(1).
       01 dummy-title pic x(40).
       01 dummy-body pic x(120).
       01 dummy-list pic x(4096).
       01 add-title pic x(40).
       01 add-body pic x(120).
       01 add-id pic x(4).
       01 field-name pic x(40).
       01 field-value pic x(256).
       01 redirect-to pic x(256).
       01 cookie-line pic x(256) value spaces.

       linkage section.
       01 route-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).
       copy "cgictx.cpy".

       procedure division using route-values cgictx.
           if ctx-session-user = spaces
               move "/login" to redirect-to
               call 'cgiredirect' using redirect-to cookie-line
               goback
           end-if
           move "title" to field-name
           call 'formget' using cgictx field-name field-value
           move field-value to add-title
           move "body" to field-name
           call 'formget' using cgictx field-name field-value
           move field-value to add-body
           call 'postserv' using
               req-type
               dummy-id dummy-found dummy-title dummy-body
               dummy-list
               add-title add-body add-id
           move spaces to redirect-to
           string "/posts/" delimited by size
               function trim(add-id) delimited by space
               into redirect-to
           call 'cgiredirect' using redirect-to cookie-line
           goback.

       end program postnewpost.
