FROM golang:1.13.9-alpine as builder

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

FROM alpine:3.12.0

WORKDIR /usr/local/bin

RUN apk update && \
    apk add --no-cache \
        bash \
        curl \
        busybox-extras \
        bind-tools \
        jq \
        openssl

# Import from builder
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/bin/debug-app /debug-app

RUN chmod 750 /debug-app

ENTRYPOINT ["/debug-app"]

EXPOSE 8080
