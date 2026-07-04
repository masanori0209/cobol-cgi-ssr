       identification division.
       program-id. cgifill.

       environment division.
       input-output section.
       file-control.
           select cgi-stdin assign to keyboard.

       data division.
       file section.
       fd cgi-stdin.
       01 stdin-chunk pic x(4096).

       working-storage section.
       01 content-len-num pic 9(8).
       01 body-len pic 9(8).
       01 scan-pos pic 9(8).
       01 pair-start pic 9(8).
       01 pair-len pic 9(8).
       01 pair-buf pic x(512).
       01 pair-idx pic 9(4).
       01 cookie-part pic x(256).
       01 cookie-rest pic x(768).
       01 cookie-idx pic 9(4).

       linkage section.
       copy "cgictx.cpy".

       procedure division using cgictx.
           move spaces to cgictx
           accept ctx-request-method from environment "REQUEST_METHOD"
           accept ctx-content-length from environment "CONTENT_LENGTH"
           accept ctx-cookie-raw from environment "HTTP_COOKIE"
           if ctx-request-method = "POST"
               move ctx-content-length to content-len-num
               if content-len-num > 4096
                   move 4096 to content-len-num
               end-if
               if content-len-num > 0
                   open input cgi-stdin
                   read cgi-stdin into ctx-post-body
                   close cgi-stdin
                   perform parse-form-body
               end-if
           end-if
           perform parse-session-cookie
           goback.

       parse-form-body.
           move content-len-num to body-len
           if body-len = 0
               move function length(function trim(ctx-post-body)) to body-len
           end-if
           move 1 to scan-pos pair-idx
           perform until scan-pos > body-len or pair-idx > 20
               move scan-pos to pair-start
               perform until scan-pos > body-len
                   or ctx-post-body(scan-pos:1) = "&"
                   add 1 to scan-pos
               end-perform
               compute pair-len = scan-pos - pair-start
               if pair-len > 0
                   move ctx-post-body(pair-start:pair-len) to pair-buf
                   unstring pair-buf delimited by "="
                       into ctx-fname(pair-idx) ctx-fvalue(pair-idx)
                   inspect ctx-fvalue(pair-idx)
                       replacing all "+" by " "
                   add 1 to pair-idx
               end-if
               add 1 to scan-pos
           end-perform
           .

       parse-session-cookie.
           if ctx-cookie-raw = spaces
               goback
           end-if
           move ctx-cookie-raw to cookie-rest
           perform varying cookie-idx from 1 by 1 until cookie-idx > 20
               unstring cookie-rest delimited by ";"
                   into cookie-part cookie-rest
               if cookie-part(1:8) = "ssr_sid="
                   move cookie-part(9:) to ctx-session-id
                   move function trim(ctx-session-id) to ctx-session-id
                   exit perform
               end-if
               if cookie-rest = spaces
                   exit perform
               end-if
           end-perform
           .

       end program cgifill.

       identification division.
       program-id. formget.

       data division.
       working-storage section.
       01 idx pic 9(4).

       linkage section.
       copy "cgictx.cpy".
       01 field-name pic x(40).
       01 field-value pic x(256).

       procedure division using cgictx field-name field-value.
           move spaces to field-value
           perform varying idx from 1 by 1 until idx > 20
               if function trim(ctx-fname(idx)) = function trim(field-name)
                   move ctx-fvalue(idx) to field-value
                   exit perform
               end-if
           end-perform
           goback.

       end program formget.

       identification division.
       program-id. cgiredirect.

       data division.
       working-storage section.
       01 crlf pic x value x'0d0a'.

       linkage section.
       01 redirect-location pic x(256).
       01 redirect-cookie pic x(256).

       procedure division using redirect-location redirect-cookie.
           display "Status: 302 Found" crlf
           display "Location: " function trim(redirect-location) crlf
           if redirect-cookie not = spaces
               display function trim(redirect-cookie) crlf
           end-if
           display crlf
           goback.

       end program cgiredirect.

       identification division.
       program-id. sessionrv.

       environment division.
       input-output section.
       file-control.
           select session-file assign to session-path
               organization is line sequential
               file status is session-fs.
           select seq-file assign to seq-path
               organization is line sequential
               file status is seq-fs.

       data division.
       file section.
       fd session-file.
       01 session-line pic x(80).
       fd seq-file.
       01 seq-line pic x(20).

       working-storage section.
       01 session-fs pic xx.
       01 seq-fs pic xx.
       01 session-path pic x(128).
       01 seq-path pic x(128) value "data/session.seq".
       01 seq-num pic 9(8) value 0.

       linkage section.
       01 session-op pic x(10).
       copy "cgictx.cpy".

       procedure division using session-op cgictx.
           evaluate session-op
               when "LOAD"
                   perform load-session
               when "CREATE"
                   perform create-session
               when "DELETE"
                   perform delete-session
           end-evaluate
           goback.

       load-session.
           if ctx-session-id = spaces
               goback
           end-if
           perform build-session-path
           open input session-file
           if session-fs not = "00"
               move spaces to ctx-session-id ctx-session-user
               goback
           end-if
           read session-file into ctx-session-user
           close session-file
           move function trim(ctx-session-user) to ctx-session-user
           if ctx-session-user = spaces
               move spaces to ctx-session-id
           end-if
           .

       create-session.
           perform next-session-id
           perform build-session-path
           open output session-file
           write session-line from ctx-session-user
           close session-file
           .

       delete-session.
           if ctx-session-id = spaces
               goback
           end-if
           perform build-session-path
           open output session-file
           move spaces to session-line
           write session-line
           close session-file
           move spaces to ctx-session-id ctx-session-user
           .

       build-session-path.
           move spaces to session-path
           string "data/sessions/" delimited by size
               function trim(ctx-session-id) delimited by space
               into session-path
           .

       next-session-id.
           move 0 to seq-num
           open input seq-file
           if seq-fs = "00"
               read seq-file into seq-line
               move seq-line to seq-num
               close seq-file
           end-if
           add 1 to seq-num
           move seq-num to seq-line
           open output seq-file
           write seq-line
           close seq-file
           move spaces to ctx-session-id
           string "SID" delimited by size
               seq-num delimited by size
               into ctx-session-id
           .

       end program sessionrv.
