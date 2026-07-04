       move 9 to nroutes.

       move "/" to routing-pattern(1).
       move "GET" to routing-method(1).
       move "home" to routing-destiny(1).

       move "/about" to routing-pattern(2).
       move "GET" to routing-method(2).
       move "about" to routing-destiny(2).

       move "/posts/new" to routing-pattern(3).
       move "GET" to routing-method(3).
       move "postnewget" to routing-destiny(3).

       move "/posts/new" to routing-pattern(4).
       move "POST" to routing-method(4).
       move "postnewpost" to routing-destiny(4).

       move "/posts" to routing-pattern(5).
       move "GET" to routing-method(5).
       move "postslist" to routing-destiny(5).

       move "/posts/%id" to routing-pattern(6).
       move "GET" to routing-method(6).
       move "postdetail" to routing-destiny(6).

       move "/login" to routing-pattern(7).
       move "GET" to routing-method(7).
       move "loginform" to routing-destiny(7).

       move "/login" to routing-pattern(8).
       move "POST" to routing-method(8).
       move "loginpost" to routing-destiny(8).

       move "/logout" to routing-pattern(9).
       move "GET" to routing-method(9).
       move "logout" to routing-destiny(9).
