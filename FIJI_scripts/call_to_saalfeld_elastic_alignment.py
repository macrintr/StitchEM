# Thomas Macrina
# 150224
# Script to automatically run elastic alignment

from mpicbg.trakem2.align import ElasticLayerAlignment
from ini.trakem2.display import Display, Patch
from ini.trakem2.utils import Filter

params = ElasticLayerAlignment.Param() 
params.layerScale = 0.175
params.searchRadius = 40
params.blockRadius = 200
params.minR = 0.10
params.maxCurvatureR = 10000
params.rodR = 0.60
params.useLocalSmoothnessFilter = True
params.localRegionSigma = 200
params.maxLocalEpsilon = 40
params.maxLocalTrust = 10000000000
params.resolutionSpringMesh = 128

params.isAligned = True
params.maxNumNeighbors = 2



# params.setup()

# Get the project
project = Project.getProject('import.xml')
# Get layerset
layerset = project.getRootLayerSet()
fixed_layer = set([layerset.getLayers()[0]])
moving_layers = layerset.getLayers()[1:]
empty_layers = set()
box = layerset.get2DBounds()
propagateTransformBefore = False
propagateTransformAfter = False

# print fixed_layer
# print moving_layers

elasticAligner = ElasticLayerAlignment()
# elasticAligner.exec(params, project, moving_layers, fixed_layer, empty_layers, box, propagateTransformBefore, propagateTransformAfter, Filter)
elasticAligner.exec(layerset, 0, 10, 0, propagateTransformBefore, propagateTransformAfter, box, Filter.accept)


