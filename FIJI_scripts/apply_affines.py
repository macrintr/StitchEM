# Thomas Macrina

# Adapted from: 
# http://fiji.sc/TrakEM2_Scripting#Import_images.2C_montage_them.2C_blend_them_and_save_as_.xml

import os
import re
import math
import csv
from java.awt.geom import AffineTransform

# Wafer
wafers = [u'S2-W001', u'S2-W002', u'S2-W003', u'S2-W004', u'S2-W005', u'S2-W006']
bucket = '/mnt/bucket/labs/seung/research/'
# project_folder = bucket + 'tommy/150528_zfish/'
project_folder = bucket + 'tommy/150502_piriform/'
tform_folder = project_folder + 'affine_transforms/'

# Get the first open project
project = Project.getProject('stack_import.xml')
# project = Project.getProject('S2-W001_XML_short_test.xml')

# Get layerset
layerset = project.getRootLayerSet()

# Cycle through all layers
for layer in layerset.getLayers():
	# Cycle through all images in that layer
	for patch in layer.getDisplayables(Patch):
		# Find corresponding transform file
		# Tile images are named like this:
		# 	Tile_r4-c4_S2-W002_sec1.tif
		# So the associated transform csv is this:
		# 	Tile_r4-c4_S2-W002_sec1.csv
		# Might be better to use patch.getImageFilePath()
		patch_title = patch.getTitle()[:-4]  # knock off the .tif
		title_split = patch_title.split('_')
		if title_split[-1][0] != 's':
			patch_title = '_'.join(title_split[:-1])
		tform_fn = tform_folder + patch_title + '.csv'
		# print title_split[-2]

		# Build affine transform
		# Java defines its affine as follows:
		# [ x']   [  m00  m01  m02  ] [ x ]   [ m00x + m01y + m02 ]
		# [ y'] = [  m10  m11  m12  ] [ y ] = [ m10x + m11y + m12 ]
		# [ 1 ]   [   0    0    1   ] [ 1 ]   [         1         ]
		# Java function:
		# AffineTransform(double m00, double m10, double m01, double m11, double m02, double m12)
		#
		# We spit out the transpose of that matrix from MATLAB as csv
		# The Java function inputs are ordered as the rows of the transpose
		if title_split[-2] in wafers:
			affine_inputs = []
			tform_csv = open(tform_fn)
			tform_matrix = csv.reader(tform_csv)
			for row in tform_matrix:
			 	affine_inputs.extend(map(float, row)[:2]) # extend not append
		 	tform_csv.close()

			affine_tform = AffineTransform(*affine_inputs) # expands the elements of the list

			print patch_title
			# Apply transform
			patch.setAffineTransform(affine_tform)
			print patch.getAffineTransform()
			# Update internal the internals
			patch.updateBucket()

Display.repaint()
# Display.getFront().getProject().save()
