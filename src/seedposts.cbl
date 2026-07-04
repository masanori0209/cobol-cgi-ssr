       identification division.
       program-id. seedposts.

       environment division.
       input-output section.
       file-control.
           select posts-file assign to posts-path
               organization is indexed
               access mode is random
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
       01 posts-path pic x(128) value "data/posts.dat".
       01 posts-fs pic xx.

       procedure division.
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
           stop run.

       end program seedposts.
