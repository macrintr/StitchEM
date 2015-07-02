# Thomas Macrina

# Reimplementing the elastic layer aligner from TrakEM2
# Based on source code:
# https://github.com/trakem2/TrakEM2/blob/master/TrakEM2_/src/main/java/mpicbg/trakem2/align/ElasticLayerAlignment.java

import os

import ij.IJ;
import ij.gui.GenericDialog;
import ini.trakem2.Project;
import ini.trakem2.display.Layer;
import ini.trakem2.display.LayerSet;
import ini.trakem2.display.Patch;
import ini.trakem2.display.VectorData;
import ini.trakem2.parallel.ExecutorProvider;
import ini.trakem2.utils.AreaUtils;
import ini.trakem2.utils.Filter;
import ini.trakem2.utils.Utils;

import java.awt.Rectangle;
import java.awt.geom.Area;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;

import mpicbg.imagefeatures.Feature;
import mpicbg.imagefeatures.FloatArray2DSIFT;
import mpicbg.models.AbstractModel;
import mpicbg.models.AffineModel2D;
import mpicbg.models.HomographyModel2D;
import mpicbg.models.NotEnoughDataPointsException;
import mpicbg.models.Point;
import mpicbg.models.PointMatch;
import mpicbg.models.RigidModel2D;
import mpicbg.models.SimilarityModel2D;
import mpicbg.models.Spring;
import mpicbg.models.SpringMesh;
import mpicbg.models.Tile;
import mpicbg.models.TileConfiguration;
import mpicbg.models.Transforms;
import mpicbg.models.TranslationModel2D;
import mpicbg.models.Vertex;
import mpicbg.trakem2.align.concurrent.BlockMatchPairCallable;
import mpicbg.trakem2.transform.MovingLeastSquaresTransform2;
import mpicbg.trakem2.util.Triple;

def adjust_mesh_from_correspondences_file(filename, mesh, spring_constant):
	if os.path.isfile(filename):
		pts_file = open(filename)
		pts_reader = csv.reader(pts_file, delimiter='\t')
		for row in pts_reader:
			p1 = Vertex([row[0]], [row[1]])
			p2 = Vertex([row[2]], [row[3]])
			p1.addSpring(p2, Spring(0, spring_constant))
			mesh.addPassiveVertex(p2)
	 	pts_reader.close()