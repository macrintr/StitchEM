# Thomas Macrina
# 150223
# Find ROI from one wafer to the next

from ini.trakem2.display import Display, Patch
from ij.gui import Roi
from ij.plugin.frame import RoiManager
 
def getRoiManager():
  """ Obtain a valid instance of the ROI Manager.
  Notice that it could still be null if its window is closed."""
  if RoiManager.getInstance() is None:
    RoiManager()
  return RoiManager.getInstance()

# Change the index here to be the project from the previous stack
original_project = Project.getProject('150308_S2-W007_sequential.xml')
target_project = Project.getProject('150308_S2-W008_sequential.xml')

print original_project
original_layerset = original_project.getRootLayerSet()
print original_layerset
original_layer = original_layerset.getLayers()[-1]
print original_layer

original_tiles = original_layer.getDisplayables(Patch)  # selected Patch instances only
print original_tiles

original_section_rect = original_tiles[0].getBoundingBox()
for tile in original_tiles[1:]:
  original_section_rect.add(tile.getBoundingBox())

print original_section_rect

# Make sure to have the old ROI added to the ROI manager before preceding
original_roi = getRoiManager().getRoi(0)
print original_roi

original_roi_width = original_roi.getBounds().getWidth()
original_roi_height = original_roi.getBounds().getHeight()

original_set_rect = original_layerset.get2DBounds()
print original_set_rect

target_roi_x_delta = original_set_rect.getWidth() - original_section_rect.getX()
target_roi_y_delta = original_set_rect.getHeight() - original_section_rect.getY()


print target_project
target_layerset = target_project.getRootLayerSet()
print target_layerset
target_layer = target_layerset.getLayers()[0]
print target_layer

target_tiles = target_layer.getDisplayables(Patch)  # selected Patch instances only
print target_tiles

target_section_rect = target_tiles[0].getBoundingBox()
for tile in target_tiles[1:]:
  target_section_rect.add(tile.getBoundingBox())

print target_section_rect

target_set_rect = target_layerset.get2DBounds()
print target_set_rect

target_roi_x = (target_section_rect.getX() - original_section_rect.getX()) + original_roi.getBounds().getX()
target_roi_y = (target_section_rect.getY() - original_section_rect.getY()) + original_roi.getBounds().getY()

print target_roi_x
print target_roi_y

target_roi = Roi(target_roi_x, target_roi_y, original_roi_width, original_roi_height)
getRoiManager().addRoi(target_roi)