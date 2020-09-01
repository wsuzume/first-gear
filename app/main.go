package main

import (
    "net/http"

		//"github.com/boltdb/bolt"
    //"github.com/gorilla/websocket"
		"github.com/gin-gonic/gin"

		//"github.com/ignite/app/env"
)

func IndexGet() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", gin.H{})
	}
}

const LISTEN_PORT = ":80"

func main() {
	r := gin.Default()

	r.LoadHTMLGlob("views/*")

	r.GET("/", IndexGet())

	r.Run(LISTEN_PORT)
}
