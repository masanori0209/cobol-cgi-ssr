       identification division.
       program-id. postserv.

       environment division.
       input-output section.
       file-control.
           select posts-file assign to posts-path
               organization is indexed
               access mode is dynamic
               record key is post-key
               file status is posts-fs.

       data division.
       file section.
       fd posts-file.
       01 post-record.
          05 post-key   pic 9(4).
          05 post-title pic x(40).
          05 post-body  pic x(120).

       working-storage section.
       01 posts-path pic x(128) value "/app/data/posts.dat".
       01 posts-fs pic xx.
       01 posts-html pic x(2048).
       01 row-html pic x(512).
       01 table-acc pic x(2048).
       01 table-tmp pic x(2048).
       01 table-next pic x(2048).
       01 post-found pic x(1).
       01 post-id-in pic x(4).
       01 post-id-num pic 9(4).
       01 post-id-ch pic z(4).
       01 post-id-disp pic 9(4).
       01 post-title-out pic x(40).
       01 post-body-out pic x(120).
       01 new-title pic x(40).
       01 new-body pic x(120).
       01 new-id pic x(4).
       01 new-id-num pic 9(4).
       01 max-key pic 9(4) value 0.
       01 lookup-key-num pic 9(4).

       linkage section.
       01 request-type pic x(10).
       01 lookup-id pic x(4).
       01 lookup-found pic x(1).
       01 lookup-title pic x(40).
       01 lookup-body pic x(120).
       01 list-html pic x(4096).
       01 add-title pic x(40).
       01 add-body pic x(120).
       01 add-id-out pic x(4).

       procedure division using
           request-type
           lookup-id lookup-found lookup-title lookup-body
           list-html
           add-title add-body add-id-out.

           evaluate request-type(1:4)
               when "INIT"
                   perform ensure-posts-file
               when "LIST"
                   perform build-posts-list-html
                   move function trim(posts-html trailing) to list-html
               when "LOOK"
                   move lookup-id to post-id-in
                   perform lookup-post-by-id
                   move post-found to lookup-found
                   move post-title-out to lookup-title
                   move post-body-out to lookup-body
               when "ADD"
                   move add-title to new-title
                   move add-body to new-body
                   perform add-post-record
                   move new-id to add-id-out
           end-evaluate
           goback.

       ensure-posts-file.
           open input posts-file
           if posts-fs = "00"
               move 1 to post-key
               read posts-file key is post-key
                   invalid key
                       close posts-file
                       perform seed-posts-file
                       goback
               end-read
               close posts-file
               goback
           end-if
           perform seed-posts-file
           .

       seed-posts-file.
           open output posts-file
           move 1 to post-key
           move "CGI was SSR from the beginning" to post-title
           move "HTML on stdout is server-side rendering." to post-body
           write post-record
           move 2 to post-key
           move "Routing costs more than rendering" to post-title
           move "PATH_INFO matching took more lines than DISPLAY HTML." to post-body
           write post-record
           move 3 to post-key
           move "VOS3 EOL is a different migration" to post-title
           move "This demo uses indexed files under data/." to post-body
           write post-record
           close posts-file
           .

       lookup-post-by-id.
           move "n" to post-found
           move spaces to post-title-out post-body-out
           move function numval(function trim(post-id-in)) to lookup-key-num
           move lookup-key-num to post-key
           open input posts-file
           if posts-fs not = "00"
               exit paragraph
           end-if
           read posts-file key is post-key
               invalid key
                   close posts-file
                   exit paragraph
           end-read
           move "y" to post-found
           move post-title to post-title-out
           move post-body to post-body-out
           close posts-file
           .

       build-posts-list-html.
           move
               "<table><thead><tr><th>ID</th><th>Title</th></tr></thead><tbody>"
               to table-acc
           open input posts-file
           if posts-fs = "00"
               perform varying post-id-num from 1 by 1 until post-id-num > 99
                   move post-id-num to post-key
                   read posts-file key is post-key
                       invalid key
                           continue
                   end-read
                   move post-key to post-id-disp
                   move post-id-disp to post-id-in
                   move spaces to row-html
                   string
                       "<tr><td>" delimited by size
                       function trim(post-id-in) delimited by size
                       "</td><td><a href='/posts/" delimited by size
                       function trim(post-id-in) delimited by size
                       "'>" delimited by size
                       function trim(post-title) delimited by size
                       "</a></td></tr>" delimited by size
                       into row-html
                   move function trim(table-acc trailing) to table-tmp
                   string
                       table-tmp delimited by size
                       row-html delimited by size
                       into table-next
                   move function trim(table-next trailing) to table-acc
               end-perform
               close posts-file
           end-if
           move spaces to posts-html
           move function trim(table-acc trailing) to table-tmp
           string
               table-tmp delimited by size
               "</tbody></table>" delimited by size
               into posts-html
           .

       add-post-record.
           move spaces to new-id
           open i-o posts-file
           if posts-fs = "35"
               perform ensure-posts-file
               open i-o posts-file
           end-if
           move 0 to max-key
           perform varying post-id-num from 1 by 1 until post-id-num > 99
               move post-id-num to post-key
               perform note-post-key-if-found
           end-perform
           add 1 to max-key
           move max-key to post-key new-id-num
           move new-title to post-title
           move new-body to post-body
           write post-record
           close posts-file
           move new-id-num to post-id-ch
           move spaces to new-id
           move function trim(post-id-ch trailing) to new-id
           .

       note-post-key-if-found.
           read posts-file key is post-key
               invalid key
                   exit paragraph
           end-read
           if post-key > max-key
               move post-key to max-key
           end-if
           .

       end program postserv.
