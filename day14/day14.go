package main

import (
	"flag"
	"fmt"
)

var (
	end   *recipe
	cooks []*recipe
	total int
)

type recipe struct {
	value int
	prev  *recipe
	next  *recipe
}

func (n *recipe) String() string {
	for i := range cooks {
		if n == cooks[i] {
			switch i {
			case 0:
				return fmt.Sprintf("(%d) ", n.value)
			case 1:
				return fmt.Sprintf("[%d] ", n.value)
			}
		}
	}

	return fmt.Sprintf("%d ", n.value)
}

func bootstrap(values ...int) {
	for _, v := range values {
		n := &recipe{value: v}
		if end == nil {
			n.prev = n
			n.next = n
			end = n
			continue
		}

		n.next = end.next
		end.next = n
		n.prev = end
		end = n
	}

	total += len(values)
}

func printRecipes() {
	for n := end.next; n != end; n = n.next {
		fmt.Print(n.String())
	}
	fmt.Print(end.String() + "\n")
}

func recipeString(n *recipe, num int) string {
	bytes := make([]byte, num)
	for i := num - 1; i >= 0; i-- {
		bytes[i] = byte(n.value) + 48
		n = n.prev
	}
	return string(bytes)
}

func createNewRecipes() []int {
	sum := 0
	for _, n := range cooks {
		sum += n.value
	}

	if sum < 10 {
		return []int{sum}
	} else {
		return []int{1, sum - 10}
	}
}

func moveCook(idx int) {
	n := cooks[idx]
	steps := 1 + n.value
	for i := 0; i < steps; i++ {
		n = n.next
	}
	cooks[idx] = n
}

func main() {
	// my input was 110201
	var neededLength int
	var neededString string
	flag.IntVar(&neededLength, "part1-input", 0, "part1 input")
	flag.StringVar(&neededString, "part2-input", "", "part2 input")
	flag.Parse()

	if neededLength == 0 && neededString == "" {
		fmt.Println("Must provide either -part1-input or -part2-input!")
		return
	}

	scoreLen := 10

	bootstrap(3, 7)
	cooks = []*recipe{
		end.next,
		end,
	}

	for {
		for _, val := range createNewRecipes() {
			bootstrap(val)

			// check for part 1
			if neededLength != 0 {
				if total == neededLength+scoreLen {
					fmt.Printf("reached %d\nscore: %s\n", neededLength, recipeString(end, scoreLen))
					return
				}
			}

			if neededString != "" {
				if recipeString(end, len(neededString)) == neededString {
					fmt.Printf("found at %d\n", total-len(neededString))
					return
				}
			}
		}

		for idx := range cooks {
			moveCook(idx)
		}
	}
}
