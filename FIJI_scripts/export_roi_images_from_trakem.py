from ini.trakem2 import Project
from ini.trakem2.display import Display, Patch
from java.awt import Color
from ij import ImagePlus
from ij.gui import Roi
from ij.plugin.frame import RoiManager
from ij.io import FileSaver 
import csv

project = Project.getProjects().get(0)
layerset = project.getRootLayerSet()

backgroundColor = Color.black
scale = 1.0
  
original_roi_width = 500.0
original_roi_height = 500.0

pad_x = 250.0
pad_y = 250.0

folder = "/mnt/data/Talmo/Zfish/"
filename = folder + "test.txt"
new_filename = folder + "ROI/" + "ROI_"

roi_file = open(filename)
reader = csv.reader(roi_file, delimiter='\t')
for row in reader:
  # row = [17524.0, 33960.0, 953.0]
  print(row[1:4])
  x, y, z = map(float, row[1:4])
  z = int(z)
  print x, y, z

  layer = layerset.getLayers()[z]
  tiles = layer.getDisplayables(Patch)  # selected Patch instances only

  target_roi_x = x - pad_x
  target_roi_y = y - pad_y

  target_roi = Roi(target_roi_x, target_roi_y, original_roi_width, original_roi_height)
  # getRoiManager().addRoi(target_roi)

  ip = Patch.makeFlatImage(
             ImagePlus.GRAY8,
             layer,
             target_roi.getBounds(), #roi,
             scale,
             tiles,
             backgroundColor,
             True)  # use the min and max of each tile
   
  imp = ImagePlus("Flat montage", ip)
  fs = FileSaver(imp)
  filepath = new_filename + str(target_roi_x) + "_" + str(target_roi_y) + "_" + str(original_roi_width) + "_" + str(original_roi_height) + ".tif"
  fs.saveAsTiff(filepath)

roi_file.close()