#!/bin/env python

import re
import sys

class Point:
    def __init__(self, position, vector):
        self.position = position
        self.vector = vector

    def step(self):
        self.position = (self.position[0] + self.vector[0], self.position[1] + self.vector[1])

    def stepback(self):
        self.position = (self.position[0] - self.vector[0], self.position[1] - self.vector[1])

points = []

with open('input.txt') as f:
    for line in f.readlines():
        result = re.match(r"position=<\s*(\-?\d+),\s*(\-?\d+)> velocity=<\s*(\-?\d+),\s*(\-?\d+)>", line)
        p = Point((int(result[1]), int(result[2])), (int(result[3]), int(result[4])))
        points.append(p)

def print_board(pts):
    max_x = max([p.position[0] for p in pts])
    max_y = max([p.position[1] for p in pts])
    min_x = min([p.position[0] for p in pts])
    min_y = min([p.position[1] for p in pts])

    board = {}
    for p in pts:
        board[p.position] = True

    for y in range(min_y, max_y+1):
        for x in range(min_x, max_x+1):
            pos = (x, y)
            if pos in board:
                print('#', end='')
            else:
                print(' ', end='')
        print()

seconds = 0
prev_range = 1000000000000

# loop and the yrange will converge, then start separating. Once it starts growing, step back one and print.
while True:
    ys = [p.position[1] for p in points]
    rng = max(ys) - min(ys)

    if rng > prev_range:
        [p.stepback() for p in points]
        print("{} seconds".format(seconds-1))
        print_board(points)
        exit(0)

    prev_range = rng
    seconds += 1
    [p.step() for p in points]
