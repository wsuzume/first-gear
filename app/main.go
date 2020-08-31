package main

import (
    "log"
    "net/http"

		//"github.com/boltdb/bolt"
    //"github.com/gorilla/websocket"

		//"github.com/ignite/app/env"
)

const LISTEN_PORT = ":80"

func main() {
    // localhost:8080 でアクセスした時に index.html を読み込む
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        http.ServeFile(w, r, "index.html")
    })

    // サーバーの起動
    err := http.ListenAndServe(LISTEN_PORT, nil)
    if err != nil {
        log.Fatal("error starting http server::", err)
        return
    }
}
