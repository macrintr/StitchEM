import os
import csv
import math
from PIL import Image
import numpy as np

bucket = "/usr/people/tmacrina/seungmount/research/"
project_folder = bucket + "tommy/150502_piriform/"
input_folder = project_folder + "affine_block_matching/tiles/"
output_folder = input_folder + "plots/"
affine_folder = project_folder + "affine_transforms/"

all_files = os.listdir(input_folder)

def color_vector(d):
	dx = d[0]
	dy = d[1]
	r, g, b = 0, 0, 0
	a = math.sqrt(dx*dx + dy*dy)
	if a != 0.0:
		o = (math.atan2(dx/a, dy/a) + math.pi) / math.pi * 3
		if o < 3:
			r = min(1.0, max(0, 2.0 - o)) * a
		else:
			r = min(1.0, max(0, o - 4.0)) * a
		
		o += 2
		if o >= 6:
			o -= 6
		if o < 3:
			g = min(1.0, max(0, 2.0 - o)) * a
		else:
			g = min(1.0, max(0, o - 4.0)) * a

		o += 2
		if o >= 6:
			o -= 6
		if o < 3:
			b = min(1.0, max(0, 2.0 - o)) * a
		else:
			b = min(1.0, max(0, o - 4.0)) * a

	return int(r*255), int(g*255), int(b*255)

def collect_points_for_section(files):
	all_points = np.empty(shape=[0, 4])
	for n, filename in enumerate(files):
		# Grab points
		points = np.genfromtxt(filename, delimiter=",")
		# Grab affine transforms for tile A and tile B
		split_filename = filename.split(' ')
		aff_A_file = split_filename[0][:-4] + '.csv'
		split_B = split_filename[2].split('_')
		aff_B_file = '_'.join(split_B[1:])[:-4] + '.csv' 
		aff_A = np.genfromtxt(affine_folder + aff_A_file, delimiter=",")
		aff_B = np.genfromtxt(affine_folder + aff_B_file, delimiter=",")
		# Make points homogeneous and transform
		pts_A = np.ones((len(points), 3))
		pts_B = np.ones((len(points), 3))
		pts_A[:,:-1] = points[:,:2]
		pts_B[:,:-1] = points[:,4:6]
		pts_A_T = np.dot(pts_A, aff_A)
		pts_B_T = np.dot(pts_B, aff_B)
		# Collect points
		pts = np.hstack((pts_A_T[:,:-1], pts_B_T[:,:-1]))
		all_points = np.vstack((all_points, pts))
	return all_points

def write_image_from_points(points, filename):
	# x_nodes = np.unique(np.sort(points[:,0]))
	# y_nodes = np.unique(np.sort(points[:,1]))

	# x_delta = x_nodes[1:] - x_nodes[:-1]
	# y_delta = y_nodes[1:] - y_nodes[:-1]

	# x_dist = min(x_delta[x_delta > 1])
	# y_dist = min(y_delta[y_delta > 1])

	# x_idx = np.round((points[:,0] - x_nodes[0]) / x_dist).astype(int)
	# y_idx = np.round((points[:,1] - y_nodes[0]) / y_dist).astype(int)

	x_idx = np.round(points[:,0]).astype(int)
	y_idx = np.round(points[:,1]).astype(int)

	dx = points[:,0] - points[:,2]
	dy = points[:,1] - points[:,3]

	d = np.vstack((dx, dy))
	max_dist = np.max(np.linalg.norm(d))
	d /= max_dist

	colors = np.apply_along_axis(color_vector, 0, d)

	size = max(x_idx)+1, max(y_idx)+1
	im = Image.new("RGB", size, "white")
	pix = im.load()
	for (i,j, color) in zip(x_idx, y_idx, colors.T):
		pix[i, j] = tuple(color)
	# k = 1
	# im = im.resize((size[0]*k, size[1]*k))
	im.save(output_folder + filename + ".png")

def main():
	section_name = 'Tile_r4-c4_S2-Tile_r3-c3_S2-W007_sec47.tif z=1055.0 #20015_Tile_r4-c2_S2-W007_sec47.tif z=1055.0 #20008_pre_smooth_pts'
	files = [f for f in all_files if section_name in f]
	points = collect_points_for_section(files)
	write_image_from_points(points, section_name)