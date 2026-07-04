       identification division.
       program-id. ssr.

       environment division.

       data division.
       working-storage section.
       copy "cgictx.cpy".

       01 analyzed-query pic x(1600).
       01 pattern-query pic x(999).

       01 the-great-dispatch.
          03 nroutes pic 99 usage comp-5.
          03 routing-table occurs 10 times.
             05 routing-pattern pic x(999).
             05 routing-method pic x(10).
             05 routing-destiny pic x(999).

       01 tester pic x(1) value "n".
       01 anyfound pic x(1) value "n".
       01 ctr pic 99 usage comp-5.

       01 the-values.
          05 query-values occurs 10 times.
             10 query-value-name pic x(90).
             10 query-value pic x(90).

       01 init-req pic x(10) value "INIT".
       01 dummy-id pic x(4).
       01 dummy-found pic x(1).
       01 dummy-title pic x(40).
       01 dummy-body pic x(120).
       01 dummy-list pic x(4096).
       01 dummy-add-title pic x(40).
       01 dummy-add-body pic x(120).
       01 dummy-add-id pic x(4).
       01 session-op pic x(10).

       01 choppery.
          05 chopped-path-pieces occurs 99 times.
             10 chopped-path-piece pic x(80) value spaces.
          05 chopped-pattern-pieces occurs 99 times.
             10 chopped-pattern-piece pic x(80) value spaces.
       01 counter pic s9(4) comp.
       01 positio pic s9(4).
       01 tmp-pointer pic s9(4) comp value +1.
       01 tmp-pointer2 pic s9(4) comp value +1.
       01 counter-of-values pic s9(2).

       procedure division.
           copy "config.cbl".
           perform get-query
           call 'cgifill' using cgictx
           move "LOAD" to session-op
           call 'sessionrv' using session-op cgictx
           perform varying ctr from 1 by 1 until ctr > nroutes
               if anyfound = "y"
                   exit perform
               end-if
               move routing-pattern(ctr) to pattern-query
               perform check-query
               if tester = "y"
                   if routing-method(ctr) = ctx-request-method
                       move "y" to anyfound
                       call routing-destiny(ctr) using the-values cgictx
                   end-if
               end-if
           end-perform
           if anyfound = "n"
               call 'cgihtmlhdr'
               perform not-found-error
           end-if
           goback.

       not-found-error.
           display "<h1>404</h1><p>Route not found: "
               function trim(analyzed-query) "</p>".

       get-query.
           move spaces to analyzed-query
           accept analyzed-query from environment "PATH_INFO"
           .

       check-query.
           move spaces to choppery the-values
           move "y" to tester
           move 0 to counter-of-values
           move 1 to tmp-pointer
           move 1 to tmp-pointer2
           perform varying counter from 2 by 1 until counter > 99
               subtract 1 from counter giving positio
               unstring analyzed-query delimited by '/'
                   into chopped-path-piece(positio)
                   with pointer tmp-pointer
               unstring pattern-query delimited by '/'
                   into chopped-pattern-piece(positio)
                   with pointer tmp-pointer2
           end-perform
           move 0 to counter
           perform varying counter from 1 by 1 until counter > 99 or tester = "n"
               if chopped-pattern-piece(counter)(1:1) equal "%"
                   if chopped-path-piece(counter) = spaces
                       move "n" to tester
                   else
                       add 1 to counter-of-values
                       move chopped-pattern-piece(counter)
                           to query-value-name(counter-of-values)
                       move chopped-path-piece(counter)
                           to query-value(counter-of-values)
                   end-if
               end-if
               if chopped-path-piece(counter)
                       not equal chopped-pattern-piece(counter)
                   and chopped-pattern-piece(counter)(1:1) not equal "%"
                   move "n" to tester
               end-if
           end-perform
           .

       end program ssr.
