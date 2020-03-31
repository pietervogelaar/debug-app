FROM alpine:3.11

RUN apk --update --no-progress add --no-cache \
      bash \
      curl \
      busybox-extras \
      jq \
      openssl

COPY start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
