package main

import (
	"fmt"
	"math"
)

func NewtonMethod(x float64) float64 {
	if x == 0 { return 0 }

	z := 1.0

	for i := 1; i < int(x); i++ {
		z = z - ((math.Pow(z, 2) - x) / (2 * z))
	}

	return z
}

func main() {
	fmt.Print("Sqrt using Newton's method: ")
	fmt.Println(NewtonMethod(4))
}
