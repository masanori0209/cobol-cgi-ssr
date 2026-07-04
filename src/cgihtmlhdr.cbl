       identification division.
       program-id. cgihtmlhdr.

       data division.
       working-storage section.
       01 newline pic x value x'0a'.

       procedure division.
           display
               "Content-Type: text/html; charset=utf-8"
               newline
               newline
           end-display
           goback.

       end program cgihtmlhdr.
