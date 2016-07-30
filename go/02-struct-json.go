package main

import (
	"fmt"
	"strings"
	"encoding/json"
)

type User struct {
	FirstName string `json:"first_name"`
	LastName string `json:"last_name"`
	Age int
	Languages []string `json:"languages"`
}

func print_user(jsonData string, age int) string {
	var output string

	res := &User{}

	json.Unmarshal([]byte(jsonData), &res)

	if res.Age > age {
		output = fmt.Sprintf("User %s %s, who's %d can code in the following languages: %s\n", res.FirstName, res.LastName,  res.Age, strings.Join(res.Languages, ", "))    
	} else {
	    output = fmt.Sprintf("User %s %s must be over %d before we can print their details", res.FirstName, res.LastName, age)
	}

	return output
}

func main() {
	var age int = 18

	str := `{"first_name": "Gustavo", "last_name": "Marttos", "age": 19, "languages": ["php", "java", "ruby", "go"]}`

	fmt.Println(print_user(str, age))
}
