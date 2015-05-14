import numpy as np
import matplotlib.pyplot as plt

def pull_out_row(arr, idx):
	row = arr[idx]
	arr = np.delete(arr, idx, axis=0)
	return row, arr

def make_affine_point(pt):
	return np.concatenate((pt, [1]), axis=0)

# From block_matching_loop
# How I wrote out the points files:
# x1 = match.getP1().getL()[0]
# y1 = match.getP1().getL()[1]
# x2 = match.getP2().getW()[0]
# y2 = match.getP2().getW()[1]

def calculate_weights(points, row, sigma):
	# points: Nx2 matrix with points as rows
	# row: 1x2 array
	# sigma: standard deviation of the radial gaussian function
	candidate = np.repeat([row], points.shape[0], axis=0)
	norm2 = np.linalg.norm(points - candidate, axis=1)
	return np.exp(np.multiply(norm2, norm2) / (-2*sigma*sigma))

def create_weighted_centroids(matches, weights):
	# matches: Nx4 matrix ((x1, y2), (x2, y2))
	# weights: Nx1 vector of weights
	weighted_matches = np.multiply(matches, weights.reshape((-1,1)))
	cumulative_matches = sum(weighted_matches)
	return cumulative_matches / sum(weights)

def create_weighted_rigid_tform(matches, weights):
	# matches: Nx4 matrix ((x1, y2), (x2, y2))
	# weights: Nx1 vector of weights	
	wt_centroids = create_weighted_centroids(matches, weights)
	pcx = wt_centroids[0]
	pcy = wt_centroids[1]
	qcx = wt_centroids[2]
	qcy = wt_centroids[3]
	dx = pcx - qcx
	dy = pcy - qcy
	x1 = matches[:, 0] - pcx
	y1 = matches[:, 1] - pcy
	x2 = matches[:, 2] - qcx + dx
	y2 = matches[:, 3] - qcy + dy
	x1y2 = np.multiply(x1, y2)
	y1x2 = np.multiply(y1, x2)
	sind = sum(np.multiply(x1y2 - y1x2, weights))
	cosd = sum(np.multiply(x1y2 + y1x2, weights))
	norm = np.linalg.norm([cosd, sind])
	cosd /= norm
	sind /= norm
	tx = qcx - cosd*pcx + sind*pcy
	ty = qcy - sind*pcx - cosd*pcy
	return np.array([[cosd, sind, 0],
					 [-sind, cosd, 0],
					 [tx, ty, 1]])

def test():
	a = np.arange(9).reshape((3,3))
	r, b = pull_out_row(a, 0)
	assert (r == a[0]).all()
	assert (b == a[1:]).all()

	a = np.array([1, 1])
	b = np.array([[4, 5]])
	s = 1
	c = calculate_weights(b, a, s)
	assert c == np.exp(25.0 / -2)
	
	m = np.repeat([[1, 2, 1, 2]], 3, axis=0)
	w = np.array([0.1, 0.1, 0.1])
	wc = create_weighted_centroids(m, w)
	assert (wc == np.array([1, 2, 1, 2])).all()

	m = np.array([[1, 0, 2, 0],
				  [3, 2, 6, 2],
				  [0, 1, 0, 1]])
	w = np.array([1., 1., 1.])
	tform = create_weighted_rigid_tform(m, w)
	ans = np.array([[2, 0, 0], [0, 1, 0], [0, 0, 1]])
	# assert (tform == ans).all()


filename = "/mnt/data0/tommy/affine_block_matching/S2-W001/003____z2.0_002____z1.0_post_smooth_pts.txt"
# filename = "/usr/people/tmacrina/Desktop/102____z101.0_101____z100.0_pre_smooth_pts.txt"p
ts = np.genfromtxt(filename, delimiter='\t')
idx = 0
row, matches = pull_out_row(pts, idx)
weights = calculate_weights(matches[:,:2], row[:2], sigma=906)
tform = create_weighted_rigid_tform(matches, weights)

p1 = make_affine_point(row[:2])
p2 = make_affine_point(row[2:])
p1_tformed = np.dot(p1, tform)
norm2 = np.linalg.norm(p1_tformed - p2)

