import os
import re

# wafers = ["S2-W001", "S2-W002", "S2-W003", "S2-W004", "S2-W005", "S2-W006", "S2-W007", "S2-W008"]
wafers = ["S2-W001"]
workstation_bucket = "/usr/people/tmacrina/seungmount/research/"
seunglab_bucket = "/mnt/bucket/labs/seung/research/"
# import_filename_template = "{0}tommy/150502_piriform/S2-W001/S2-W003-W008_import.txt"
import_filename_template = "{0}tommy/trakem_tests/150709_rough_xy_montage/test_import.txt"

folder_name_idx = 11 # 8 for zfish; 11 for piriform
base_section_count = 317

# imagefolder = bucket + "GABA/data/atlas/MasterUTSLdirectory/10122012-1/" + wafer + "/HighResImages_Fine_5nm_120apa_" + wafer + "/"
# imagefolder = bucket + "GABA/data/atlas/MasterUTSLdirectory/07122012S2/S2-" + wafer + "/HighResImages_ROI1_7nm_120apa/"
# image_folder_template = "{0}ashwin/07122012/{1}/"
image_folder_template = "{0}GABA/data/atlas/MasterUTSLdirectory/07122012S2/{1}/HighResImages_ROI1_7nm_120apa/"
import_line_template = "{0}{1}/{2}\t0\t0\t{3}\n"

import_filename = import_filename_template.format(workstation_bucket)
wf = open(import_filename, 'w+')

for wafer in wafers:

	print wafer
	wafer_section_count = 0

	input_image_folder = image_folder_template.format(workstation_bucket, wafer)
	write_image_folder = image_folder_template.format(seunglab_bucket, wafer)

	foldernames = os.listdir(input_image_folder)
	for folder in foldernames:
		if folder[-7:] == "Montage":
			section = int(re.match(r'\d+', folder[folder_name_idx:]).group())
			
			if section == 19 or section == 20:
				print section
				filenames = os.listdir(input_image_folder + folder)
				for filename in filenames:
					if filename[0] == "T" and filename[-3:] == "tif":
						# print imagefolder + folder + "/" + fn + "\t0\t0\t" + str(section) +"\n"
						# wf.write(imagefolder + folder + "/" + fn + "\t0\t0\t" + str(section) +"\n")
						import_line = import_line_template.format(write_image_folder, folder, filename, str(section - 19))
						wf.write(import_line)

				if section > wafer_section_count:
					wafer_section_count = section

	print wafer_section_count

	base_section_count += wafer_section_count

wf.close()
