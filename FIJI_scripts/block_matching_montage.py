# Thomas Macrina
# 150710
# Jython conversion of ElasticMontage

import os
from ij import IJ
from ij import ImagePlus
from ij import WindowManager
from ij.io import FileSaver 
from ij.gui import GenericDialog
from ij.gui import PointRoi
from ij.process import ColorProcessor
from ij.process import FloatProcessor

from java.util import ArrayList
from java.util import Set

from mpicbg.ij.blockmatching import BlockMatching
from mpicbg.models import PointMatch
from mpicbg.ij.util.Util import pointsToPointRoi
from mpicbg.ij.util.Util import colorVector
from mpicbg.models import ErrorStatistic
from mpicbg.models import SpringMesh
from mpicbg.models import TranslationModel2D
from mpicbg.models import SimilarityModel2D
from mpicbg.models import CoordinateTransformList
from mpicbg.trakem2.align import Util
from mpicbg.trakem2.align import ElasticMontage
from mpicbg.trakem2.align.Align import ParamOptimize
from mpicbg.trakem2.align import Align
from mpicbg.trakem2.align import RigidTile2D
from mpicbg.trakem2.align import AbstractAffineTile2D
from mpicbg.ij import TransformMapping

from net.imglib2 import RealPoint
from net.imglib2.collection import KDTree
from net.imglib2.collection import RealPointSampleList
from net.imglib2.exception import ImgLibException
from net.imglib2.img.imageplus import ImagePlusImg
from net.imglib2.img.imageplus import ImagePlusImgFactory
from net.imglib2.neighborsearch import NearestNeighborSearchOnKDTree
from net.imglib2.type.numeric import ARGBType
from script.imglib import ImgLib

from mpicbg.util import Timer

import threading
import time
from java.util.concurrent import Callable
from java.util.concurrent import Executors, TimeUnit

from script.imglib.algorithm import Scale2D

class BlockMatcherParameters():
	def __init__(self,
			export_point_roi = False,
			export_displacement_vectors = False,
			scale = 1.00,
			search_radius = 35,
			block_radius = 35,
			min_R = 0.4,
			max_curvature_R = 10,
			rod_R = 1.0,
			use_local_smoothness_filter = False,
			local_model_index = 3,
			local_region_sigma = 240,
			max_local_epsilon = 6,
			max_local_trust = 999999,
			point_distance = 100,
			save_data = True):
		# bucket = "/usr/people/tmacrina/seungmount/research/"
		bucket = "/mnt/bucket/labs/seung/research/"
		project_folder = bucket + "tommy/150502_piriform/"
		# project_folder = bucket + "tommy/trakem_tests/150709_rough_xy_montage/"
		# self.input_folder = project_folder + "affine_renders_0175x/"
		# self.output_folder = project_folder + "affine_block_matching/all_points/"
		self.output_folder = project_folder + "affine_block_matching/tiles/"

		self.export_point_roi = export_point_roi
		self.export_displacement_vectors = export_displacement_vectors

		self.scale = scale
		self.search_radius = search_radius
		self.block_radius = block_radius
		self.min_R = min_R
		self.max_curvature_R = max_curvature_R
		self.rod_R = rod_R
		self.use_local_smoothness_filter = use_local_smoothness_filter
		self.local_model_index = local_model_index # 0: Translation, 1: Rigid, 2: Similarity, 3: Affine
		self.local_region_sigma = local_region_sigma
		self.max_local_epsilon = max_local_epsilon
		self.max_local_trust = max_local_trust
		self.point_distance = point_distance

		self.save_data = save_data

class BlockMatcher():
	def __init__(self, tileA, tileB, params, wf=None):
		self.tileA = tileA
		self.tileB = tileB
		self.params = params
		self.wf = wf
		self.patchA = self.tileA.getPatch()
		self.patchB = self.tileB.getPatch()

		self.started = None
		self.completed = None
		self.thread_used = None
		self.exception = None

	# With help from
	# http://albert.rierol.net/imagej_programming_tutorials.html#ImageJ%20programming%20basics
	def scaleIntImagePlus(self, intImgPlus, scale):
		imgPlus = intImgPlus.getImagePlus()
		ip = imgPlus.getProcessor()
		new_width = int(ip.getWidth()*scale)
		new_height = int(ip.getHeight()*scale)
		ip2 = ip.resize(new_width, new_height)
		imgPlus.setProcessor(imgPlus.getTitle(), ip2)
		return imgPlus

	# Adapted from AbstractBlockMatching.java
	# http://fiji.sc/git/?p=fiji.git;a=blob;f=src-plugins/blockmatching_/mpicbg/ij/plugin/AbstractBlockMatching.java;h=9dfebf1d807544173c763051ba45f6a65fccafad;hb=1861dafff1162f64051393a7e5ef71f0426f5bf6
	def createMask(self, source):
		mask = FloatProcessor(source.getWidth(), source.getHeight())
		maskColor = 0x0000ff00
		sourcePixels = source.getPixels()
		n = len(sourcePixels)
		maskPixels = mask.getPixels()
		for i in xrange(n):
			sourcePixel = sourcePixels[i] & 0x00ffffff
			if sourcePixel == maskColor:
				maskPixels[i] = 0
			else:
				maskPixels[i] = 1
		mask.setPixels(maskPixels)
		return mask

	# Adapted from AbstractBlockMatching.java
	# http://fiji.sc/git/?p=fiji.git;a=blob;f=src-plugins/blockmatching_/mpicbg/ij/plugin/AbstractBlockMatching.java;h=9dfebf1d807544173c763051ba45f6a65fccafad;hb=1861dafff1162f64051393a7e5ef71f0426f5bf6
	def matches2ColorSamples(self, matches):
		samples = RealPointSampleList(2)
		maxX = 1
		maxY = 1
		for match in matches:
			p = match.getP1().getL()
			q = match.getP2().getW()
			if q[0] - p[0] > maxX:
				maxX = q[0] - p[0]
			if q[1] - p[1] > maxY:
				maxY = q[1] - p[1]
		max_color = maxX
		if maxY > max_color:
			max_color = maxY
		for match in matches:
			p = match.getP1().getL()
			q = match.getP2().getW()
			dx = (q[0] - p[0]) / max_color
			dy = (q[1] - p[1]) / max_color
			rgb = colorVector(dx, dy)
			samples.add(RealPoint(p), ARGBType(rgb))
		return samples, max_color


	# Adapted from AbstractBlockMatching.java
	# http://fiji.sc/git/?p=fiji.git;a=blob;f=src-plugins/blockmatching_/mpicbg/ij/plugin/AbstractBlockMatching.java;h=9dfebf1d807544173c763051ba45f6a65fccafad;hb=1861dafff1162f64051393a7e5ef71f0426f5bf6
	def drawNearestNeighbor(self, target, nnSearchSamples, nnSearchMask):
		timer = Timer()
		timer.start()
		c = target.localizingCursor()
		while c.hasNext():
			c.fwd()
			c.get().set(ARGBType(-1))
			nnSearchSamples.search(c)
			nnSearchMask.search(c)
			if nnSearchSamples.getSquareDistance() <= nnSearchMask.getSquareDistance():
				c.get().set(nnSearchSamples.getSampler().get())
			else:
				c.get().set(nnSearchMask.getSampler().get())
		return timer.stop()

	def writePointsFile(self, points, filename):
		fn = open(filename, 'w')
		for match in points:
			xl1 = match.getP1().getL()[0]
			yl1 = match.getP1().getL()[1]
			xw1 = match.getP1().getW()[0]
			yw1 = match.getP1().getW()[1]			
			xl2 = match.getP2().getL()[0]
			yl2 = match.getP2().getL()[1]			
			xw2 = match.getP2().getW()[0]
			yw2 = match.getP2().getW()[1]
			fn.write(str(xl1) + "," + str(yl1) + "," +
					str(xw1) + "," + str(yw1) + "," + 
					str(xl2) + "," + str(yl2) + "," +
					str(xw2) + "," + str(yw2) + "\n")	

	def call(self, save_images=False):
		self.thread_used = threading.currentThread().getName()
		self.started = time.time()
		try:
			IJ.log(time.asctime())
			IJ.log(str(self.patchA))
			IJ.log(str(self.patchB))			
			print str(self.patchA)
			print str(self.patchB)

			# Adapted from ElasticMontage.java
			# https://github.com/trakem2/TrakEM2/blob/master/TrakEM2_/src/main/java/mpicbg/trakem2/align/ElasticMontage.java
			pi1 = self.patchA.createTransformedImage()
			pi2 = self.patchB.createTransformedImage()

			fp1 = pi1.target.convertToFloat()
			mask1 = pi1.getMask()
			if mask1 is None:
				fpMask1 = None
			else:
				fpMask1 = scaleByte(mask1)

			fp2 = pi2.target.convertToFloat()
			mask2 = pi2.getMask()
			if mask2 is None:
				fpMask2 = None
			else:
				fpMask2 = scaleByte(mask1)

			mesh_resolution = int(self.tileA.getWidth() / self.params.point_distance)
			effective_point_distance = self.tileA.getWidth() / mesh_resolution

			mesh = SpringMesh(mesh_resolution, self.tileA.getWidth(), self.tileA.getHeight(), 1, 1000, 0.9)
			vertices = mesh.getVertices()
			maskSamples = RealPointSampleList(2)
			for vertex in vertices:
				maskSamples.add(RealPoint(vertex.getL()), ARGBType(-1)) # equivalent of 0xffffffff
			pm12 = ArrayList()
			v1 = mesh.getVertices()

			t = self.tileB.getModel().createInverse()
			t.concatenate(self.tileA.getModel())

			BlockMatching.matchByMaximalPMCC(
							fp1,
							fp2,
							fpMask1,
							fpMask2,
							self.params.scale,
							t,
							self.params.block_radius,
							self.params.block_radius,
							self.params.search_radius,
							self.params.search_radius,
							self.params.min_R,
							self.params.rod_R,
							self.params.max_curvature_R,
							v1,
							pm12,
							ErrorStatistic(1))

			pre_smooth_block_matches = len(pm12)
			if self.params.save_data:
				pre_smooth_filename = self.params.output_folder + str(self.patchB) + "_" + str(self.patchA) + "_pre_smooth_pts.txt"
				self.writePointsFile(pm12, pre_smooth_filename)

			if self.params.use_local_smoothness_filter:
				model = Util.createModel(self.params.local_model_index)
				try:
					model.localSmoothnessFilter(pm12, pm12, self.params.local_region_sigma, self.params.max_local_epsilon, self.params.max_local_trust)
					if self.params.save_data:
						post_smooth_filename = self.params.output_folder + str(self.patchB) + "_" + str(self.patchA) + "_post_smooth_pts.txt"
						self.writePointsFile(pm12, post_smooth_filename)
				except:
					pm12.clear()

			color_samples, max_displacement = self.matches2ColorSamples(pm12)
			post_smooth_block_matches = len(pm12)
				
			print time.asctime()
			print str(self.patchB) + "_" + str(self.patchA) + "\tblock_matches\t" + str(pre_smooth_block_matches) + "\tsmooth_filtered\t" + str(pre_smooth_block_matches - post_smooth_block_matches) + "\tmax_displacement\t" + str(max_displacement) + "\trelaxed_length\t" + str(effective_point_distance) + "\tsigma\t" + str(self.params.local_region_sigma)
			IJ.log(time.asctime())
			IJ.log(str(self.patchB) + "_" + str(self.patchA) + ": block_matches " + str(pre_smooth_block_matches) + ", smooth_filtered " + str(pre_smooth_block_matches - post_smooth_block_matches) + ", max_displacement " + str(max_displacement) + ", relaxed_length " + str(effective_point_distance) + ", sigma " + str(self.params.local_region_sigma))
			if self.params.save_data and self.wf:
				self.wf.write(str(self.patchB) + 
					"\t" + str(self.patchA) + 
					"\t" + str(pre_smooth_block_matches) + 
					"\t" + str(pre_smooth_block_matches - post_smooth_block_matches) + 
					"\t" + str(max_displacement) + 
					"\t" + str(effective_point_distance) + 
					"\t" + str(self.params.local_region_sigma) + 
					"\t" + str(mesh_resolution) + "\n")

			if self.params.export_point_roi:
				pm12Sources = ArrayList()
				pm12Targets = ArrayList()

				PointMatch.sourcePoints(pm12, pm12Sources)
				PointMatch.targetPoints(pm12, pm12Targets)

				roi1 = pointsToPointRoi(pm12Sources)
				roi2 = pointsToPointRoi(pm12Targets)

				# # Adapted from BlockMatching.java
				# # https://github.com/axtimwalde/mpicbg/blob/master/mpicbg/src/main/java/mpicbg/ij/blockmatching/BlockMatching.java
				# tTarget = TranslationModel2D()
				# sTarget = SimilarityModel2D()
				# tTarget.set(-self.params.search_radius, -self.params.search_radius)
				# sTarget.set(1.0/self.params.scale, 0, 0, 0)
				# lTarget = CoordinateTransformList()
				# lTarget.add(sTarget)
				# lTarget.add(tTarget)
				# lTarget.add(t)
				# targetMapping = TransformMapping(lTarget)

				# mappedScaledTarget = FloatProcessor(fp1.getWidth() + 2*search_radius, fp1.getHeight() + 2*search_radius)

				# targetMapping.mapInverseInterpolated(fp2, mappedScaledTarget)
				# imp1 = tileImagePlus("imp1", fp1)
				# imp1.show()				
				# imp2 = ImagePlus("imp2", mappedScaledTarget)
				# imp2.show()

				imp1 = ImagePlus("imp1", fp1)
				imp1.show()				
				imp2 = ImagePlus("imp2", fp2)
				imp2.show()				

				imp1.setRoi(roi1)
				imp2.setRoi(roi2)

			if self.params.export_displacement_vectors:
				pm12Targets = ArrayList()
				PointMatch.targetPoints(pm12, pm12Targets)

				maskSamples2 = RealPointSampleList(2)
				for point in pm12Targets:
					maskSamples2.add(RealPoint(point.getW()), ARGBType(-1))
				factory = ImagePlusImgFactory()
				kdtreeMatches = KDTree(color_samples)
				kdtreeMask = KDTree(maskSamples)
				
				img = factory.create([fp1.getWidth(), fp1.getHeight()], ARGBType())
				self.drawNearestNeighbor(
							img, 
							NearestNeighborSearchOnKDTree(kdtreeMatches),
							NearestNeighborSearchOnKDTree(kdtreeMask))
				scaled_img = self.scaleIntImagePlus(img, 0.03)
				if self.params.save_data:
					fs = FileSaver(scaled_img)
					fs.saveAsTiff(self.params.output_folder + str(self.patchB) + "_" + str(self.patchA) + ".tif")
				else:
					scaled_img.show()
				print time.asctime()
				print str(self.patchB) + "_" + str(self.patchA) + "\tsaved"
				IJ.log(time.asctime())
				IJ.log(str(self.patchB) + "_" + str(self.patchA) + ": saved")
		except Exception, ex:
			self.exception = ex
			print str(ex)
			IJ.log(str(ex))
			if self.params.save_data and self.wf:
				self.wf.write(str(ex) + "\n")
		self.completed = time.time()
		return self
		# return pm12, vertices, maskSamples
		# return pm12Sources, pm12Targets

def shutdownAndAwaitTermination(pool, timeout):
	pool.shutdown()
	try:
		if not pool.awaitTermination(timeout, TimeUnit.SECONDS):
			pool.shutdownNow()
			if (not pool.awaitTermination(timeout, TimeUnit.SECONDS)):
				print >> sys.stderr, "Pool did not terminate"
	except InterruptedException, ex:
		# (Re-)Cancel if current thread also interrupted
		pool.shutdownNow()
		# Preserve interrupt status
		threading.currentThread().interrupt()

def get_tile_pairs(layer):
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
	tile_pairs = []
	AbstractAffineTile2D.pairOverlappingTiles(tiles, tile_pairs)
	return tile_pairs

def run_block_matching(tile_pairs):
	MAX_CONCURRENT = 40
	params = BlockMatcherParameters()

	# Log file
	t = time.localtime()
	ts = str(t[0]) + str(t[1]) + str(t[2]) + str(t[3]) + str(t[4]) + str(t[5])
	writefile = params.output_folder + ts + "_block_matching_montage_log.txt"
	wf = open(writefile, 'w')
	wf.write(time.asctime() + "\n")
	wf.write(writefile + "\n")
	param_values = vars(params)
	for key in param_values:
		wf.write(key + "\t" + str(param_values[key]) + "\n")
	wf.write("B_idx\t" + 
			"A_idx\t" + 
			"B_file\t" + 
			"A_file\t" + 
			"matches\t" + 
			"smooth_removed\t" + 
			"max_displacement\t" + 
			"eff_dist\t" + 
			"eff_sigma\t" +
			"mesh\n")

	for pair in tile_pairs:
		bm = BlockMatcher(pair[0], pair[1], params, wf)
		bm.call()

	# pool = Executors.newFixedThreadPool(MAX_CONCURRENT)
	# block_matchers = [BlockMatcher(pair[0], pair[1], params, wf) for pair in tile_pairs]
	# futures = pool.invokeAll(block_matchers)

	# for future in futures:
	# 	print future.get(5, TimeUnit.SECONDS)

	wf.write(time.asctime() + "\n")
	wf.close()
	# shutdownAndAwaitTermination(pool, 5)

def main():
	# Get the first open project
	project = Project.getProject('stack_import.xml')

	# Get layerset
	layerset = project.getRootLayerSet()
	layers = layerset.getLayers()
	tile_pairs = []
	for layer in layers:
		tile_pairs += get_tile_pairs(layer)
	run_block_matching(tile_pairs)
