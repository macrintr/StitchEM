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

Authors
-------
Talmo Periera

Thomas Macrina, tmacrina <at> princeton.edu

How to use
----------
The pipeline acts in two phases to align serial electron microscopy
images. It generates a "rough" affine alignment (using MATLAB), then
provides a final piecewise affine alignment (using TrakEM2 in FIJI).