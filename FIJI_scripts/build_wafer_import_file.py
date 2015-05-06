import os
import re

wafer = "S2-W005"
# writefile = "/mnt/bucket/labs/seung/research/tommy/S2-W002/import_files/S2-W002_import.txt"
writefile = "/mnt/data0/tommy/" + wafer + "/" + wafer + "_import.txt"
# imagefolder = "/mnt/bucket/labs/seung/research/GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-W002/HighResImages_ROI1_W002_7nm_120apa/"
imagefolder = "/mnt/data0/ashwin/07122012/" + wafer + "/"

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
