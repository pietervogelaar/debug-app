package main

import (
	"fmt"

	"log"
	"net/http"
	"os"
)

func defaultHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "[Request]\n")
	fmt.Fprintf(w, "Host: \"%s\"\n", r.Host)
	fmt.Fprintf(w, "Headers: \"%+v\"\n", r.Header)
	fmt.Fprintf(w, "URI: \"%s\"\n", r.RequestURI)

	fmt.Fprintf(w, "\n")

	fmt.Fprintf(w, "[Environment]\n")
	for _, envPair := range os.Environ() {
		fmt.Fprintf(w, envPair+"\n")
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if os.Getenv("DEBUG") == "true" {
		fmt.Println(fmt.Sprintf("[Request] Host: \"%s\", Headers: \"%+v\", URI: \"%s\"",
			r.Host, r.Header, r.RequestURI))
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "UP")
}

func setupRoutes() {
	// Catch all, including deeper paths
	http.HandleFunc("/", defaultHandler)

	// Unique endpoints of this app that must have no collision with other apps
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/health/", healthHandler)

	if os.Getenv("DEV") == "true" {
		// Listen on localhost to avoid firewall dialog on macOS
		log.Fatal(http.ListenAndServe("localhost:8080", nil))
	} else {
		log.Fatal(http.ListenAndServe(":8080", nil))
	}
}

func main() {
	fmt.Println("Running debug-app")
	setupRoutes()
}
