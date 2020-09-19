FROM golang:1.14.4

RUN go get -u github.com/gin-gonic/gin \
    && go get -u github.com/gorilla/csrf \
    && go get -u github.com/google/uuid \
    && go get -u github.com/boltdb/bolt \
    && go get -u github.com/go-sql-driver/mysql \
    && go get -u github.com/go-redis/redis

WORKDIR /go/src/github.com/ignite
