StitchEM
========
A set of tools for serial electron microscopy image registration.

Requirements
------------
* MATLAB 2013
* FIJI (ImgeJ 1.49p)
* TrakEM2 FIJI plugin (1.0a 2012-07-04)

License
-------
Released under the latest General Public License.

How to use
----------
The pipeline acts in two phases to align serial electron microscopy
images. It generates a "rough" affine alignment (using feature matching
in MATLAB), then provides a final piecewise affine alignment (using 
cross correlation with TrakEM2 in FIJI).

Authors
-------
* Talmo Periera
* Thomas Macrina

Contact
-------
Thomas Macrina, tmacrina at princeton edu