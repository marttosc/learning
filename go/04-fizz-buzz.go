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
		if i % fizz == 0 {
			fmt.Print("fizz")
		}

		if i % buzz == 0 {
			fmt.Print("buzz")
		}

		if i % fizz != 0 && i % buzz != 0 {
			fmt.Print(i)
		}

		fmt.Println()
	}
}

