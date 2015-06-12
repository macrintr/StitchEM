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
 

wafer = "S2-W003-W008"
# bucket = "/usr/people/tmacrina/seungmount/research/"
bucket = "/mnt/data0/"
# writefile = bucket + "tommy/150528_zfish/" + wafer + "_import.txt"
project_folder = bucket + "tommy/150502_piriform/S2-W001/"

project = Project.getProject("150605_S2-W001_elastic_S2-W002_affine.xml")
loader = project.getLoader()
# loader.setMipMapsRegeneration(False) # disable mipmaps
layerset = project.getRootLayerSet()



layers = layerset.getLayers()
starting_index = len(layers) + 1

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

clahe_filter = CLAHE()
print clahe_filter.toXML("\t")

for layer in layerset.getLayers()[starting_index:1]:
     # layer.recreateBuckets()
	for patch in layer.getDisplayables(Patch):
          print patch
          patch.updateBucket()
          patch.setFilters([clahe_filter])
          # roi.add(patch.getBoundingBox())

# project.save()