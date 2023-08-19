package main

import (
	"embed"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"github.com/webview/webview"
)

//go:embed public_html/*
var staticFiles embed.FS

var (
	port      = flag.Int("port", 8765, "web server port")
	directory = flag.String("directory", ".", "directory to serve files from")
)

func main() {
	flag.Parse()

	http.HandleFunc("/", handleRequest)
	address := fmt.Sprintf(":%d", *port)
	log.Printf("Starting server on http://localhost%s\n", address)
 	go http.ListenAndServe(address, nil)

	// Функция, вызываемая при загрузке веб-страницы
	onPageLoaded := func(w webview.WebView, url string) {
		// Вы можете выполнить дополнительные действия при загрузке страницы
	}

	// Создаем новое окно WebView
	w := webview.New(false)
	defer w.Destroy()
	w.SetTitle("RESTAR")
	w.SetSize(800, 600, webview.HintNone)
	w.Navigate("http://localhost" + address)

	// Задаем функцию, вызываемую при загрузке страницы
	w.Bind("onPageLoaded", onPageLoaded)

	// Запускаем окно WebView
	w.Run()



}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	requestedFile := r.URL.Path[1:]
	if requestedFile == "" {
		requestedFile = "login.html"
	}
	log.Printf("Requested file: %s\n", requestedFile)

	// create full path to requested file:
	fullPathToFile := *directory + "/" + requestedFile
	if fileExists(fullPathToFile) {
		log.Printf("Serving file from current directory: %s\n", fullPathToFile)
		http.ServeFile(w, r, fullPathToFile)
		return
	}

	if fileExistsInStatic(requestedFile) {
		log.Printf("Serving file from embedded static directory: %s\n", requestedFile)
		fileData, err := staticFiles.ReadFile(filepath.Join("public_html", requestedFile))
		if err != nil {
			log.Printf("Error reading embedded file: %s\n", err.Error())
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}

		// Устанавливаем MIME-тип в зависимости от расширения файла
		contentType := getContentType(requestedFile)
		w.Header().Set("Content-Type", contentType)
		w.Write(fileData)
		return
	}

	log.Printf("File not found: %s\n", requestedFile)
	http.NotFound(w, r)
}

func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

func fileExistsInStatic(filename string) bool {
	_, err := staticFiles.ReadFile(filepath.Join("public_html", filename))
	return err == nil
}

func getContentType(filename string) string {
	extension := filepath.Ext(filename)
	switch strings.ToLower(extension) {
	case ".html":
		return "text/html"
	case ".js":
		return "application/javascript"
	case ".css":
		return "text/css"
	case ".png":
		return "image/png"
	default:
		return "application/octet-stream"
	}
}
