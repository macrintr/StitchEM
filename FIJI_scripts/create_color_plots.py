# Thomas Macrina
# 150710
# Python implementation to take correspondences and produce color plots

import os
import csv
import math
from PIL import Image, ImageDraw
import numpy as np

bucket = "/usr/people/tmacrina/seungmount/research/"
# project_folder = bucket + "tommy/150502_piriform/"
project_folder = bucket + "tommy/trakem_tests/150709_elastic_montage/"
input_folder = project_folder + "affine_block_matching/points/"
# input_folder = project_folder + "affine_block_matching/layers/"
output_folder = project_folder + "affine_block_matching/plots/"
affine_folder = project_folder + "affine_transforms/"

all_files = os.listdir(input_folder)

# Pulled from Variable Scope
# http://variable-scope.com/posts/hexagon-tilings-with-python
class HexagonGenerator(object):
	"""Returns a hexagon generator for hexagons of the specified size."""
	def __init__(self, edge_length):
		self.short_radius = edge_length * math.sqrt(3) / 2
		self.edge_length = edge_length

	@property
	def col_width(self):
		return self.short_radius

	@property
	def row_height(self):
		return self.edge_length * 3.0 / 2

	def __call__(self, row, col):
		x = col * self.col_width
		y = row * self.row_height
		for angle in range(0, 360, 60):
			x += math.sin(math.radians(angle)) * self.edge_length
			y += math.cos(math.radians(angle)) * self.edge_length
			yield x
			yield y

# Adapted from mpicbg.ij.util.Util.java
# https://github.com/axtimwalde/mpicbg/blob/master/mpicbg/src/main/java/mpicbg/ij/util/Util.java
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

def filter_row_and_col_from_tile_name(tile_name):
	# tile_name format: (####)_Tile_r{row}-c{col}_S2-W00X_secZ.tif
	tile_split = tile_name.split('_')
	tile_location = next(i for i in tile_split if 'r' in i).split('-')
	row = int(tile_location[0][1:]) - 1
	col = int(tile_location[1][1:]) - 1
	return row, col

def create_translation_matrix(dx, dy):
	aff = np.identity(3)
	aff[2,0] = dx
	aff[2,1] = dy
	return aff

def create_affines_from_filename(filename, size):
	split_filename = filename.split(' ')
	row_A, col_A = filter_row_and_col_from_tile_name(split_filename[2])
	row_B, col_B = filter_row_and_col_from_tile_name(split_filename[0])
	aff_A = create_translation_matrix(col_A * size[1], row_A * size[0])
	aff_B = create_translation_matrix(col_B * size[1], row_B * size[0])
	return aff_A, aff_B

def load_affines_from_file(filename):
	split_filename = filename.split(' ')
	aff_A_file = split_filename[0][:-4] + '.csv'
	split_B = split_filename[2].split('_')
	aff_B_file = '_'.join(split_B[1:])[:-4] + '.csv' 
	aff_A = np.genfromtxt(affine_folder + aff_A_file, delimiter=",")
	aff_B = np.genfromtxt(affine_folder + aff_B_file, delimiter=",")
	return aff_A, aff_B

def collect_layer_points_for_section(filename):
	fn = input_folder + filename
	# Grab points
	points = np.genfromtxt(fn, delimiter="\t")
	points = np.atleast_2d(points)
	# Collect points
	return np.hstack((points[:,:2], points[:,2:]))

def collect_montage_points_for_section(files, original_image_size=(8000,8000)):
	all_points = np.empty(shape=[0, 4])
	for n, filename in enumerate(files):
		try:
			fn = input_folder + filename
			# Grab points
			points = np.genfromtxt(fn, delimiter=",")
			points = np.atleast_2d(points)
			# Grab affine transforms for tile A and tile B
			aff_A, aff_B = create_affines_from_filename(filename, original_image_size)
			# Make points homogeneous
			pts_A = np.ones((len(points), 3))
			pts_B = np.ones((len(points), 3))
			pts_A[:,:-1] = points[:,:2]
			pts_B[:,:-1] = points[:,6:8]
			# Transform points
			pts_A_T = np.dot(pts_A, aff_A)
			pts_B_T = np.dot(pts_B, aff_B)
			# Collect points
			pts = np.hstack((pts_A_T[:,:-1], pts_B_T[:,:-1]))
			all_points = np.vstack((all_points, pts))
		except e:
			print "Failed point collection: " + filename
			print e
	return all_points

def write_image_from_points(points, point_distance, original_image_size, filename):
	x_dist = point_distance / 2.0
	y_dist = point_distance * math.sqrt(3) / 2

	# This will cause breaks where rounding doesn't perfectly match integers
	# Could try snapping points to predetermined grid
	# Good enough for now, though
	x_idx = np.round(points[:,0]/x_dist).astype(int)
	y_idx = np.round(points[:,1]/y_dist).astype(int)

	dx = points[:,0] - points[:,2]
	dy = points[:,1] - points[:,3]

	d = np.vstack((dx, dy))
	max_dist = np.max(np.linalg.norm(d, axis=0))
	d /= max_dist

	colors = np.apply_along_axis(color_vector, 0, d)

	hex_edge = 10
	hexagon_generator = HexagonGenerator(hex_edge)
	width = int((original_image_size[0] / x_dist + 1.5) * hexagon_generator.col_width)
	height = int((original_image_size[1] / y_dist + 1.5) * hexagon_generator.row_height)
	size = width, height
	im = Image.new("RGB", size, "white")
	draw = ImageDraw.Draw(im)
	for (i, j, color) in zip(x_idx, y_idx, colors.T):
		hexagon = hexagon_generator(j, i)
		# draw_color = tuple(color) + (100,)
		draw.polygon(list(hexagon), outline=tuple(color), fill=tuple(color))
	im.save(output_folder + filename + ".png")

def demo_layer_points():
	filename = '1354____z1354.0_1353____z1353.0_post_smooth_pts.txt'
	point_distance = 180
	original_image_size = 180*40, 180*40
	points = collect_layer_points_for_section(filename)
	write_image_from_points(points, point_distance, original_image_size, filename[:-4])

def demo_montage_points():
	section_name = 'S2-W001_sec25'
	point_distance = 100
	original_image_size = 8000, 8000
	original_section_size = 32000, 32000
	files = [f for f in all_files if section_name in f]
	points = collect_montage_points_for_section(files, original_image_size)
	write_image_from_points(points, point_distance, original_section_size, section_name)

def main():
	point_distance = 100
	original_image_size = 8000, 8000
	original_section_size = 32000, 32000
	for i in range(1, 2):
		for j in range(19,21):
			section_name = 'S2-W00' + str(i) + '_sec' + str(j) + '.'
			files = [f for f in all_files if section_name in f]
			if files:
				try:
					points = collect_montage_points_for_section(files, original_image_size)
					write_image_from_points(points, point_distance, original_section_size, section_name[:-1])
					print 'Wrote ' + section_name
				except:
					print 'No points: ' + section_name
