# We are going to containerize this "service" using multi stage docker

# Build stage
# Start from a Alpine Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang:1.9-alpine
WORKDIR /go/src/outyet
COPY outyet.go .
RUN go get -d ./... && go build -o outyet .

# Final Stage
FROM alpine:3.7
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/outyet .

# Document that the service listens on port 8080.
EXPOSE 8080
# Run the outyet command by default when the container starts.
ENTRYPOINT ./outyet