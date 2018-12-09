package main

import (
	"flag"
	"fmt"
)

type ring struct {
	num   int
	left  *ring
	right *ring
}

type player struct {
	num   int
	score int
}

func addRing(cur *ring, num int, p *player) *ring {
	if num%23 == 0 {
		n := cur
		for i := 0; i < 7; i++ {
			n = n.left
		}
		n.left.right = n.right
		n.right.left = n.left
		p.score += num + n.num
		return n.right
	}

	n := &ring{
		num:   num,
		left:  cur.right,
		right: cur.right.right,
	}
	cur.right.right.left = n
	cur.right.right = n
	return n
}

var (
	PLAYERS = 9
	MOVES   = 23
	PRINT   = true
)

func main() {
	flag.IntVar(&PLAYERS, "players", 9, "number of players")
	flag.IntVar(&MOVES, "moves", 23, "number of moves")
	flag.BoolVar(&PRINT, "print", true, "print the table")
	flag.Parse()

	root := &ring{num: 0}
	root.left = root
	root.right = root

	players := make([]*player, PLAYERS)
	for i := 0; i < PLAYERS; i++ {
		players[i] = &player{num: i + 1}
	}

	curRing := root
	curPlayer := 0

	for i := 1; i <= MOVES; i++ {
		curRing = addRing(curRing, i, players[curPlayer])
		curPlayer++
		if curPlayer%PLAYERS == 0 {
			curPlayer = 0
		}
	}

	if PRINT {
		fmt.Printf("right: %d ", root.num)
		for i := root.right; i.num != root.num; i = i.right {
			if i.num == curRing.num {
				fmt.Printf("(%d) ", i.num)
			} else {
				fmt.Printf("%d ", i.num)
			}
		}
		fmt.Println()
	}

	highestPlayer := players[0]
	for i := 1; i < len(players); i++ {
		if players[i].score > highestPlayer.score {
			highestPlayer = players[i]
		}
	}
	fmt.Printf("player %d had the highest score with %d\n", highestPlayer.num, highestPlayer.score)
}
