package main

// correct: 143, 123

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

type turn int
type direction int

const (
	_              = iota
	TURN_LEFT turn = 1 << (10 * iota)
	TURN_RIGHT
	TURN_STRAIGHT
)

const (
	_                = iota
	DIR_UP direction = 1 << (10 * iota)
	DIR_DOWN
	DIR_LEFT
	DIR_RIGHT
)

var (
	turnOrder = []turn{
		TURN_LEFT,
		TURN_STRAIGHT,
		TURN_RIGHT,
	}

	turnDirection = map[direction]map[turn]direction{
		DIR_UP: map[turn]direction{
			TURN_LEFT:     DIR_LEFT,
			TURN_STRAIGHT: DIR_UP,
			TURN_RIGHT:    DIR_RIGHT,
		},
		DIR_DOWN: map[turn]direction{
			TURN_LEFT:     DIR_RIGHT,
			TURN_STRAIGHT: DIR_DOWN,
			TURN_RIGHT:    DIR_LEFT,
		},
		DIR_LEFT: map[turn]direction{
			TURN_LEFT:     DIR_DOWN,
			TURN_STRAIGHT: DIR_LEFT,
			TURN_RIGHT:    DIR_UP,
		},
		DIR_RIGHT: map[turn]direction{
			TURN_LEFT:     DIR_UP,
			TURN_STRAIGHT: DIR_RIGHT,
			TURN_RIGHT:    DIR_DOWN,
		},
	}
)

type car struct {
	direction direction
	turnIndex int
}

type track struct {
	x, y  int
	left  *track
	right *track
	up    *track
	down  *track
	char  byte
	car   *car
}

func (t *track) String() string {
	ch := t.char
	if t.car != nil {
		ch = directionPrintMap[t.car.direction]
	}
	return fmt.Sprintf("%c", ch)
}

func (t *track) addCar(c *car) error {
	if t.car != nil {
		fmt.Printf("collision at %d,%d on iteration %d\n\n", t.x, t.y, iterations+1)
		t.car = nil
		return nil
	}

	t.car = c

	// turn logic
	if t.char == '+' {
		t.car.direction = turnDirection[t.car.direction][turnOrder[t.car.turnIndex]]
		t.car.turnIndex++
		if t.car.turnIndex == 3 {
			t.car.turnIndex = 0
		}
	} else {
		if (t.car.direction == DIR_RIGHT && t.right == nil) ||
			(t.car.direction == DIR_LEFT && t.left == nil) {
			if t.up != nil {
				t.car.direction = DIR_UP
			}
			if t.down != nil {
				t.car.direction = DIR_DOWN
			}
		}

		if (t.car.direction == DIR_UP && t.up == nil) ||
			(t.car.direction == DIR_DOWN && t.down == nil) {
			if t.left != nil {
				t.car.direction = DIR_LEFT
			}
			if t.right != nil {
				t.car.direction = DIR_RIGHT
			}
		}
	}

	return nil
}

func (t *track) drive() error {
	if t.car == nil {
		return nil
	}

	var next *track

	// intended next directions
	if t.car.direction == DIR_RIGHT && t.right != nil {
		next = t.right
	}
	if t.car.direction == DIR_LEFT && t.left != nil {
		next = t.left
	}
	if t.car.direction == DIR_UP && t.up != nil {
		next = t.up
	}
	if t.car.direction == DIR_DOWN && t.down != nil {
		next = t.down
	}

	if next == nil {
		panic(fmt.Sprintf("wtf! %d,%d", t.x, t.y))
	}

	c := t.car
	t.car = nil
	return next.addCar(c)
}

var (
	board      [][]*track // board[y][x]
	cars       []*car
	iterations = 0

	trackFunc = map[byte]func(x, y int){
		'-': func(x, y int) {
			n := &track{x: x, y: y, char: '-', left: board[y][x-1]}
			board[y][x-1].right = n
			board[y][x] = n
		},
		'|': func(x, y int) {
			n := &track{x: x, y: y, char: '|', up: board[y-1][x]}
			board[y-1][x].down = n
			board[y][x] = n
		},
		'/': func(x, y int) {
			n := &track{x: x, y: y, char: '/'}

			if x-1 >= 0 && board[y][x-1] != nil {
				if board[y][x-1].char == '-' || board[y][x-1].char == '+' {
					n.left = board[y][x-1]
					board[y][x-1].right = n

					n.up = board[y-1][x]
					board[y-1][x].down = n
				}
			}

			board[y][x] = n
		},
		'\\': func(x, y int) {
			n := &track{x: x, y: y, char: '\\'}

			if x-1 >= 0 && board[y][x-1] != nil && (board[y][x-1].char == '-' || board[y][x-1].char == '+') {
				n.left = board[y][x-1]
				board[y][x-1].right = n
			} else if y-1 >= 0 && board[y-1][x] != nil && (board[y-1][x].char == '|' || board[y-1][x].char == '+') {
				n.up = board[y-1][x]
				board[y-1][x].down = n
			}

			board[y][x] = n
		},
		'+': func(x, y int) {
			n := &track{x: x, y: y, char: '+', left: board[y][x-1], up: board[y-1][x]}
			board[y][x-1].right = n
			board[y-1][x].down = n
			board[y][x] = n
		},
	}

	directionMap = map[byte]direction{
		'>': DIR_RIGHT,
		'<': DIR_LEFT,
		'^': DIR_UP,
		'v': DIR_DOWN,
	}
	directionPrintMap = map[direction]byte{
		DIR_RIGHT: '>',
		DIR_LEFT:  '<',
		DIR_UP:    '^',
		DIR_DOWN:  'v',
	}
)

func createCarFunc(ch byte, f func(x, y int)) func(int, int) {
	return func(x, y int) {
		f(x, y)
		board[y][x].car = &car{direction: directionMap[ch]}
	}
}

func printBoard() {
	for y := range board {
		for x := range board[y] {
			if board[y][x] == nil {
				fmt.Print(" ")
			} else {
				t := board[y][x]
				fmt.Print(t.String())
			}
		}
		fmt.Println()
	}
	fmt.Printf("%d iterations\n", iterations)
}

func iterate() error {
	carLocations := map[*car][]int{}

	for y := range board {
		for x := range board[y] {
			t := board[y][x]
			if t != nil {
				if t.car == nil {
					continue
				}
				if _, ok := carLocations[t.car]; ok {
					continue
				}

				carLocations[t.car] = []int{x, y}
				if err := t.drive(); err != nil {
					return err
				}
			}
		}
	}
	iterations++

	if len(carLocations) == 1 {
		fmt.Printf("%#v\n", carLocations)
		return fmt.Errorf("done")
	}
	if len(carLocations) == 0 {
		return fmt.Errorf("no more cars!")
	}

	return nil
}

func main() {
	input, _ := ioutil.ReadFile(os.Args[1])

	trackFunc['>'] = createCarFunc('>', trackFunc['-'])
	trackFunc['<'] = createCarFunc('<', trackFunc['-'])
	trackFunc['v'] = createCarFunc('v', trackFunc['|'])
	trackFunc['^'] = createCarFunc('^', trackFunc['|'])

	board = make([][]*track, 0)
	for y, str := range strings.Split(string(input), "\n") {
		ba := []byte(str)
		board = append(board, make([]*track, len(ba)))

		for x, b := range ba {
			f, exists := trackFunc[b]
			if exists {
				f(x, y)
			}
		}
		y++
	}

	for {
		// printBoard()
		// fmt.Scanln()
		// fmt.Print("\n\n\n")

		err := iterate()
		if err != nil {
			fmt.Printf("err: %v\n", err)
			break
		}
	}
}
