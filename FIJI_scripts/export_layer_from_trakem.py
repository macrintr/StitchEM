from ini.trakem2 import Project
from ini.trakem2.display import Patch

project = Project.getProjects().get(0)
layerset = project.getRootLayerSet()
layer = layerset.getLayers().get(54)

loader = project.getLoader()
scale = 0.175

flat = loader.makeFlatImage(ImagePlus.GRAY8, layer, layerset.get2DBounds(), scale, layer.getAll(Patch), Color.black)
imp = ImagePlus("snap " + str(scale), flat).show()