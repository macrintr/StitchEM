# Thomas Macrina

# Adapted from: 
# http://fiji.sc/TrakEM2_Scripting#Concatenating_multiple_project_XML_files_by_copying_all_their_layers

from ini.trakem2 import Project
from ini.trakem2.display import Patch
from ini.trakem2.utils import Utils

# Wafer
bucket = '/mnt/bucket/labs/seung/research/'
# project_folder = bucket + 'tommy/150528_zfish/'
# project_folder = bucket + 'tommy/150502_piriform/'
project_folder = bucket + 'tommy/trakem_test/150622_fix_rigid'

# Get the first open project
project = Project.getProject('turtle_rigid.xml')

# Get layerset
layerset = project.getRootLayerSet()

start = 0
finish = 2

layers = layerset.getLayers()[start:finish]

# Regenerate all image mipmaps
futures = []
for layer in layers:
	for patch in layer.getDisplayables(Patch):
		futures.append(patch.updateMipMaps())
Utils.wait(futures)