# Thomas Macrina

# Pulled from: 
# http://fiji.sc/TrakEM2_Scripting#Import_images.2C_montage_them.2C_blend_them_and_save_as_.xml

 
import os, re, math
from java.awt.geom import AffineTransform
 
#folder = "/path/to/folder/with/all/images/"
folder = "/usr/people/tmacrina/Desktop/elastic_experiments/importing_test/images"
 
# 1. Create a TrakEM2 project
project = Project.newFSProject("blank", None, folder)
# OR: get the first open project
# project = Project.getProjects().get(0)
 
layerset = project.getRootLayerSet()
 
#  2. Create 10 layers (or as many as you need)
for i in range(1):
  layerset.getLayer(i, 1, True)
 
# ... and update the LayerTree:
project.getLayerTree().updateList(layerset)
# ... and the display slider
Display.updateLayerScroller(layerset)


# By layer, add patches and apply transform
filenames = os.listdir(folder)
# [ x']   [  m00  m01  m02  ] [ x ]   [ m00x + m01y + m02 ]
# [ y'] = [  m10  m11  m12  ] [ y ] = [ m10x + m11y + m12 ]
# [ 1 ]   [   0    0    1   ] [ 1 ]   [         1         ]
# AffineTransform(double m00, double m10, double m01, double m11, double m02, double m12) 
affines = [AffineTransform(1, 0, 0, 1, 0, 0),
            AffineTransform(math.cos(math.pi/4), -math.sin(math.pi/4), math.sin(math.pi/4), math.cos(math.pi/4), 100, 0)]
layers = layerset.getLayers()

for i, layer in enumerate(layerset.getLayers()):
  for j, fn in enumerate(filenames[0:2]):
    filepath = os.path.join(folder, fn)
    patch = Patch.createPatch(project, filepath)
    patch.setAffineTransform(affines[j])
    layer.add(patch)
  # Update internal quadtree of the layer
  layer.recreateBuckets()

# Resize width and height of the world to fit the montages
layerset.setMinimumDimensions()
# Blend images of each layer
# Nonlinear blending based on S Preibisch plugin (http://fiji.sc/wiki/index.php/Stitching_2D/3D)
# Exponentially weighted by distance to the edge
Blending.blendLayerWise(layerset.getLayers(), True, None)