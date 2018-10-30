import numpy as np
import tensorflow as tf
import random

# Build Network

# Input is (position, velocity)
x = tf.placeholder(tf.float32, [None, 2])
# Reward of current state
R = tf.placeholder(tf.float32, [None, 1])
# Action Mask
A = tf.placeholder(tf.float32, [None, 3])
# Qvalue of next state
nQ = tf.placeholder(tf.float32, [None, 1])

# Hidden Layer with 16 
w1 = tf.Variable(tf.random_normal([2, 16], stddev=0.1))
f1 = tf.matmul(x, w1)
# Final Output
w2 = tf.Variable(tf.random_normal([16, 3], stddev=0.1))
Q = tf.matmul(x, w2)

loss = tf.square(R + 0.95 * nQ - Q)
train = tf.train.GradientDescentOptimizer(0.001).minimize(cost)

sess = tf.Session()
init = tf.global_variables_initializer()
sess.run(init)

player = np.zeros((1, 2))
nextplayer = np.zeros((1, 2))
# Run Episode
for iteration in range(10) :
	#Reset Player
	player[0][0] = random.random() * 0.2 - 0.6
	player[0][1] = 0.
	
	#Run Step
	step = 0
	while step < 1000 and player[0][0] < 0.5 :
		# Use epsilon-greedy
		r = random.random()
		if r < 0.1 :
			action = random.randint(0, 2)
		else :
			res = sess.run(Q, {x : player})
			action = np.argmax(res[0])
		
		# Get Next State
		nextplayer[0][0] = player[0][0] + player[0][1]
		if nextplayer[0][0] < -1.2 :
			nextplayer[0][0] = -1.2
		nextplayer[0][1] = player[0][1] + 0.001 * action - 0.0025 * np.cos(3 * player[0][0])
		
		# Get Next Q Value
		nextQ = sess.run(Q, {x : nextplayer})
		
		# Get Action Mask
		ActionMask = np.zeros((1, 3))
		ActionMask[0][action] = 1.
		
		# Get Reward
		if player[0][0] >= 0.5 :
			reward = 0.
		else :
			reward = -1.
		
		# Update Q Value
		_, loss = sess.run([train, loss], {x : player, R : reward, A : ActionMask, nQ : nextQ})
		
		# Prepare Next Step
		player[0][0] = nextplayer[0][0]
		player[0][1] = nextplayer[0][1]