       01 posts-shared-data.
          05 post-found      pic x(1) value 'n'.
          05 post-id-in      pic x(4).
          05 post-title-out  pic x(40).
          05 post-body-out   pic x(120).
          05 posts-html      pic x(4096) value spaces.
          05 posts-table.
             10 post-entry occurs 3 times indexed by post-idx.
                15 post-id     pic x(4).
                15 post-title pic x(40).
                15 post-body  pic x(120).
