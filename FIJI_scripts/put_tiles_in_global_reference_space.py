# Thomas Macrina
# 150710
# Jython conversion of BlockMatching_ExtractPoinRoi (sic)

from mpicbg.models import SimilarityModel2D
from mpicbg.models import CoordinateTransformList
from mpicbg.ij import TransformMapping
from mpicbg.trakem2.align.Align import ParamOptimize
from mpicbg.trakem2.align import Align
from mpicbg.trakem2.align import RigidTile2D
from mpicbg.trakem2.align import AbstractAffineTile2D

# Get the first open project
project = Project.getProject('stack_import.xml')

# Get layerset
layerset = project.getRootLayerSet()
layers = layerset.getLayers()
patches = layers.getDisplayables(Patch)

po = ParamOptimize()
po.maxEpsilon = 25.0
po.minInlierRatio = 0.0
po.minNumInliers = 12
po.expectedModelIndex = 0
po.desiredModelIndex = 0
po.rejectIdentity = True
po.identityTolerance = 5.0

search_radius = 200
scale = 1.0 # Don't change, unless you fix scaling in the images
tiles = []
fixed_tiles = []
fixed_patches = []
Align.tilesFromPatches(po, patches, fixed_patches, tiles, fixed_tiles)

tile_pairs = []
AbstractAffineTile2D.pairOverlappingTiles(tiles, tile_pairs)

tileA = tile_pairs[3][0]
tileB = tile_pairs[3][1]

pi1 = tileA.getPatch().createTransformedImage()
pi2 = tileB.getPatch().createTransformedImage()

fp1 = pi1.target.convertToFloat()
fp2 = pi2.target.convertToFloat()

t = tileB.getModel().createInverse()
t.concatenate(tileA.getModel())
tTarget = TranslationModel2D()
sTarget = SimilarityModel2D()
tTarget.set(-search_radius, -search_radius)
sTarget.set(1.0/scale, 0, 0, 0)
lTarget = CoordinateTransformList()
lTarget.add(sTarget)
lTarget.add(tTarget)
lTarget.add(t)
targetMapping = TransformMapping(lTarget)

mappedScaledTarget = FloatProcessor(fp1.getWidth() + 2*search_radius, fp1.getHeight() + 2*search_radius)

targetMapping.mapInverseInterpolated(fp2, mappedScaledTarget)
a = ImagePlus("mst", mappedScaledTarget)
a.show()
b = ImagePlus("fp1", fp1)
b.show()
c = ImagePlus("fp2", fp2)
c.show()
