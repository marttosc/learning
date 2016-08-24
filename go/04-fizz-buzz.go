package main

import (
	"fmt"
)

func main() {
	const (
		fizz int = 3
		buzz int = 5
	)

	for i := 1; i <= 100; i++ {
		found := false

		if i%fizz == 0 {
			fmt.Print("fizz")

			found = true
		}

		if i%buzz == 0 {
			fmt.Print("buzz")

			found = true
		}

		if !found {
			fmt.Printf("%v", i)
		}

		fmt.Println()
	}
}
