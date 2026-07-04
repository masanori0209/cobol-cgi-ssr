FROM ubuntu:24.04 AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gnucobol ca-certificates \
  && rm -rf /var/lib/apt/lists/*
COPY . /app
RUN chmod +x scripts/build.sh && ./scripts/build.sh \
  && cobc -x -free -I src/copy src/seedposts.cbl -o seedposts \
  && ./seedposts

FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends apache2 libcob4 \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app /app
WORKDIR /app
RUN chmod +x scripts/init-data.sh && ./scripts/init-data.sh \
  && chown -R www-data:www-data data
EXPOSE 80
CMD ["-D", "FOREGROUND", "-f", "/app/apache.conf"]
ENTRYPOINT ["/usr/sbin/apachectl"]
