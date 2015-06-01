StitchEM
========
A set of tools for serial electron microscopy image registration.

Requirements
------------
* MATLAB 2013
* FIJI (ImageJ 1.49p)
* TrakEM2 FIJI plugin (1.0a 2012-07-04)

License
-------
Released under the latest General Public License.

Getting started
---------------
The pipeline acts in two phases to align serial electron microscopy
images. It generates a rough affine alignment (using feature matching
in MATLAB), then provides a final piecewise affine alignment (using 
cross correlation with TrakEM2 in FIJI, we refer to it as elastic alignment).

Our microscopy images are organized as follows:

* wafer folder
  * section folder
    * downscaled overview image
    * multiple tile images named with their grid location

The general pipeline:

1. "affine alignment" (MATLAB)
  1. rough_xy: align tiles to overview
  2. xy: align tiles within a section to each other
  3. overview_rough_z: align overview to prior overview
  4. rough_z: apply overview_rough_z to tiles
  5. z: align stitched tile section to prior stitched tile section
2. "elastic alignment" (TrakEM2/FIJI)

To start using the MATLAB portion of the code base:

1. Run "Initialize_StitchEM" to add the directory paths.
2. Open one of the wafer files in "wafers_piriform" and "wafers_zfish".
3. Open "pipeline/default_params" to understand the parameters for the methods.
3. Create a new wafer file with your own settings and run it. This will setup a new directory for alignment checkpoints.
4. Open "pipeline/align_stack_xy". Read through the comments and functions (in MATLAB's editor, right-click on a function name to open its code).
5. Open "pipeline/align_stack_z".

The TrakEM2/FIJI portion of the code base is written in Jython and can be found in the "FIJI_scripts" folder. Use FIJI's "Jython interpretter" plugin to run them. To get started:

1. Create an import text file for your tile images using "build_wafer_import_file.py".
2. Create a new TrakEM2 project file with "create_new_wafer_project.py".
3. Apply any affines created from any work done in MATLAB with "apply_affines.py".
4. Test block matching parameters by exporting your affine aligned tiles, then running "block_matching_loop.py".
5. Run elastic layer alignment as described on the TrakEM2 website with your desired parameters.

Authors
-------
* Talmo Periera
* Thomas Macrina

Contact
-------
Thomas Macrina, tmacrina at princeton edu
