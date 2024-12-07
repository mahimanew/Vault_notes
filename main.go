package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

// Define a struct to map the inner object
type APIData struct {
	ApiService string   `json:"ApiService"`
	Email      string   `json:"email"`
	Role       []string `json:"role"`
	UUID       string   `json:"uuid"`
}

func main() {
	// Define the file path
	filePath := "app.env"

	// Open the file
	file, err := os.Open(filePath)
	if err != nil {
		log.Fatalf("Failed to open file: %v", err)
	}
	defer file.Close()

	// Read the file content
	content, err := ioutil.ReadAll(file)
	if err != nil {
		log.Fatalf("Failed to read file: %v", err)
	}

	// Parse the JSON data into a map
	data := make(map[string]APIData)
	if err := json.Unmarshal(content, &data); err != nil {
		log.Fatalf("Failed to parse JSON: %v", err)
	}

	// Iterate over the map and print the parsed data
	for apiKey, apiData := range data {
		fmt.Printf("Key: %s\n", apiKey)
		fmt.Printf("  ApiService: %s\n", apiData.ApiService)
		fmt.Printf("  Email: %s\n", apiData.Email)
		fmt.Printf("  Role: %v\n", apiData.Role)
		fmt.Printf("  UUID: %s\n", apiData.UUID)
	}
}
