      *> Minimal {{var}} templating engine (inspired by COBOL on Wheelchair)

       identification division.
       program-id. ssrtemplate.

       environment division.
       input-output section.
       file-control.
           select readfile
               assign to readfile-name
               file status is readfile-status
               organization is line sequential.

       data division.
       file section.
       fd readfile.
       01 readline pic x(1024).

       working-storage section.
       01 readfile-name   pic x(255).
       01 readfile-status pic x(2).
       01 templine        pic x(1024).
       01 the-var         pic x(100).
       01 what-we-change  pic x(100).
       01 counter         pic 9(4).

       linkage section.
       copy "thevars.cpy".
       01 template-filename pic x(255).

       procedure division using the-vars template-filename.
           move
               function concatenate("views/", function trim(template-filename))
               to readfile-name
           open input readfile
           if readfile-status not = '00'
               display "ERROR opening " function trim(readfile-name)
               stop run
           end-if
           read readfile
           perform until readfile-status = '10'
               move function trim(readline) to templine
               perform varying counter from 1 by 1 until counter > 99
                   if function trim(SSR-varname(counter)) not = spaces
                       move
                           function concatenate(
                               '{{' function trim(SSR-varname(counter)) '}}'
                           )
                           to what-we-change
                       move
                           function substitute(
                               templine,
                               function trim(what-we-change),
                               function trim(SSR-varvalue(counter))
                           )
                           to templine
                   end-if
               end-perform
               display function trim(templine)
               read readfile
           end-perform
           close readfile
           goback.

       end program ssrtemplate.
