       identification division.
       program-id. postlistfill.

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
       01 post-id-num pic 9(4).
       01 post-count-num pic 9(4).
       01 var-slot pic 9(4).
       01 var-name-buf pic x(99).
       01 id-num pic 9(4).

       linkage section.
       copy "thevars.cpy".
       01 filled-count pic 9(4).

       procedure division using the-vars filled-count.
           move 0 to filled-count post-count-num var-slot
           open input posts-file
           if posts-fs not = "00"
               perform store-post-count
               goback
           end-if
           perform varying post-id-num from 1 by 1 until post-id-num > 99
               move post-id-num to post-key
               move spaces to post-title
               read posts-file key is post-key
                   invalid key
                       move spaces to post-title
               end-read
               if post-title not = spaces
                   add 1 to post-count-num
                   add 1 to var-slot
                   move spaces to var-name-buf
                   move post-count-num to id-num
                   string "post_id_" delimited by size
                       id-num delimited by space
                       into var-name-buf
                   end-string
                   move var-name-buf to SSR-varname(var-slot)
                   move spaces to SSR-varvalue(var-slot)
                   move post-key to id-num
                   string id-num delimited by space
                       into SSR-varvalue(var-slot)
                   add 1 to var-slot
                   move spaces to var-name-buf
                   move post-count-num to id-num
                   string "post_title_" delimited by size
                       id-num delimited by space
                       into var-name-buf
                   end-string
                   move var-name-buf to SSR-varname(var-slot)
                   move post-title to SSR-varvalue(var-slot)
               end-if
           end-perform
           close posts-file
           perform store-post-count
           goback.

       store-post-count.
           add 1 to var-slot
           move "post_count" to SSR-varname(var-slot)
           move spaces to SSR-varvalue(var-slot)
           move post-count-num to id-num
           string id-num delimited by space into SSR-varvalue(var-slot)
           move var-slot to filled-count
           .

       end program postlistfill.
