from ini.trakem2.display import Display, Patch
from java.awt import Color
 
project = Project.getProjects().get(0)
layerset = project.getRootLayerSet()
 
front = Display.getFront() # the active TrakEM2 display window
layer = front.getLayer()
tiles = front.getSelection().get(Patch)  # selected Patch instances only
backgroundColor = Color.black
scale = 0.175
 
roi = tiles[0].getBoundingBox()
for tile in tiles[1:]:
  roi.add(tile.getBoundingBox())
 
print "Creating flat image from", len(tiles), "image tiles"
 
ip = Patch.makeFlatImage(
           ImagePlus.GRAY8,
           layer,
           layerset.get2DBounds(), #roi,
           scale,
           tiles,
           backgroundColor,
           True)  # use the min and max of each tile
 
imp = ImagePlus("Flat montage", ip)
imp.show()