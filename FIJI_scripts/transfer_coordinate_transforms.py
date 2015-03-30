# Thomas Macrina
# 150224
# Transfer transform of last section to its duplicate as first section in next project
# https://github.com/axtimwalde/fiji-scripts/blob/master/TrakEM2/project1-project2-assign-ct-and-affine-layer.bsh

import ij
from ini.trakem2.display import Display, Patch
from java.util import HashMap

# folder = "/mnt/data0/tommy/S2-W005/coordinate_transforms/"

# Change the index here to be the project from the previous stack
original_project = Project.getProject('150308_S2-W007_sequential.xml')
target_project = Project.getProject('150308_S2-W008_sequential.xml')

print original_project
print target_project

original_layer = original_project.getRootLayerSet().getLayers()[-1]
print original_layer

target_layer = target_project.getRootLayerSet().getLayers()[0]
print target_layer

original_patches = original_layer.getDisplayables(Patch)
print original_patches 

target_patches = target_layer.getDisplayables(Patch)
print target_patches

# Overkill to hash, but we'll do it to match Saalfeld
cp = HashMap()
IJ.log( "Collecting target patches..." )

# Get the display order in the original section
display_order = []
for patch in original_patches:
	display_order.append(original_layer.relativeIndexOf(patch))

# Sort original indexed to put it in display order
original_indexed = zip(display_order, original_patches)
original_indexed = sorted(original_indexed, key=lambda x: x[0])

for i, patch in enumerate(target_patches):
	print patch.getTitle()
	cp.put(patch.getTitle(), patch)
	IJ.showProgress(i, target_patches.size())

IJ.log( "Assigning transformations..." );

for i, patch in original_indexed:
	print patch.getTitle()
	if cp.containsKey(patch.getTitle()):
		patch_title = patch.getTitle()[:-4]
		print patch.getId(), patch_title
		print patch.hasCoordinateTransform()

		target_patch = cp.get(patch.getTitle())
		target_patch.setCoordinateTransform(patch.getCoordinateTransform())
		target_patch.getAffineTransform().setTransform(patch.getAffineTransform())
		target_patch.updateInDatabase("transform")
		target_patch.updateBucket()

		# tform_file = folder + patch_title + '_original.xml'
		# tform_xml = open(tform_file, 'w')
		# tform_xml.write(patch.getCoordinateTransform().toXML('\t'))
	 	# tform_xml.close()

		# tform_file = folder + patch_title + '_target.xml'
		# tform_xml = open(tform_file, 'w')
		# tform_xml.write(target_patch.getCoordinateTransform().toXML('\t'))
	 	# tform_xml.close()

		print patch.getAffineTransform()
		print target_patch.getAffineTransform()

		target_layer.moveBottom(target_patch)	 				

	IJ.showProgress(i, original_patches.size())

Display.repaint()
