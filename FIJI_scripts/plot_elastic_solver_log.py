# Thomas Macrina
# 150730
#
# Plot elastic solver log file outputs
# i mean min max

import numpy as np
import matplotlib.pyplot as plt

bucket = '/usr/people/tmacrina/seungmount/research/'
project_folder = bucket + 'tommy/trakem_tests/150709_elastic_montage/'
input_file = project_folder + 'W001_sec20_my_elastic_log.txt'

log = np.genfromtxt(input_file, delimiter=" ")
plt.plot(log[:,0], log[:,1])
plt.show()