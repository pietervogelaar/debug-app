FROM golang:1.13.9-alpine AS builder

ENV GO111MODULE=on

# Install git + SSL ca certificates
# Git is required for fetching the dependencies
# Ca-certificates is required to call HTTPS endpoints
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

WORKDIR /go/src/debug-app/

COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux \
      go build -mod=vendor -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/debug-app .

############################

FROM alpine:3.21.3

WORKDIR /usr/local/bin

RUN apk update && \
    apk add --no-cache \
      bash \
      curl \
      busybox-extras \
      bind-tools \
      jq \
      ruby \
      openssl \
      openldap-clients \
      shadow && \
    useradd -u 5000 debug-app

# Import from builder
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/bin/debug-app /debug-app

RUN chown debug-app:debug-app /debug-app && \
    chmod 750 /debug-app

ENTRYPOINT ["/debug-app"]

USER debug-app

EXPOSE 8080
