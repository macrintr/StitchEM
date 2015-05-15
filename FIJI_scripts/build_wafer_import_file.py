import os
import re

wafer = "W001"
bucket = "/mnt/bucket/labs/seung/research/"
writefile = bucket + "tommy/150502_piriform/S2-" + wafer + "_import.txt"
# writefile = "/mnt/data0/tommy/S2-" + wafer + "/S2-" + wafer + "_import.txt"
imagefolder = bucket + "GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-" + wafer + "/HighResImages_ROI1_7nm_120apa/"
# imagefolder = "/mnt/data0/ashwin/07122012/S2-" + wafer + "/"

wf = open(writefile, 'w')
foldernames = os.listdir(imagefolder)
for folder in foldernames:
	if folder[-7:] == "Montage":
		layer = int(re.match(r'\d+', folder[11:]).group())
		# print layer

		# if layer == 173:
		filenames = os.listdir(imagefolder + folder)
		for fn in filenames:
			if fn[0] == "T" and fn[-3:] == "tif":
				# print imagefolder + folder + "/" + fn + "\t0\t0\t" + str(layer) +"\n"
				wf.write(imagefolder + folder + "/" + fn + "\t0\t0\t" + str(layer) +"\n")
wf.close()
