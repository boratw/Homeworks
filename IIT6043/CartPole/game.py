import numpy as np
import cv2

# Constants
timeconst = 0.025 # time difference of each frame
FMax = 20. # Maximum force Agent can apply
sigma_noise = 1. # Stddev of Random noise
mu_c = 0.01 # Friction Factor
mu_p = 0.01 # Friction Factor
G = 9.8 # Gravity
M = 1 # Mass of Cart
m = 0.1 # Mass of Pole
L = 1 # Length of Pole

# Initial Values
x = 0.
v = 0.
theta = 0.
w = 0.
F = 0.

image = np.zeros((240, 320, 3), dtype = np.float)

while True:
	# Apply Phisical Model
	sintheta = np.sin(theta)
	costheta = np.cos(theta)
	sgn_mu_c = mu_c if v > 0. else -mu_c if v < 0. else 0.
	F += np.random.normal(0., 0.02 * timeconst)
	
	dw = G * sintheta + \
		((sgn_mu_c - F - m * L * w * w * sintheta) * costheta) / (M + m) - \
		(mu_p * w) / (m * L)
	dw /= L * (1.333333 - m / (m + M) * costheta * costheta)
	dv = (F + m * L * (w * w * sintheta - dw * costheta) - sgn_mu_c) / (m + M)
	
	# Update Values
	w += dw * timeconst
	v += dv * timeconst
	
	theta += w * timeconst
	x += v * timeconst
	
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
	key = cv2.waitKey(30);
	
	# Human Input
	if key == ord('z') :
		F = -FMax
	elif key == ord('x') :
		F = FMax
	elif key == ord('q') :
		break
	else:
		F = 0.