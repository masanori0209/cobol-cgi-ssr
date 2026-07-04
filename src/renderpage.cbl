      *> Render layout.cow with standard template variables (framework entry).

       identification division.
       program-id. renderpage.

       data division.
       working-storage section.
       copy "thevars.cpy".

       linkage section.
       copy "pagectx.cpy".
       copy "cgictx.cpy".

       procedure division using page-ctx cgictx.
           call 'cgihtmlhdr'
           move spaces to the-vars
           move "page_title" to SSR-varname(1)
           move page-title to SSR-varvalue(1)
           move "page_body" to SSR-varname(2)
           move page-body to SSR-varvalue(2)
           move "session_user" to SSR-varname(3)
           move ctx-session-user to SSR-varvalue(3)
           move "page_template" to SSR-varname(4)
           move page-template to SSR-varvalue(4)
           move "extra_css" to SSR-varname(5)
           move extra-css to SSR-varvalue(5)
           move "extra_js" to SSR-varname(6)
           move extra-js to SSR-varvalue(6)
           move "page_script" to SSR-varname(7)
           move page-script to SSR-varvalue(7)
           if function trim(layout-name) = spaces
               move "layout.cow" to layout-name
           end-if
           call 'ssrtemplate' using the-vars layout-name
           goback.

       end program renderpage.
