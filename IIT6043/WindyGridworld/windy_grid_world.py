# -*- coding = "utf-8" -*-
import numpy as np
import random

# Set Constant
ALPHA = 0.5
EPSILON = 0.1

# Set Wind
wind = np.zeros(10, dtype=np.int32)
wind[3] = 1
wind[4] = 1
wind[5] = 1
wind[6] = 2
wind[7] = 2
wind[8] = 1

# Set Initial Q value (x, y, action)
Q = np.zeros((10, 7, 9))

def NextPosition(x, y, action) :
	nx = x
	ny = y - wind[x]
	
	if action == 0:
		ny -= 1
	elif action == 1:
		ny += 1
	elif action == 2:
		nx += 1
	elif action == 3:
		nx -= 1
	elif action == 4:
		nx += 1
		ny -= 1
	elif action == 5:
		nx += 1
		ny += 1
	elif action == 6:
		nx -= 1
		ny -= 1
	elif action == 7:
		nx -= 1
		ny += 1
	
	if nx < 0:
		nx = 0
	elif nx > 9:
		nx = 9
	
	if ny < 0:
		ny = 0
	elif ny > 6:
		ny = 6
		
	return nx, ny

f_res = open("res3.txt", "w")
	
for iteration in range(10000) :
	# Reset Player
	player_x = 0
	player_y = 3
	step = 0
	while True:
		r = random.random()
		if r < EPSILON :
			action = random.randrange(0, 9)
		else :
			action = np.argmax(Q[player_x][player_y]);
		
		# Get Next Position
		player_next_x, player_next_y = NextPosition(player_x, player_y, action)
		
		# If reached goal, then reward is zeros
		# else reward is -1
		if (player_next_x == 7 and player_next_y == 3):
			reward = 0
		else :
			reward = -1
		
		# Update Q Value
		Q[player_x][player_y][action] += ALPHA * (reward + np.max(Q[player_next_x][player_next_y]) - Q[player_x][player_y][action])
		
		# If reached goal or maximum step (100) reached, exit the loop
		if (player_next_x == 7 and player_next_y == 3) :
			break
		elif step == 100 :
			step = -1
			break
		else :
			player_x = player_next_x
			player_y = player_next_y
		step += 1
	
	if step >= 0:
		print("It " + str(iteration) + " : Goal at " + str(step+1))
		f_res.write("It " + str(iteration) + " : Goal at " + str(step+1) + "\n")
	else :
		print("It " + str(iteration) + " : Terminated")
		f_res.write("It " + str(iteration) + " : Terminated\n")

f_map = open("map3.txt", "w")
for y in range(7):
	for x in range(10):
		action = np.argmax(Q[x][y]);
		if action == 0:
			f_map.write("↑")
		elif action == 1:
			f_map.write("↓")
		elif action == 2:
			f_map.write("→")
		elif action == 3:
			f_map.write("←")
		elif action == 4:
			f_map.write("↗")
		elif action == 5:
			f_map.write("↘")
		elif action == 6:
			f_map.write("↖")
		elif action == 7:
			f_map.write("↙")
		elif action == 8:
			f_map.write("○")
	f_map.write("\n")
		