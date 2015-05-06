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
 

wafer = "S2-W008"
# writefile = "/mnt/bucket/labs/seung/research/tommy/S2-W002/import_files/S2-W002_import.txt"
writefile = "/mnt/data0/tommy/" + wafer + "/" + wafer + "_import.txt"
# imagefolder = "/mnt/bucket/labs/seung/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W002/HighResImages_ROI1_W002_7nm_120apa/"
imagefolder = "/mnt/data0/ashwin/07122012/" + wafer + "/"

project = Project.newFSProject("blank", None, "/mnt/data0/tommy/" + wafer + "/")
loader = project.getLoader()
loader.setMipMapsRegeneration(False) # disable mipmaps
layerset = project.getRootLayerSet()
layerset.setSnapshotsMode(1) # outlines

task = loader.importImages(
          layerset.getLayers().get(0),  # the first layer
          "/mnt/data0/tommy/" + wafer + "/" + wafer + "_import.txt", # the absolute file path to the text file with absolute image file paths
          "\t", # the column separator  <path> <x> <y> <section index>
          1.0, # section thickness, defaults to 1
          1.0, # calibration, defaults to 1
          False, # whether to homogenize contrast, avoid
          1.0, # scaling factor, default to 1
          0) # border width
 
task.join() # Optional: wait until all images have been imported

project.saveAs("/mnt/data0/tommy/" + wafer + "/" + wafer + "_import.xml", True)
Display.getFront().getProject().adjustProperties()

# project.destroy()

layerset = project.getRootLayerSet()
futures_CLAHE = []
futures_mipmaps = []
for layer in layerset.getLayers():
	for patch in layer.getDisplayables(Patch):
		print patch
		imp = patch.getImagePlus()
		# futures_CLAHE.append((IJ.run(imp, "Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)"))
		futures_CLAHE.append(Flat.getFastInstance().run(imp, 250, 256, 4, None, False))
		futures_mipmaps.append(patch.updateMipMaps())

Utils.wait(futures_CLAHE)
Utils.wait(futures_mipmaps)

project.save()