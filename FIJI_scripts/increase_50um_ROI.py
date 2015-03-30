# Thomas Macrina
# 150308
# Increase ROI to 50 um (72000 x 72000 px)
# 72000 px * 7 nm / px = 50.4 um

from ini.trakem2.display import Display, Patch
from ij.gui import Roi
from ij.plugin.frame import RoiManager
 
def getRoiManager():
  """ Obtain a valid instance of the ROI Manager.
  Notice that it could still be null if its window is closed."""
  if RoiManager.getInstance() is None:
    RoiManager()
  return RoiManager.getInstance()

original_roi = getRoiManager().getRoi(0)
x = original_roi.getBounds().getX()
y = original_roi.getBounds().getY() - original_roi.getBounds().getHeight()
w = original_roi.getBounds().getWidth() * 2
h = original_roi.getBounds().getHeight() * 2

target_roi = Roi(x, y, w, h)
print target_roi
getRoiManager().addRoi(target_roi)

