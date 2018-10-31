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
Q = tf.matmul(f1, w2)

desQ = tf.reduce_sum(R + 0.95 * nQ)
loss = tf.square(tf.reduce_sum(tf.multiply(Q, A)) - desQ)
train = tf.train.GradientDescentOptimizer(0.001).minimize(loss)

sess = tf.Session()
init = tf.global_variables_initializer()
sess.run(init)

player = np.zeros((1, 2))
nextplayer = np.zeros((1, 2))
f_step = open("step.txt", "wt")
f_loss = open("loss.txt", "wt")
# Run Episode
for iteration in range(1, 5001) :
	#Reset Player
	player[0][0] = random.random() * 0.2 - 0.6
	player[0][1] = 0.
	
	#Run Step
	step = 0
	avgloss = 0.
	while step < 2000 and player[0][0] < 0.5 :
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
		nextplayer[0][1] = player[0][1] + 0.001 * (action-1) - 0.0025 * np.cos(3 * player[0][0])
		if nextplayer[0][1] < -0.07 :
			nextplayer[0][1] = -0.07
		elif nextplayer[0][1] > 0.07 :
			nextplayer[0][1] = 0.07
		
		# Get Next Q Value
		nextQ = sess.run(Q, {x : nextplayer})
		
		# Get Action Mask
		ActionMask = np.zeros((1, 3))
		ActionMask[0][action] = 1.
		
		# Get Reward
		if nextplayer[0][0] >= 0.5 :
			reward = 0.
		else :
			reward = -1.
		
		# Update Q Value
		_, res = sess.run([train, loss], {x : player, R : np.array([[reward]]), A : ActionMask, nQ : np.array([[np.max(nextQ[0])]])})
		avgloss += res
		
		# Prepare Next Step
		player[0][0] = nextplayer[0][0]
		player[0][1] = nextplayer[0][1]
		step += 1
	print(iteration, step, avgloss / step)
	f_step.write(str(step) + "\n")
	f_loss.write(str(avgloss/step) + "\n")

	if(iteration % 100 == 0) :
		f_a = open("a_" + str(iteration) + ".txt", "wt")
		for i in range(100) :
			for j in range(100):
				player[0][0] = -1.2 + i * 0.017
				player[0][1] = -0.07 + j * 0.0014
				res = sess.run(Q, {x : player})
				action = np.argmax(res[0])
				f_a.write(str(action) + " ")
			f_a.write("\n")
