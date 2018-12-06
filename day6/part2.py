#!/bin/env python2.7

import sys
from collections import defaultdict

# cutoff = 32
# labels = {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5:'F', 99: '#'}
# small_labels = {0: 'a', 1: 'b', 2: 'c', 3: 'd', 4: 'e', 5:'f', 99: '#'}

cutoff = 10000
labels = defaultdict(lambda: 'A')
small_labels = defaultdict(lambda: 'A')

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
            c = (x,y)
            if c in board:
                if c in coordinates:
                    sys.stdout.write(labels[board[(x, y)]])
                else:
                    sys.stdout.write(small_labels[board[(x, y)]])
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

def sum_distances(pt):
    distances = [distance(pt, c) for c in coordinates.keys()]
    return sum(distances)

board = {}
for x in range(max_x+1):
    for y in range(max_y+1):
        closest = closest_coordinate((x, y))
        if closest != None:
            board[(x,y)] = coordinates[closest]

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
for c, v in coordinates.items():
    board[c] = v

print "Board with infinites removed"
print_board(board)
print

safe_areas = {}
for x in range(max_x+1):
    for y in range(max_y+1):
        c = (x, y)
        total = sum_distances(c)
        if total < cutoff:
            safe_areas[c] = 99
# for c, v in coordinates.items():
    # safe_areas[c] = v

print "Areas that are safe"
print_board(safe_areas)
print "Total areas: {}".format(len(safe_areas))
