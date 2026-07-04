       identification division.
       program-id. navbuild.

       data division.
       linkage section.
       copy "cgictx.cpy".
       01 nav-html pic x(512).

       procedure division using cgictx nav-html.
           if ctx-session-user not = spaces
               string
                   "Logged in as " delimited by size
                   function trim(ctx-session-user) delimited by space
                   " | <a href='/posts/new'>New post</a> | "
                   delimited by size
                   "<a href='/logout'>Logout</a>" delimited by size
                   into nav-html
           else
               move "<a href='/login'>Login</a>" to nav-html
           end-if
           goback.

       end program navbuild.
