      *> {{var}} + Django-ish tags: include / if / for / block

       identification division.
       program-id. ssrtemplate is recursive.

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
       01 lookup-name     pic x(99).
       01 lookup-result   pic x(4096).
       01 what-we-change  pic x(100).
       01 counter         pic 9(4).
       01 include-name    pic x(255).
       01 if-var-name     pic x(99).
       01 if-truthy       pic x(1).
       01 for-prefix      pic x(99).
       01 for-count-var   pic x(99).
       01 for-index       pic 9(4).
       01 for-max         pic 9(4).
       01 block-name      pic x(99).
       01 block-line-idx  pic 9(4).
       01 branch-mode     pic x(1).
       01 true-line-count pic 9(4).
       01 false-line-count pic 9(4).
       01 loop-line-count pic 9(4).
       01 loop-line-idx   pic 9(4).
       01 loop-field-id   pic x(99).
       01 loop-field-title pic x(99).
       01 loop-slot-id    pic 9(4) value 90.
       01 loop-slot-title pic 9(4) value 91.
       01 loop-id-name    pic x(99).
       01 loop-title-name pic x(99).
       01 for-index-num   pic 9(4).
       01 render-depth    pic 9(2) value 0.
       01 scan-idx        pic 9(4).
       01 tag-token-1     pic x(32).
       01 tag-token-2     pic x(32).
       01 tag-token-3     pic x(32).
       01 tag-token-4     pic x(32).
       01 template-stack occurs 8 times.
          05 stack-line-count pic 9(4).
          05 stack-line-idx pic 9(4).
          05 stack-lines occurs 128 times.
             10 stack-line-text pic x(1024).
       01 true-lines occurs 64 times.
          05 true-text pic x(1024).
       01 false-lines occurs 64 times.
          05 false-text pic x(1024).
       01 loop-lines occurs 32 times.
          05 loop-text pic x(1024).

       linkage section.
       copy "thevars.cpy".
       01 template-filename pic x(255).

       procedure division using the-vars template-filename.
           perform render-file
           goback.

       render-file.
           if render-depth > 8
               display "ERROR template include depth exceeded"
               stop run
           end-if
           add 1 to render-depth
           move
               function concatenate(
                   "views/",
                   function trim(template-filename)
               )
               to readfile-name
           perform load-template-lines
           if readfile-status not = '00'
               display "ERROR opening " function trim(readfile-name)
               stop run
           end-if
           move 1 to stack-line-idx(render-depth)
           perform until stack-line-idx(render-depth)
               > stack-line-count(render-depth)
               move function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) to templine
               perform process-line
               add 1 to stack-line-idx(render-depth)
           end-perform
           subtract 1 from render-depth
           .

       load-template-lines.
           move 0 to stack-line-count(render-depth)
           open input readfile
           if readfile-status not = '00'
               exit paragraph
           end-if
           read readfile
           perform until readfile-status = '10'
               if stack-line-count(render-depth) >= 128
                   display "ERROR template too many lines"
                   stop run
               end-if
               add 1 to stack-line-count(render-depth)
               move readline to
                   stack-line-text(
                       render-depth,
                       stack-line-count(render-depth)
                   )
               read readfile
           end-perform
           close readfile
           move '00' to readfile-status
           .

       process-line.
           if templine = spaces
               display " "
               exit paragraph
           end-if
           if templine(1:2) = '{%'
               perform handle-tag-line
               exit paragraph
           end-if
           perform substitute-and-display
           .

       handle-tag-line.
           if templine(1:10) = '{% include'
               perform handle-include
           else if templine(1:6) = '{% if '
               perform handle-if-block
           else if templine(1:7) = '{% for '
               perform handle-for-block
           else if templine(1:9) = '{% block '
               perform handle-block
           else
               continue
           end-if
           .

       handle-include.
           move spaces to include-name
           if templine(12:1) = '"'
               unstring templine delimited by '"' into tag-token-1 include-name
           else
               unstring templine delimited by ' ' into tag-token-1 tag-token-2
                   tag-token-3 tag-token-4
               move function trim(tag-token-3) to lookup-name
               perform lookup-var-by-name
               move lookup-result to include-name
           end-if
           if function trim(include-name) = spaces
               exit paragraph
           end-if
           call 'ssrtemplate' using the-vars include-name
           .

       handle-if-block.
           unstring templine delimited by ' ' into tag-token-1 tag-token-2
               if-var-name tag-token-4 tag-token-3
           move function trim(if-var-name) to lookup-name
           perform normalize-tag-token
           move lookup-name to if-var-name
           perform lookup-var-by-name
           if function trim(lookup-result) = spaces
               move "n" to if-truthy
           else
               move "y" to if-truthy
           end-if
           move 0 to true-line-count false-line-count
           move "t" to branch-mode
           perform until stack-line-idx(render-depth)
               >= stack-line-count(render-depth)
               add 1 to stack-line-idx(render-depth)
               move function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) to templine
               if templine = '{% endif %}'
                   exit perform
               end-if
               if templine = '{% else %}'
                   move "f" to branch-mode
               else
                   if branch-mode = "t"
                       add 1 to true-line-count
                       move templine to true-text(true-line-count)
                   else
                       add 1 to false-line-count
                       move templine to false-text(false-line-count)
                   end-if
               end-if
           end-perform
           if if-truthy = "y"
               perform varying block-line-idx from 1 by 1
                   until block-line-idx > true-line-count
                   move true-text(block-line-idx) to templine
                   perform process-line
               end-perform
           else
               perform varying block-line-idx from 1 by 1
                   until block-line-idx > false-line-count
                   move false-text(block-line-idx) to templine
                   perform process-line
               end-perform
           end-if
           .

       handle-for-block.
           unstring templine delimited by ' ' into tag-token-1 tag-token-2
               for-prefix tag-token-4 for-count-var tag-token-3
           move function trim(for-prefix) to for-prefix
           move function trim(for-count-var) to lookup-name
           perform normalize-tag-token
           move lookup-name to for-count-var
           perform lookup-var-by-name
           move function numval(function trim(lookup-result)) to for-max
           if for-max < 1
               perform skip-to-endfor
               exit paragraph
           end-if
           move 0 to loop-line-count
           perform until stack-line-idx(render-depth)
               >= stack-line-count(render-depth)
               add 1 to stack-line-idx(render-depth)
               move function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) to templine
               if templine = '{% endfor %}'
                   exit perform
               end-if
               add 1 to loop-line-count
               move templine to loop-text(loop-line-count)
           end-perform
           string
               function trim(for-prefix) delimited by size
               "_id" delimited by size
               into loop-id-name
           end-string
           string
               function trim(for-prefix) delimited by size
               "_title" delimited by size
               into loop-title-name
           end-string
           perform varying for-index from 1 by 1 until for-index > for-max
               perform inject-loop-vars
               perform varying loop-line-idx from 1 by 1
                   until loop-line-idx > loop-line-count
                   move loop-text(loop-line-idx) to templine
                   perform process-line
               end-perform
           end-perform
           perform clear-loop-vars
           .

       skip-to-endfor.
           perform until stack-line-idx(render-depth)
               >= stack-line-count(render-depth)
               add 1 to stack-line-idx(render-depth)
               if function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) = '{% endfor %}'
                   exit perform
               end-if
           end-perform
           .

       handle-block.
           unstring templine delimited by ' ' into tag-token-1 block-name
               tag-token-3
           move function trim(block-name) to lookup-name
           perform lookup-var-by-name
           if function trim(lookup-result) not = spaces
               display function trim(lookup-result)
               perform skip-to-endblock
               exit paragraph
           end-if
           perform until stack-line-idx(render-depth)
               >= stack-line-count(render-depth)
               add 1 to stack-line-idx(render-depth)
               move function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) to templine
               if templine = '{% endblock %}'
                   exit perform
               end-if
               perform process-line
           end-perform
           .

       skip-to-endblock.
           perform until stack-line-idx(render-depth)
               >= stack-line-count(render-depth)
               add 1 to stack-line-idx(render-depth)
               if function trim(
                   stack-line-text(
                       render-depth,
                       stack-line-idx(render-depth)
                   )
               ) = '{% endblock %}'
                   exit perform
               end-if
           end-perform
           .

       inject-loop-vars.
           move spaces to loop-field-id loop-field-title
           move for-index to for-index-num
           string
               function trim(for-prefix) delimited by size
               "_id_" delimited by size
               for-index-num delimited by space
               into loop-field-id
           end-string
           string
               function trim(for-prefix) delimited by size
               "_title_" delimited by size
               for-index-num delimited by space
               into loop-field-title
           end-string
           move loop-field-id to lookup-name
           perform lookup-var-by-name
           move lookup-result to SSR-varvalue(loop-slot-id)
           move loop-id-name to SSR-varname(loop-slot-id)
           move loop-field-title to lookup-name
           perform lookup-var-by-name
           move lookup-result to SSR-varvalue(loop-slot-title)
           move loop-title-name to SSR-varname(loop-slot-title)
           .

       clear-loop-vars.
           move spaces to SSR-varname(loop-slot-id) SSR-varvalue(loop-slot-id)
           move spaces to SSR-varname(loop-slot-title) SSR-varvalue(loop-slot-title)
           .

       lookup-var-by-name.
           move spaces to lookup-result
           perform varying counter from 1 by 1 until counter > 99
               if function trim(SSR-varname(counter))
                   = function trim(lookup-name)
                   move SSR-varvalue(counter) to lookup-result
                   exit perform
               end-if
           end-perform
           .

       normalize-tag-token.
           inspect lookup-name replacing all '}' by ' '
           inspect lookup-name replacing all '%' by ' '
           move function trim(lookup-name) to lookup-name
           .

       substitute-and-display.
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
           .

       end program ssrtemplate.
