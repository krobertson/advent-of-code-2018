#!/bin/env python2.7

import sys
from collections import defaultdict

# labels = {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5:'F'}
labels = defaultdict(lambda: 'A')
coordinates = {}

with open('input.txt') as f:
    for line in f.readlines():
        x, y = line.split(', ')
        coordinates[(int(x), int(y))] = len(coordinates)

max_x = max([x for x,y in coordinates])
max_y = max([y for x,y in coordinates])

def print_board(board):
    for y in range(max_y+1):
        for x in range(max_x+1):
            if (x, y) in board:
                sys.stdout.write(labels[board[(x, y)]])
            else:
                sys.stdout.write(".")
        print ""

print "Board after coordinates:"
print_board(coordinates)
print

def distance(a, b):
    ax, ay = a
    bx, by = b
    return abs(ax - bx) + abs(ay - by)

def closest_coordinate(pt):
    distances = [(c, distance(pt, c)) for c in coordinates.keys()]
    mindist = min(distances, key=lambda i: i[1])

    # need to check if multiple
    coords_with_min = [i[0] for i in distances if i[1] == mindist[1]]
    if len(coords_with_min) > 1:
        return None
    return mindist[0]

board = {}
for x in range(max_x+1):
    for y in range(max_y+1):
        closest = closest_coordinate((x, y))
        if closest != None:
            board[(x,y)] = coordinates[closest]


print "Board with proximty"
print_board(board)
print

# Find coordinates which walk the borders
print max_x, max_y
infinite = []
for y in [0, max_y]:
    for x in range(max_x):
        c = (x,y)
        if c not in board: continue
        v = board[c]
        if v not in infinite:
            infinite.append(v)
for x in [0, max_x]:
    for y in range(max_y+1):
        c = (x,y)
        if c not in board: continue
        v = board[c]
        if v not in infinite:
            infinite.append(v)

# filter the board now to see what remains
for x in range(max_x+1):
    for y in range(max_y+1):
        c = (x, y)
        if c not in board: continue
        if board[c] in infinite: del board[c]

print "Board with infinites removed"
print_board(board)
print

# build count of references
counts = defaultdict(lambda: 0)
for x in range(max_x+1):
    for y in range(max_y+1):
        c = (x, y)
        if c not in board: continue
        counts[board[c]] += 1

print counts
max_value = max(counts, key=counts.get)
max_area = counts[max_value]
max_coord = [k for k, v in coordinates.items() if v == max_value]

print max_area
print max_coord

# print counts

# aaaaa.cccc
# aAaaa.cccc
# aaaddecccc
# aadddeccCc
# ..dDdeeccc
# bb.deEeecc
# bBb.eeee..
# bbb.eeefff
# bbb.eeffff
# bbb.ffffFf

# AAAAA.CCC
# AAAAA.CCC
# AAADDECCC
# AADDDECCC
# ..DDDEECC
# BB.DEEEEC
# BBB.EEEE.
# BBB.EEEFF
# BBB.EEFFF
# BBB.FFFFF
