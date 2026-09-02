FROM golang:1.26-alpine@sha256:ce864e7223ac17b1775e6fd0b4c0db580c2eb50e7953a427916379e4b92a1628 AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY *.go .
COPY *ping .
RUN go build .

FROM alpine:edge@sha256:115729ec5cb049ba6359c3ab005ac742012d92bbaa5b8bc1a878f1e8f62c0cb8
RUN mkdir -p /usr/app/src
WORKDIR /usr/src/app
COPY --from=build /app/tcping .
COPY --from=build /app/*ping .

RUN chmod +x /usr/src/app/*ping

RUN apk --no-cache add ca-certificates tzdata
USER 1000
HEALTHCHECK --interval=5s --timeout=3s CMD ps aux | grep '[s]h ping' || exit 1
RUN ls /usr/src/app/
ENTRYPOINT ["sh", "/usr/src/app/healthping"]
