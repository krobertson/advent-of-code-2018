#!/bin/env python3

import re

#
# May be the lazy approach, but a pattern emerges after 101 generations, where
# each incremental generation is a fixed amount greater than the next. The
# printed tree is the same, just pushed out another index.
#
gens = 101
extra = 50000000000 - gens
zero = 0
state = []
transforms = {}

with open('input.txt') as f:
    for line in f.readlines():
        result = re.match(r"initial state: ([\.#]+)", line)
        if result:
            state = list(result[1])
        else:
            result = re.match(r"([\.#]+) => ([\.#])", line)
            if result:
                transforms[tuple(result[1])] = result[2]

def process(idx):
    if idx == 0:
        sub = tuple(['.', '.'] + state[idx:idx+3])
    elif idx == 1:
        sub = tuple(['.'] + state[idx-1:idx+3])
    elif len(state) - idx == 2:
        sub = tuple(state[idx-2:idx+2] + ['.'])
    elif len(state) - idx == 1:
        sub = tuple(state[idx-2:idx+1] + ['.', '.'])
    elif idx == -1:
        sub = tuple(['.', '.', '.'] + state[0:2])
    elif idx == len(state):
        sub = tuple(state[idx-2:idx] + ['.', '.', '.'])
    else:
        sub = tuple(state[idx-2:idx+3])
    if sub in transforms:
        return transforms[sub]
    else:
        return '.'

def newgen():
    new_state = []
    before = process(-1)
    if before == '#':
        new_state.append(before)
        global zero
        zero -= 1
    for idx in range(len(state)):
        new_state.append(process(idx))
    after = process(len(state))
    if after == '#':
        new_state.append(after)
    return new_state

def value():
    val = 0
    for idx in range(len(state)):
        if state[idx] == '#':
            val += zero + idx
    return val

print('00 / {}: {}'.format(len(state), ''.join(state)))
for gen in range(1, gens+1):
    state = newgen()
    print('{}: {}'.format(value(), ''.join(state)))

print('{}-{}: {}'.format(zero, zero+len(state), ''.join(state)))
print('value: {}'.format(value()))

baseline = value()
state = newgen()
increment = value() - baseline

print("Full generations: {}".format((extra * increment) + baseline))
