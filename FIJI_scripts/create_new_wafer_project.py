# Albert Cardona 2011-02-02
# At Madison, Wisconsin, with Erwin Frise
from ini.trakem2 import Project
from ini.trakem2.utils import Utils
from ini.trakem2.display import Patch
from mpicbg.ij.clahe import Flat
from ij.gui import Toolbar
from java.awt import Color
from ij import ImagePlus
from ij import IJ
from ini.trakem2.imaging.filters import CLAHE
from mpicbg.trakem2.align import AlignmentUtils
import os
import re
import math
import csv
from java.awt.geom import AffineTransform
 

wafer = "W004"
bucket = "/usr/people/tmacrina/seungmount/research/"
project_folder = bucket + "tommy/150528_zfish/"
# project_folder = "/mnt/data0/tommy/tests/150501_trakem_project_creation/"

project = Project.newFSProject("blank", None, project_folder)
loader = project.getLoader()
# loader.setMipMapsRegeneration(False) # disable mipmaps
layerset = project.getRootLayerSet()
# layerset.setSnapshotsMode(1) # outlines

task = loader.importImages(
          layerset.getLayers().get(0),  # the first layer
          project_folder + wafer + "_import.txt", # the absolute file path to the text file with absolute image file paths
          "\t", # the column separator  <path> <x> <y> <section index>
          1.0, # section thickness, defaults to 1
          1.0, # calibration, defaults to 1
          False, # whether to homogenize contrast, avoid
          1.0, # scaling factor, default to 1
          0) # border width
 
task.join() # Optional: wait until all images have been imported

# Get transforms
# affine_folder = project_folder + "/affine_transforms/"
# # folder = "/usr/people/tmacrina/Desktop/elastic_experiments/150317_bad_correspondences/affine_alignments/"

# # Cycle through all layers
# for layer in layerset.getLayers():
#      # Cycle through all images in that layer
#      for patch in layer.getDisplayables(Patch):
#           # Find corresponding transform file
#           # Tile images are named like this:
#           #    Tile_r4-c4_S2-W002_sec1.tif
#           # So the associated transform csv is this:
#           #    Tile_r4-c4_S2-W002_sec1.csv
#           # Might be better to use patch.getImageFilePath()
#           patch_title = patch.getTitle()[:-4]  # knock off the .tif
#           title_split = patch_title.split("_")
#           if title_split[-1][0] != "s":
#                patch_title = "_".join(a[:-1])
#           tform_fn = affine_folder + patch_title + ".csv"

#           # Build affine transform
#           # Java defines its affine as follows:
#           # [ x']   [  m00  m01  m02  ] [ x ]   [ m00x + m01y + m02 ]
#           # [ y'] = [  m10  m11  m12  ] [ y ] = [ m10x + m11y + m12 ]
#           # [ 1 ]   [   0    0    1   ] [ 1 ]   [         1         ]
#           # Java function:
#           # AffineTransform(double m00, double m10, double m01, double m11, double m02, double m12)
#           #
#           # We spit out the transpose of that matrix from MATLAB as csv
#           # The Java function inputs are ordered as the rows of the transpose
#           if title_split[-2] == wafer_title:
#                affine_inputs = []
#                print tform_fn
#                tform_csv = open(tform_fn)
#                tform_matrix = csv.reader(tform_csv)
#                for row in tform_matrix:
#                     affine_inputs.extend(map(float, row)[:2]) # extend not append
#                tform_csv.close()

#                affine_tform = AffineTransform(*affine_inputs) # expands the elements of the list

#                print patch_title
#                # Apply transform
#                patch.setAffineTransform(affine_tform)
#                print patch.getAffineTransform()
#                # Update internal the internals
#                patch.updateBucket()

# Display.repaint()
# layerset.setMinimumDimensions()
# Display.getFront().getProject().save()


# project.saveAs(project_folder + wafer + "_import.xml", True)
# Display.getFront().getProject().adjustProperties()

# project.destroy()

clahe_filter = CLAHE()
print clahe_filter.toXML("\t")
# layer1 = layerset.getLayers()[1]
# roi = layer1.getDisplayables(Patch)[0].getBoundingBox()

for layer in layerset.getLayers():
	for patch in layer.getDisplayables(Patch):
          print patch
          patch.setFilters([clahe_filter])
          # roi.add(patch.getBoundingBox())

# loader.saveAs(project, project_folder + wafer_title + ".xml", XMLOptions())

# loader.setMipMapsRegeneration(True)
# futures = []
# for layer in layerset.getLayers():
#      for patch in layer.getDisplayables(Patch):
#           print patch
#           futures.append(patch.updateMipMaps())
# Utils.wait(futures)

# Check that CLAHE applied properly with simple image
# img = loader.getFlatAWTImage(
#           layer1,
#           roi,
#           0.005, # layer_scale
#           0x0000ff00,
#           ImagePlus.COLOR_RGB,
#           type(Patch),
#           AlignmentUtils.filterPatches(layer1, None),
#           True,
#           Color(0x00ffffff, True))

# imp = ImagePlus("Flat montage", img)
# imp.show()

# project.save()