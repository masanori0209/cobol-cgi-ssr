       01 cgictx.
          05 ctx-request-method pic x(10).
          05 ctx-content-length pic x(10).
          05 ctx-post-body     pic x(4096).
          05 ctx-cookie-raw    pic x(1024).
          05 ctx-session-id    pic x(32).
          05 ctx-session-user  pic x(40).
          05 ctx-form-fields.
             10 ctx-field occurs 20 times.
                15 ctx-fname  pic x(40).
                15 ctx-fvalue pic x(256).
