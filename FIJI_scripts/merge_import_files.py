import os
import re

# bucket = "/mnt/bucket/labs/seung/"
bucket = "/usr/people/tmacrina/seungmount/"
bucket_ext = bucket + "research/tommy/150502_piriform/"
folder = bucket_ext + "/seunglab05_import_files/"
writefile = bucket_ext + "stack_import.txt"

filenames = sorted(os.listdir(folder))
ref_layer = 0
with open(writefile, 'w') as wf:
	for fn in filenames:
		# rf = open(folder + fn, 'r')
		max_layer = 0
		with open(folder + fn, 'r') as rf:
			for line in rf.readlines():
				tile_location = line.strip().split("\t")[0]
				layer_idx = int(line.strip().split("\t")[-1])
				if layer_idx > max_layer:
					max_layer = layer_idx
				wf.write(tile_location + "\t0\t0\t" + str(layer_idx + ref_layer) +"\n")
		print fn, max_layer, ref_layer
		ref_layer += max_layer
