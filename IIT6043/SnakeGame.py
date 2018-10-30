import socket
import tensorflow as tf
import numpy as np
import math
import random
from time import sleep

TCP_IP = "127.0.0.1"
TCP_PORT = 4321

Message_RequestScreen = bytearray({0});
Message_Action = [bytearray({1}), bytearray({2}), bytearray({3}), bytearray({4})]


client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((TCP_IP, TCP_PORT))

def readfile(path):
	f = open(path, 'rb')
	moved = 20
	lasteat = 0
	record = []
	map = []
	line = f.read(770)
	for i in range(768) :
		map.append(float(line[i]) / 256.)
	while(True) :
		action = [0., 0., 0., 0.]
		action[line[768]-1] = 1.
		result = line[769]
		line = f.read(770)
		if(len(line) == 770) :
			newmap = []
			for i in range(768) :
				newmap.append(float(line[i]) / 256.)
			record.append([map, action, 0, newmap])
			map = newmap
		else :
			record.append([map, action, -10, map])
			break
		if(result == 1) :
			moved += 1
		elif(result == 3) :
			for x in record[lasteat:] :
				x[2] = 200 / moved
				moved -= 1
			moved = 20
			lasteat = len(record)
	f.close()
	return record

def conv2d(x, W, b, strides=1):
	x = tf.nn.conv2d(x, W, strides=[1, strides, strides, 1], padding='SAME')
	x = tf.nn.bias_add(x, b)
	return tf.nn.relu(x)

def fully_connected(x, W, b):
	x = tf.matmul(x, W)
	return tf.nn.bias_add(x, b)

def maxpool2d (x, k):
	return tf.nn.max_pool(x, ksize=[1, k, k, 1], strides=[1, k, k, 1], padding='SAME')
	
def buildNetwork(scope_name) :
	with tf.variable_scope(scope_name) :
		x = tf.placeholder(tf.float32, [None, 768])

		reshaped = tf.reshape(x, shape=[-1, 16, 16, 3])
		wc1 = tf.Variable(tf.random_normal([5, 5, 3, 24], stddev=0.1))
		bc1 = tf.Variable(tf.constant(0.1, shape=[24]))
		conv1 = conv2d(reshaped, wc1, bc1)
		pool1 = maxpool2d(conv1, 2)
		wc2 = tf.Variable(tf.random_normal([3, 3, 24, 36], stddev=0.1))
		bc2 = tf.Variable(tf.constant(0.1, shape=[36]))
		conv2 = conv2d(pool1, wc2, bc2)
		pool2 = maxpool2d(conv2, 2)
		wc3 = tf.Variable(tf.random_normal([3, 3, 36, 48], stddev=0.1))
		bc3 = tf.Variable(tf.constant(0.1, shape=[48]))
		conv3 = conv2d(pool2, wc3, bc3)

		flat1 = tf.reshape(conv3, [-1, 4*4*48])
		wf1 = tf.Variable(tf.random_normal([4*4*48, 128], stddev=0.1))
		bf1 = tf.Variable(tf.constant(0.1, shape=[128]))
		fc1 = fully_connected(flat1, wf1, bf1)
		wf2_V = tf.Variable(tf.random_normal([128, 32], stddev=0.1))
		bf2_V = tf.Variable(tf.constant(0.1, shape=[32]))
		wf2_A = tf.Variable(tf.random_normal([128, 32], stddev=0.1))
		bf2_A = tf.Variable(tf.constant(0.1, shape=[32]))
		fc2_V = fully_connected(fc1, wf2_V, bf2_V)
		fc2_A = fully_connected(fc1, wf2_A, bf2_A)
		wf3_V = tf.Variable(tf.random_normal([32, 1], stddev=0.1))
		bf3_V = tf.Variable(tf.constant(0.1, shape=[1]))
		wf3_A = tf.Variable(tf.random_normal([32, 4], stddev=0.1))
		bf3_A = tf.Variable(tf.constant(0.1, shape=[4]))
		fc3_V = fully_connected(fc2_V, wf3_V, bf3_V)
		fc3_A = fully_connected(fc2_A, wf3_A, bf3_A)

		

	return x, wc1, bc1, wc2, bc2, wc3, bc3, wf1, bf1, wf2_V, bf2_V, wf2_A, bf2_A, wf3_V, bf3_V, wf3_A, bf3_A, fc3_V, fc3_A

	
def predict(sess, image, n_epoch, lastaction) :
	action = [0., 0., 0., 0.]
	#if (random.random() < (1 / math.sqrt(n_epoch + 1))) :
	if (random.random() < 0.1) :
		arg = random.randrange(4)
		if (arg == 0 and lastaction == 1) :
			arg = 1
		elif (arg == 1 and lastaction == 0) :
			arg = 0
		elif (arg == 2 and lastaction == 3) :
			arg = 3
		elif (arg == 3 and lastaction == 2) :
			arg = 2
	else :
		Qvalue = sess.run(Qvalue_rA, {input_r : image})[0]
		arg = np.argmax(Qvalue)
	action[arg] = 1.
	return arg, action
	
def CopyNetwork(sess):
	copyTargetQnetworkOperation = [wc1_t.assign(wc1_r), bc1_r.assign(bc1_t), wc2_t.assign(wc2_r), bc2_r.assign(bc2_t), wc3_t.assign(wc3_r), bc3_r.assign(bc3_t), \
		wf1_t.assign(wf1_r), bf1_r.assign(bf1_t),
		wf2_tV.assign(wf2_rV), bf2_rV.assign(bf2_tV), wf2_tA.assign(wf2_rA), bf2_rA.assign(bf2_tA),
		wf3_tV.assign(wf3_rV), bf3_rV.assign(bf3_tV), wf3_tA.assign(wf3_rA), bf3_rA.assign(bf3_tA)]
	sess.run(copyTargetQnetworkOperation)

input_r, wc1_r, bc1_r, wc2_r, bc2_r, wc3_r, bc3_r, wf1_r, bf1_r, wf2_rV, bf2_rV, wf2_rA, bf2_rA, wf3_rV, bf3_rV, wf3_rA, bf3_rA, Qvalue_rV, Qvalue_rA = buildNetwork('train')
input_t, wc1_t, bc1_t, wc2_t, bc2_t, wc3_t, bc3_t, wf1_t, bf1_t, wf2_tV, bf2_tV, wf2_tA, bf2_tA, wf3_tV, bf3_tV, wf3_tA, bf3_tA, Qvalue_tV, Qvalue_tA = buildNetwork('target')


with tf.variable_scope('train') :
	actionInput = tf.placeholder(tf.float32, [None, 4])
	yInput = tf.placeholder(tf.float32, [None])
	Q_Action = Qvalue_rV + tf.reduce_sum(tf.multiply(Qvalue_rA, actionInput), reduction_indices = 1)
	cost = tf.reduce_mean(tf.square(yInput - Q_Action))
	global_step = tf.placeholder(tf.int64)
	learning_rate = tf.train.exponential_decay(0.001, global_step, 1000, 0.96) 
	train = tf.train.AdamOptimizer(learning_rate).minimize(cost)
	

sess = tf.Session()
init = tf.global_variables_initializer()
sess.run(init)
saver = tf.train.Saver()
saver.restore(sess, ".\\tmp\\model10.ckpt")

record = []
record.extend(readfile('Training\\output_1.txt'))
record.extend(readfile('Training\\output_2.txt'))
record.extend(readfile('Training\\output_3.txt'))
record.extend(readfile('Training\\output_4.txt'))
record.extend(readfile('Training\\output_5.txt'))
record.extend(readfile('Training\\output_6.txt'))
record.extend(readfile('Training\\output_7.txt'))
record.extend(readfile('Training\\output_8.txt'))
record.extend(readfile('Training\\output_9.txt'))
record.extend(readfile('Training\\output_10.txt'))
record.extend(readfile('Training\\output_11.txt'))
record.extend(readfile('Training\\output_12.txt'))
record.extend(readfile('Training\\output_13.txt'))
record.extend(readfile('Training\\output_14.txt'))
record.extend(readfile('Training\\output_15.txt'))
record.extend(readfile('Training\\output_16.txt'))
record.extend(readfile('Training\\output_17.txt'))
record.extend(readfile('Training\\output_18.txt'))
record.extend(readfile('Training\\output_19.txt'))
record.extend(readfile('Training\\output_20.txt'))
record.extend(readfile('Training\\output_21.txt'))
record.extend(readfile('Training\\output_22.txt'))
record.extend(readfile('Training\\output_23.txt'))
record.extend(readfile('Training\\output_24.txt'))
record.extend(readfile('Training\\output_25.txt'))
record.extend(readfile('Training\\output_26.txt'))
record.extend(readfile('Training\\output_27.txt'))
record.extend(readfile('Training\\output_28.txt'))
record.extend(readfile('Training\\output_29.txt'))
record.extend(readfile('Training\\output_30.txt'))

for n_epoch in range(100) :
	lastaction = 3
	rawbyte = []
	while(len(rawbyte) != 768):
		client.send(Message_RequestScreen)
		rawbyte = client.recv(1024)
	image = [[float(x) / 256. for x in rawbyte]]
	while(True):
		sleep(0.2)
		arg, action = predict(sess, image, n_epoch, lastaction)
		lastaction = action
		lastaction = action
		client.send(Message_Action[arg])
		stopped = client.recv(1024)
		if(stopped[0] == 2) :
			break
		else :
			rawbyte = []
			while(len(rawbyte) != 768):
				client.send(Message_RequestScreen)
				rawbyte = client.recv(1024)
			newimage = [[float(x) / 256. for x in rawbyte]]
			image = newimage
'''
file_length = open('Result\\length10.txt', 'a')
file_cost = open('Result\\cost10.txt', 'a')
file_time = open('Result\\time10.txt', 'a')
CopyNetwork(sess)

replayMemory = []

for n_epoch in range(72001, 75001) :
	played = 0
	consumed = 0
	increasedlen = 0
	if(len(replayMemory) > 448) :
		replayMemory = replayMemory[-448:]
	while(len(replayMemory) < 512) :
		played += 1
		reward = 20
		lastaction = 3
		replaystart = len(replayMemory)
		rawbyte = []
		while(len(rawbyte) != 768):
			client.send(Message_RequestScreen)
			rawbyte = client.recv(1024)
		image = [[float(x) / 256. for x in rawbyte]]
		while(True):
			arg, action = predict(sess, image, n_epoch, lastaction)
			increasedlen += 1
			lastaction = action
			client.send(Message_Action[arg])
			stopped = client.recv(1024)
			if(stopped[0] == 2) :
				replayMemory.append([image[0], action, -10, image[0]])
				break
			else :
				rawbyte = []
				while(len(rawbyte) != 768):
					client.send(Message_RequestScreen)
					rawbyte = client.recv(1024)
				newimage = [[float(x) / 256. for x in rawbyte]]
				replayMemory.append([image[0], action, 0, newimage[0]])
				image = newimage
				if(stopped[0] == 3) :
					for x in replayMemory[replaystart:] :
						x[2] = 200 / reward
						reward -= 1
					replaystart = len(replayMemory)
					reward = 20
					consumed += 1
				else :
					reward += 1
	file_time.write(str(increasedlen / played) + '\n')
	file_length.write(str(consumed / played) + '\n')
	minibatch = random.sample(replayMemory, 64)
	state_batch = [x[0] for x in minibatch]
	action_batch = [x[1] for x in minibatch]
	reward_batch = [x[2] for x in minibatch]
	next_batch = [x[3] for x in minibatch]
	y_batch = []
	VQ, AQ = sess.run((Qvalue_tV, Qvalue_tA), {input_t : next_batch})
	costr = 0
	for i in range(64) :
		if(reward_batch[i] <= 0) :
			y_batch.append(reward_batch[i])
		else :
			y_batch.append(reward_batch[i] + 0.9 * (VQ[i][0] + np.max(AQ[i])))
	_, costt = sess.run((train, cost), {input_r : state_batch, actionInput : action_batch, yInput : y_batch, global_step : n_epoch})
	costr += costt
	minibatch = random.sample(record, 16)
	state_batch = [x[0] for x in minibatch]
	action_batch = [x[1] for x in minibatch]
	reward_batch = [x[2] for x in minibatch]
	next_batch = [x[3] for x in minibatch]
	y_batch = []
	VQ, AQ = sess.run((Qvalue_tV, Qvalue_tA), {input_t : next_batch})
	for i in range(16) :
		if(reward_batch[i] <= 0) :
			y_batch.append(reward_batch[i])
		else :
			y_batch.append(reward_batch[i] + 0.9 * (VQ[i][0] + np.max(AQ[i])))
	_, costt = sess.run((train, cost), {input_r : state_batch, actionInput : action_batch, yInput : y_batch, global_step : n_epoch})
	costr += costt
	file_cost.write(str(costr / 6.) + '\n')
	
	print(str(n_epoch) + " epoch completed")
	
	if (n_epoch % 500 == 0) :
		CopyNetwork(sess)
		saver.save(sess, "tmp\\model10.ckpt")


file_length.close()
file_cost.close()
file_time.close()
'''