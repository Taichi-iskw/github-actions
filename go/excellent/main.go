package main

import "fmt"

// EvenOrOdd 関数を定義
func EvenOrOdd(n int) string {
	if n%2 == 0 {
		return "even"
	}
	return "odd"
}

func main() {
	fmt.Println(EvenOrOdd(10)) // "even"
}
