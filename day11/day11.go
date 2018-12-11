package main

import (
	"fmt"
)

var (
	gridSerial = 4842
	board      [][]*cell
)

type cell struct {
	posX, posY int
	powerLevel int
}

func (c *cell) calcPowerLevel() {
	rackId := c.posX + 10
	p := ((rackId * c.posY) + gridSerial) * rackId
	c.powerLevel = ((p / 100) % 10) - 5
}

func gridPower(posX, posY, square int) int {
	total := 0
	for x := 0; x < square; x++ {
		for y := 0; y < square; y++ {
			total += board[posX+x-1][posY+y-1].powerLevel
		}
	}
	return total
}

func main() {
	board = make([][]*cell, 300)
	for x := 0; x < 300; x++ {
		board[x] = make([]*cell, 300)
		for y := 0; y < 300; y++ {
			c := &cell{posX: x + 1, posY: y + 1}
			c.calcPowerLevel()
			board[x][y] = c
		}
	}

	var maxX, maxY, maxPower, maxSq int

	for sq := 1; sq < 300; sq++ {
		fmt.Printf("sq %d\n", sq)
		for x := 1; x < (300 - sq); x++ {
			for y := 1; y < (300 - sq); y++ {
				power := gridPower(x, y, sq)

				if power > maxPower {
					maxPower = power
					maxX = x
					maxY = y
					maxSq = sq
				}
			}
		}
	}

	fmt.Printf("Max Power: %d at %d,%d square %d\n", maxPower, maxX, maxY, maxSq)
}
