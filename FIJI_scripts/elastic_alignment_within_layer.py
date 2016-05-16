# Thomas Macrina

# Reimplementing the elastic montage aligner from TrakEM2
# Based on source code:
# https://github.com/trakem2/TrakEM2/blob/master/TrakEM2_/src/main/java/mpicbg/trakem2/align/ElasticMontage.java

import os
import re
import csv
import threading
import time

from ij import IJ
from ij.gui import GenericDialog
from ini.trakem2 import Project
from ini.trakem2.display import Layer
from ini.trakem2.display import LayerSet
from ini.trakem2.display import Patch
from ini.trakem2.display import VectorData
from ini.trakem2.utils import AreaUtils
from ini.trakem2.utils import Filter
from ini.trakem2.utils import Utils

from java.awt import Rectangle
from java.awt.geom import Area
from java.awt.geom import Path2D
from java.io import Serializable
from java.util import ArrayList
from java.util import Collection
from java.util import HashSet
from java.util import Iterator
from java.util import List
from java.util import Set

from mpicbg.imagefeatures import Feature
from mpicbg.imagefeatures import FloatArray2DSIFT
from mpicbg.models import AbstractModel
from mpicbg.models import AffineModel2D
from mpicbg.models import HomographyModel2D
from mpicbg.models import NotEnoughDataPointsException
from mpicbg.models import Point
from mpicbg.models import PointMatch
from mpicbg.models import RigidModel2D
from mpicbg.models import SimilarityModel2D
from mpicbg.models import Spring
from mpicbg.models import SpringMesh
from mpicbg.models import Tile
from mpicbg.models import TileConfiguration
from mpicbg.models import Transforms
from mpicbg.models import TranslationModel2D
from mpicbg.models import Vertex
from mpicbg.models import CoordinateTransform
from mpicbg.trakem2.transform import MovingLeastSquaresTransform2
from mpicbg.trakem2.util import Triple
from mpicbg.trakem2.align.Util import applyLayerTransformToPatch

from mpicbg.models import CoordinateTransformList
from mpicbg.trakem2.align import Util
from mpicbg.trakem2.align import ElasticMontage
from mpicbg.trakem2.align.Align import ParamOptimize
from mpicbg.trakem2.align import Align
from mpicbg.trakem2.align import RigidTile2D
from mpicbg.trakem2.align import AbstractAffineTile2D
from mpicbg.ij import TransformMapping

from java.util.concurrent import Callable
from java.util.concurrent import Executors, TimeUnit

SPRING_LENGTH = 100
spring_triangle_height_twice = 2 * Math.sqrt(0.75*SPRING_LENGTH*SPRING_LENGTH)
LAYER_SCALE = 1.0
STIFFNESS = 0.1
MAX_STRETCH = 2000.0
DAMP = 0.9
MAX_ITERATIONS = 5000 #1000
MAX_PLATEAU_WIDTH = 200
MAX_EPSILON = 6
MIN_NUM_MATCHES = 1 # minimum for TranslationModel2D()
MAX_NUM_THREADS = 40

# project = Project.getProject('stack_import.xml')
project = Project.getProject('montage_align.xml')

bucket = "/usr/people/tmacrina/seungmount/research/"
# project_folder = bucket + "tommy/150502_piriform/"
project_folder = bucket + "tommy/trakem_tests/150709_elastic_montage/"
input_folder = project_folder + "affine_block_matching/points/"
# input_folder = project_folder + "affine_block_matching/layers/"

all_files = os.listdir(input_folder)

def get_tiles(layer):
	po = ParamOptimize()
	po.maxEpsilon = 25.0
	po.minInlierRatio = 0.0
	po.minNumInliers = 12
	po.expectedModelIndex = 1
	po.desiredModelIndex = 1
	po.rejectIdentity = True
	po.identityTolerance = 5.0
	patches = layer.getDisplayables(Patch)
	tiles = []
	fixed_tiles = []
	fixed_patches = []
	Align.tilesFromPatches(po, patches, fixed_patches, tiles, fixed_tiles)
	return tiles

def modify_patch_str(patch_str):
	return str(patch_str).split(' z')[0][:-4]

def create_meshes(tiles):
	meshes = {}
	for tile in tiles:
		w = tile.getWidth()
		h = tile.getHeight()
		num_x = Math.max(2, int(Math.ceil(w / SPRING_LENGTH) + 1))
		num_y = Math.max(2, int(Math.ceil(h / spring_triangle_height_twice) + 1))
		w_mesh = (num_x - 1) * SPRING_LENGTH
		h_mesh = (num_y - 1) * spring_triangle_height_twice

		mesh = SpringMesh(num_x,
							num_y,
							w_mesh,
							h_mesh,
							STIFFNESS,
							MAX_STRETCH * LAYER_SCALE,
							DAMP)
		meshes[modify_patch_str(tile.getPatch())] = mesh
	return meshes

def parse_filename_into_tiles(filename):
	split_str = 'Tile'
	split_filename = filename.split(split_str)
	tileA = split_str + split_filename[2]
	tileA = modify_patch_str(tileA)
	tileB = split_str + split_filename[1][:-1]
	tileB = modify_patch_str(tileB)
	return tileA, tileB

def parse_section_name(patch_str):
	name = re.search(r'(W(\d*)_sec(\d*))', str(patch_str))
	return name.groups()[0]

layerset = project.getRootLayerSet()
layers = layerset.getLayers()
for layer in layers:
	tiles = get_tiles(layer)
	meshes = create_meshes(tiles)

	section_name = parse_section_name(str(tiles[0].getPatch()))

	files = [fn for fn in all_files if section_name in fn]
	for filename in files:
		tileA, tileB = parse_filename_into_tiles(filename)
		spring_constant = 1.0
		mesh = meshes[tileB]

		pts_list = ArrayList()

		pts_file = open(input_folder + filename)
		pts_reader = csv.reader(pts_file, delimiter=',', lineterminator='\n')
		for row in pts_reader:
			row = [float(i) for i in row]
			v1 = Vertex(row[:2], row[2:4]) # local coords, global coords
			v2 = Vertex(row[4:6], row[6:])
			v1.addSpring(v2, Spring(0, spring_constant))
			mesh.addPassiveVertex(v2)
			add_sucess = pts_list.add(PointMatch(v1, v2))
	 	pts_file.close()

	for mesh, tile in zip(meshes.values(), tiles):
		mesh.init(tile.getModel())
	try:
		t0 = System.currentTimeMillis()
		Utils.log( "Optimizing spring meshes..." )
		SpringMesh.optimizeMeshes2(meshes.values(),
									MAX_EPSILON * LAYER_SCALE,
									MAX_ITERATIONS,
									MAX_PLATEAU_WIDTH)
		Utils.log("Done optimizing spring meshes. Took " + 
						str(System.currentTimeMillis()-t0) + " ms")
	except:
		Utils.log("Not enough data points to optimize!")

	for mesh, tile in zip(meshes.values(), tiles):
		patch = tile.getPatch()
		matches = mesh.getVA().keySet()
		box = patch.getCoordinateTransformBoundingBox()
		for match in matches:
			p1 = match.getP1()
			l = p1.getL()
			l[0] += box.x
			l[1] += box.y
		mlt = MovingLeastSquaresTransform2()
		mlt.setModel(AffineModel2D)
		mlt.setAlpha(2.0)
		mlt.setMatches(matches)

		patch.appendCoordinateTransform(mlt)
		box = patch.getCoordinateTransformBoundingBox()
		patch.getAffineTransform().setToTranslation(box.x, box.y)
		patch.updateInDatabase('transform')
		patch.updateBucket()
		patch.updateMipMaps()
	Utils.log('Done.')