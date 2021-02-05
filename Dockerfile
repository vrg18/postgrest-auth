FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git curl

RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.4/dep-linux-amd64 && \
  chmod +x /usr/local/bin/dep

RUN mkdir -p $GOPATH/src/github.com/vrg18/postgrest-auth
WORKDIR $GOPATH/src/github.com/vrg18/postgrest-auth

COPY postgrest-auth/Gopkg.toml postgrest-auth/Gopkg.lock ./
RUN dep ensure -vendor-only

COPY postgrest-auth ./
RUN go build -o postgrest-auth cmd/postgrest-auth/main.go

FROM alpine
WORKDIR /root
RUN apk add -U --no-cache ca-certificates
COPY --from=builder /go/src/github.com/vrg18/postgrest-auth/postgrest-auth .
ENTRYPOINT ["./postgrest-auth"]
