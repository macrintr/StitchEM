# Thomas Macrina
# 150323
# Jython conversion of BlockMatching_ExtractPoinRoi (sic)
# http://fiji.sc/git/?p=fiji.git;a=blob;f=src-plugins/blockmatching_/mpicbg/ij/plugin/BlockMatching_ExtractPoinRoi.java;h=2e9daf810b81110ee899e12c236c3864ab09ed89;hb=1861dafff1162f64051393a7e5ef71f0426f5bf6

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
from mpicbg.trakem2.align import Util

from net.imglib2 import RealPoint
from net.imglib2 import KDTree
from net.imglib2 import RealPointSampleList
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

MAX_CONCURRENT = 20

class BlockMatcher(Callable):
	def __init__(self, imgA, imgB):
		self.imgA = imgA
		self.imgB = imgB

		# Block matching parameters 
		self.exportPointRoi = True
		self.exportDisplacementVectors = True

		self.scale = 1.00
		self.searchRadius = 35
		self.blockRadius = 35
		self.meshResolution = 32
		self.minR = 0.6
		self.maxCurvatureR = 10
		self.rodR = 1
		self.useLocalSmoothnessFilter = True
		self.localModelIndex = 1 # 0: Translation, 1: Rigid, 2: Similarity, 3: Affine
		self.localRegionSigma = 210
		self.maxLocalEpsilon = 6
		self.maxLocalTrust = 999999

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

	def call(self):
		self.thread_used = threading.currentThread().getName()
		self.started = time.time()
		try:
			# folder = "/mnt/data0/tommy/150318_debug_block_matching/S2-W003/"
			folder = "/home/seunglab/tommy/S2-W002/affine_renders_0175x/"
			filenames = os.listdir(folder)
			filenames.sort()

			imp1 = IJ.openImage(os.path.join(folder, filenames[self.imgA]))
			imp2 = IJ.openImage(os.path.join(folder, filenames[self.imgB]))
			IJ.log(time.asctime())
			IJ.log(str(self.imgA) + ": " + str(imp1))
			IJ.log(str(self.imgB) + ": " + str(imp2))			
			print str(self.imgA) + ": " + str(imp1)
			print str(self.imgB) + ": " + str(imp2)

			mesh = SpringMesh(self.meshResolution, imp1.getWidth(), imp1.getHeight(), 1, 1000, 0.9)
			vertices = mesh.getVertices()
			maskSamples = RealPointSampleList(2)
			for vertex in vertices:
				maskSamples.add(RealPoint(vertex.getL()), ARGBType(-1)) # equivalent of 0xffffffff
			pm12 = ArrayList()
			v1 = mesh.getVertices()

			ip1 = imp1.getProcessor().convertToFloat().duplicate()
			ip2 = imp2.getProcessor().convertToFloat().duplicate()

			ip1Mask = self.createMask(imp1.getProcessor().convertToRGB())
			ip2Mask = self.createMask(imp2.getProcessor().convertToRGB())

			ct = TranslationModel2D()

			BlockMatching.matchByMaximalPMCC(
							ip1,
							ip2,
							ip1Mask,
							ip2Mask,
							self.scale,
							ct,
							self.blockRadius,
							self.blockRadius,
							self.searchRadius,
							self.searchRadius,
							self.minR,
							self.rodR,
							self.maxCurvatureR,
							v1,
							pm12,
							ErrorStatistic(1))

			IJ.log(time.asctime())
			IJ.log(str(self.imgB) + "_" + str(self.imgA) + " Block matches: " + str(len(pm12)))

			if self.useLocalSmoothnessFilter:
				model = Util.createModel(self.localModelIndex)
				try:
					model.localSmoothnessFilter(pm12, pm12, self.localRegionSigma, self.maxLocalEpsilon, self.maxLocalTrust)
				except:
					pm12.clear()

			if self.exportPointRoi:
				pm12Sources = ArrayList()
				pm12Targets = ArrayList()

				PointMatch.sourcePoints(pm12, pm12Sources)
				PointMatch.targetPoints(pm12, pm12Targets)

				roi1 = pointsToPointRoi(pm12Sources)
				roi2 = pointsToPointRoi(pm12Targets)

				imp1.setRoi(roi1)
				imp2.setRoi(roi2)

			if self.exportDisplacementVectors:
				pm12Targets = ArrayList()
				PointMatch.targetPoints(pm12, pm12Targets)

				maskSamples2 = RealPointSampleList(2)
				for point in pm12Targets:
					maskSamples2.add(RealPoint(point.getW()), ARGBType(-1))
				factory = ImagePlusImgFactory()
				kdtreeMatches, max_displacement = KDTree(self.matches2ColorSamples(pm12))
				kdtreeMask = KDTree(maskSamples)

				print time.asctime()
				print str(self.imgB) + "_" + str(self.imgA) + " max_displacement " + str(max_displacement)
				
				img = factory.create([imp1.getWidth(), imp1.getHeight()], ARGBType())
				self.drawNearestNeighbor(
							img, 
							NearestNeighborSearchOnKDTree(kdtreeMatches),
							NearestNeighborSearchOnKDTree(kdtreeMask))
				scaled_img = self.scaleIntImagePlus(img, 0.1)
				scaled_img.show()
				# fs = FileSaver(scaled_img)
				# fs.saveAsTiff("/mnt/data0/tommy/150325_block_match_vector_plots_smoothness/S2-W003/" + filenames[self.imgB]
				# print time.asctime()
				# print str(self.imgB) + "_" + str(self.imgA) + " Saved " + filenames[self.imgB]
				# IJ.log(time.asctime())
				# IJ.log(str(self.imgB) + "_" + str(self.imgA) + " Saved " + filenames[self.imgB])
		except Exception, ex:
			self.exception = ex
			print str(ex)
			IJ.log(str(ex))
		self.completed = time.time()
		# return self
		return pm12Sources, pm12Targets


def shutdown_and_await_termination(pool, timeout):
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
		Thread.currentThread().interrupt()

# Cycle through images
image_pairs = [(i-1, i) for i in range(1,149)]

pool = Executors.newFixedThreadPool(MAX_CONCURRENT)
block_matchers = [BlockMatcher(pair[0], pair[1]) for pair in image_pairs]
futures = pool.invokeAll(block_matchers)

for future in futures:
	print future.get(5, TimeUnit.SECONDS)

shutdown_and_await_termination(pool, 5)