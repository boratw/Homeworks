import numpy as np
import cv2
import tensorflow as tf



#Constants
timeconst = 0.025 # time difference of each frame
FMax = 20. # Maximum force Agent can apply
sigma_noise = 1. # Stddev of Random noise
mu_c = 0.01 # Friction Factor
mu_p = 0.01 # Friction Factor
G = 9.8 # Gravity
M = 1 # Mass of Cart
m = 0.1 # Mass of Pole
L = 1 # Length of Pole
TD_GAMMA = 0.9


# Set Network

# Actor Network ( One Hidden layer with 32 elements )
global_step = tf.Variable(0, trainable=False)
with tf.variable_scope('Actor'):
	actor_x = tf.placeholder(tf.float32, [None, 4])
	actor_action = tf.placeholder(tf.int32, [None])
	actor_td_error = tf.placeholder(tf.float32, [None])
	
	actor_w1 = tf.Variable(tf.random_normal([4, 32], stddev=0.1))
	actor_b1 = tf.Variable(tf.random_normal([32], stddev=0.1))
	actor_f1 = tf.nn.relu(tf.matmul(actor_x, actor_w1) + actor_b1)
	
	
	actor_w2 = tf.Variable(tf.random_normal([32, 5], stddev=0.1))
	actor_b2 = tf.Variable(tf.random_normal([5], stddev=0.1))
	actor_y = tf.matmul(actor_f1, actor_w2) + actor_b2
	actor_act = tf.nn.softmax(actor_y)
	
	actor_action_hot = tf.one_hot(actor_action, 5)
	actor_log_prob = tf.log(tf.reduce_sum(actor_act * actor_action_hot) + 1e-15)
	actor_loss = -actor_log_prob * actor_td_error
	
	actor_train = tf.train.AdamOptimizer(tf.train.exponential_decay(0.001, global_step, 1000, 0.1))\
		.minimize(actor_loss)
	
# Critic Network ( One Hidden layer with 32 elements )
with tf.variable_scope('Critic'):
	critic_x = tf.placeholder(tf.float32, [None, 4])
	critic_v_next = tf.placeholder(tf.float32, [None, 1])
	critic_r = tf.placeholder(tf.float32, [None, 1])
	
	critic_w1 = tf.Variable(tf.random_normal([4, 32], stddev=0.1))
	critic_b1 = tf.Variable(tf.random_normal([32], stddev=0.1))
	critic_f1 = tf.nn.relu(tf.matmul(critic_x, critic_w1) + critic_b1)
	
	critic_w2 = tf.Variable(tf.random_normal([32, 1], stddev=0.1))
	critic_v = tf.matmul(critic_f1, critic_w2)
	
	critic_error = tf.reduce_mean(  critic_r + critic_v_next * TD_GAMMA - critic_v )
	critic_train = tf.train.AdamOptimizer(tf.train.exponential_decay(0.01, global_step, 1000, 0.1))\
		.minimize(tf.square(critic_error) )

sess = tf.Session()
init = tf.global_variables_initializer()
sess.run(init)
saver = tf.train.Saver(max_to_keep = 0)
#saver.restore(sess, ".\\model2-700")


f_w = open('out_3.txt', 'at')
image = np.zeros((240, 320, 3), dtype = np.float)
	
for iteration in range(1, 3001) :
	# Env Reset
	x = 0.
	v = 0.
	theta = np.random.normal(0., 0.2) # Randomize Initial theta
	w = np.random.normal(0., 1.) # Randomize Initial w
	
	td_error_sum = 0.
	actor_loss_sum = 0.
	reward_sum = 0.
	for step in range(1000) :
		# Get Action
		act_prob = sess.run(actor_act, {actor_x : np.array([[x, v, theta, w]])})
		#act_prob_added = [t + 0.05 for t in act_prob[0]]
		#act_prob_added /= np.sum(act_prob_added)
		action = np.random.choice(5, p=act_prob[0])
		F = (action - 2) * 0.5 * FMax + np.random.normal(0., sigma_noise)
		
		# Physics
		sintheta = np.sin(theta)
		costheta = np.cos(theta)
		sgn_mu_c = mu_c if v > 0. else -mu_c if v < 0. else 0.
		
		dw = G * sintheta + \
			((sgn_mu_c - F - m * L * w * w * sintheta) * costheta) / (M + m) - \
			(mu_p * w) / (m * L)
		dw /= L * (1.333333 - m / (m + M) * costheta * costheta)
		dv = (F + m * L * (w * w * sintheta - dw * costheta) - sgn_mu_c) / (m + M)
		
		next_x = x + v * timeconst
		next_v = v + dv * timeconst
		next_theta = theta + w * timeconst
		next_w = w + dw * timeconst
		
		# Learn Critic
		reward = np.cos(next_theta) ** 3
		if reward > 0. or next_x < -10. or next_x > 10.:
			next_value = sess.run(critic_v, {critic_x : np.array([[next_x, next_v, next_theta, next_w]])})
			[_, td_error] = sess.run([critic_train, critic_error], \
				{global_step : iteration, critic_x : np.array([[x, v, theta, w]]), \
				critic_v_next : next_value, critic_r : np.array([[reward]])})
		else :
			[_, td_error] = sess.run([critic_train, critic_error], \
				{global_step : iteration, critic_x : np.array([[x, v, theta, w]]), \
				critic_v_next : np.array([[0.]]), critic_r : np.array([[reward]])})
			
		# Learn Actor
		[_, loss] = sess.run([actor_train, actor_loss], \
			{global_step : iteration, actor_x : np.array([[x, v, theta, w]]), \
			actor_action : np.array([action]), actor_td_error : np.array([td_error])})
		
		td_error_sum += td_error ** 2
		actor_loss_sum += np.abs(loss[0])
		reward_sum += reward
		
		x = next_x
		v = next_v
		theta = next_theta
		w = next_w
		'''
		# Drawing
		cv2.rectangle(image, (0, 0), (320, 240), (1., 1., 1.), -1)
		
		cv2.line(image, (0, 120), (320, 120), (0., 1., 0.), 2)
		t = int(((x / 1.) - np.floor(x / 1.)) * 40.)
		while t < 320 :
			cv2.line(image, (t, 115), (t, 125), (0., 1., 0.), 2)
			t += 40
		
		cv2.rectangle(image, (140, 110), (180, 130), (1., 0., 0.), -1)
		cx = int(160 + sintheta * 60);
		cy = int(120 + costheta * -60);
		cv2.line(image, (160, 120), (cx, cy), (0., 0., 0.), 5)
		cv2.circle(image, (cx, cy), 10, (0., 0., 1.), -1)
		
		cv2.imshow("game", image);
		cv2.waitKey(100);
		'''
		
		if reward <= 0. :
			break
	
	print(step, reward_sum / step, actor_loss_sum / step, td_error_sum / step)
	f_w.write(str(step) + "\t" + str(reward_sum / step) + "\t" + \
		str(actor_loss_sum / step) + "\t" + str(td_error_sum / step) + "\n")
	
	if iteration % 100 == 0:
		saver.save(sess, ".\\model3", global_step=iteration)