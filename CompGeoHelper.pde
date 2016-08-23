class CompGeoHelper {

	public CompGeoHelper() {}

	int unique_poly_id = 1;
	int poly_r_id = 1;
	int poly_g_id = 1;
	int poly_b_id = 1;

	Polygon createPoly() {
		unique_poly_id++;
		if ( poly_r_id < 255 ) {
			poly_r_id++;
		} else if ( poly_g_id < 255 ) {
			poly_g_id++;
		} else if ( poly_b_id < 255 ) {
			poly_b_id++;
		}
		return new Polygon(unique_poly_id,
				color(poly_r_id, poly_g_id, poly_b_id));
	}

	public LayeredMesh createKirkpatrickDataStructure(
			Polygon poly, Polygon outerTri ){
		poly = poly.copy();
		outerTri = outerTri.copy();
		if(DEBUG){
		console.log("Creating KP Data Structure");
		}
		int i, j;
		ArrayList<color> layerColors = new ArrayList<color>();
		layerColors.add(color(random(255), random(255), random(255)));

		// A LayeredMesh will serve as Kirkpatrick's Data Structure
		LayeredMesh mesh = new LayeredMesh( );
		int currLayer = mesh.createNewLayer();

		// triangulate the main polygon
		if(DEBUG){
		console.log("triangulate and add poly to kp");
		}
		mesh.addTrianglesToLayer( currLayer, poly.triangulate() );

		// triangulate holes between convex hull and polygon
		Polygon convexHull = getConvexHull( poly );
		ArrayList<Polygon> convexHullHoleTris =
			getPolygonsRemovedFromConvexHull(poly, convexHull, true);
		mesh.addTrianglesToLayer( currLayer, convexHullHoleTris );

		// triangulate the outer triangle with a hole in the middle for
		// the original polygon
		if(DEBUG){
		console.log("triangulate and add outer tri to kp");
		}
		outerTri.addHole( convexHull );
		mesh.addTrianglesToLayer( currLayer, outerTri.triangulate() );

		ArrayList<Vertex> ildv = independentLowDegreeVertices( mesh, outerTri );
		do {
			if(DEBUG){
			console.log("Found set of " + ildv.size() + " ILDV");
			}
			layerColors.add(color(random(255), random(255), random(255)));
			int currLayer = mesh.createNewLayer();
			for ( i = 0; i < ildv.size(); i++ ) {
				if(DEBUG){
				console.log("Processing ILDV: " + ildv.get(i).description);
				}
				// Get faces (triangles) surrounding ildv
				ArrayList<Face> faces = mesh.facesOfVertex( ildv.get(i) );
				// set colors of polygons removed on this layer
				for ( j = 0; j < faces.size(); j++ ) {
					if ( mesh.polygons.get(faces.get(j).id).parentId !=
							poly.id ){
						mesh.polygons.get(faces.get(j).id).cFill =
							layerColors.get(mesh.layers.size() - 1);
					} else {
						mesh.polygons.get(faces.get(j).id).cFill = poly.cFill;
					}
				}

				// Get the outer (not-convex) hull of the surrounding triangles
				ArrayList<Vertex> surrounding_vertices =
					mesh.verticesSurroundingVertex( ildv.get(i) );
				Polygon hull = createPoly();
				// set replacement hull as child id so that the layers
				// can be associated later during point location
				for ( j = 0; j < faces.size(); j++ ) {
					mesh.polygons.get(faces.get(j).id).childId = hull.id;
				}
				// create hull with points of soon-to-be-removed faces
				for( j = 0; j < surrounding_vertices.size(); j++ ) {
					hull.addPoint( surrounding_vertices.get(j).x,
							surrounding_vertices.get(j).y );
				}

				// Remove triangles surrounding ildv from mesh
				mesh.removeVertexFromLayer( currLayer, ildv.get(i) );
				mesh.removeFacesFromLayer( currLayer, faces );

				if ( hull != null ) {
					// Add convex hull triangulation to mesh
					mesh.addTrianglesToLayer( currLayer,
							hull.triangulate() );
				} else {
					console.log("WARNING! Hole hull was null");
				}

			}
			// Get new ildv for next layer
			ildv = independentLowDegreeVertices( mesh, outerTri );

		} while ( mesh.vertices.size() > 3 );

		// Mesh should now consist of only one triangle with 3 vertices
		if ( mesh.vertices.size() != 3 ) {
			console.log("WARNING: mesh is greater than 3 vertices");
		} else if ( mesh.faces.size() != 1 ) {
			console.log("WARNING: mesh has more than 1 face");
		}
		else {
			if(DEBUG){
			console.log("CONGRATULATIONS: mesh has only 3 vertices " +
					"and 1 face!");
			}
		}

		for ( j = 0; j < mesh.faces.size(); j++ ) {
			mesh.polygons.get(faces.get(j).id).cFill =
				layerColors.get(layerColors.size() - 1);
		}

		mesh.setLayerColors( layerColors );

		return mesh;
	}

	private ArrayList<Vertex> independentLowDegreeVertices(
			Mesh mesh, Polygon outerTri) {
		int i, j;
		ArrayList<Vertex> ildv = new ArrayList<Vertex>();
		ArrayList<Vertex> neighboringVertices = new ArrayList<Vertex>();
		ArrayList<Face> fov;
		ArrayList<Vertex> neighbors;
		for ( i = 0; i < mesh.vertices.size(); i++ ) {
			if ( !neighboringVertices.contains( mesh.vertices.get(i)) &&
					!outerTri.points.contains( mesh.vertices.get(i)) ) {
				fov = mesh.facesOfVertex( mesh.vertices.get(i) );
				if ( fov.size() < 7 ) {
					ildv.add( mesh.vertices.get(i) ); // add ildv to list
					neighbors =
						mesh.verticesSurroundingVertex(mesh.vertices.get(i));
					for ( j = 0; j < neighbors.size(); j++ ) {
						neighboringVertices.add( neighbors.get(j) );
					}
				}
			}
		}
		return ildv;
	}

	public ArrayList<Polygon> getPolygonsRemovedFromConvexHull(
			Polygon poly, Polygon convexHull, boolean triangulate ) {

		ArrayList<Polygon> holes = new ArrayList<Polygon>();
		Polygon hole;
		boolean foundHole = false;
		boolean firstHoleIncomplete = false;
		for( int i = 0; i < poly.points.size(); i++ ) {
			if ( !convexHull.points.contains(poly.points.get(i)) ) {
				if ( !foundHole ) {
					foundHole = true;
					hole = createPoly();
					if ( i > 0 ){
						hole.addPoint(
								poly.points.get(i - 1).x,
								poly.points.get(i - 1).y);
					} else {
						firstHoleIncomplete = true;
					}
				}
				hole.addPoint(
						poly.points.get(i).x,
						poly.points.get(i).y);
			} else {
				if ( foundHole ) {
					hole.addPoint(
							poly.points.get(i).x,
							poly.points.get(i).y);
					holes.add(hole);
					foundHole = false;
				}
			}
		}

		// first hold polygon should now be completed
		if ( firstHoleIncomplete ){
			if ( foundHole ) {
				// first point in the middle of an interior section
				// so add incomplete final hole to initial hole
				for ( int i = 0; i < hole.points.size(); i++ ) {
					holes.get(0).addPoint(
							hole.points.get(i).x,
							hole.points.get(i).y);
				}
			} else {
				// first point was the first point in interior section
				holes.get(0).addPoint(
						poly.points.get(poly.points.size() - 1).x,
						poly.points.get(poly.points.size() - 1).y);
			}
		} else {
			if ( foundHole ) {
				// hole was unfinished at end of polygon, which
			    // means that it wraps around to first point in the poly
				hole.addPoint(
						poly.points.get(0).x,
						poly.points.get(0).y);
				holes.add(hole);
			}
		}

		if ( triangulate ) {
			ArrayList<Polygon> convexHullHoleTris = new ArrayList<Polygon>();
			for ( i = 0; i < holes.size(); i++ ) {
				convexHullHoleTris.addAll( holes.get(i).triangulate() );
			}
			holes = convexHullHoleTris;
		}

		return holes;
	}

	public Polygon getConvexHull( Polygon poly ) {
		// Melkman's Convex Hull algorithm
		// see 1987 "On-line Construction of the Convex Hull of a
		// Simple Polyline" by A. Melkman for details
		//
		ArrayList<PolyPoint> deque = new ArrayList<PolyPoint>();
		if ( poly.points.size() <= 2 ) {
			console.log("WARNING: cannot get convex hull of < 3 point poly");
			return null;
		}

		// setup first three points
		PolyPoint v1 = poly.points.get(0);
		PolyPoint v2 = poly.points.get(1);
		PolyPoint v3 = poly.points.get(2);
		deque.add(v3);
		if ( rightTurn(v1, v2, v3) ) {
			deque.add(v2);
			deque.add(v1);
		} else {
			deque.add(v1);
			deque.add(v2);
		}
		deque.add(v3);

		PolyPoint v;
		int b = 0;
		int t = deque.size() - 1;
		for ( int i = 3; i < poly.points.size(); i++ ) {
			v = poly.points.get(i);
			if ( !leftTurn(deque.get(b), deque.get(b+1), v) ||
				 !leftTurn(deque.get(t-1), deque.get(t), v)) {
				while( !leftTurn(deque.get(t-1), deque.get(t), v)) {
					// pop d_t
					deque.remove(t);
					t -= 1;
				}
				// push v_i
				deque.add(v);
				t += 1;
				while( !leftTurn(v, deque.get(b), deque.get(b+1))) {
					// remove d_b
					deque.remove(0);
					t -= 1;
				}
				// insert v_i
				deque.add(0, v);
				t += 1;
			}
		}

		Polygon convexHull = createPoly();
		for( int j = 0; j < deque.size() - 1; j++ ) {
			convexHull.addPoint(deque.get(j).x, deque.get(j).y);
		}

		return convexHull;
	}

	public int rightTurn(PolyPoint v1, PolyPoint v2, PolyPoint v3){
		return rightCollinearOrLeft(v1,v2,v3) < 0;
	}
	public int leftTurn(PolyPoint v1, PolyPoint v2, PolyPoint v3){
		return rightCollinearOrLeft(v1,v2,v3) > 0;
	}
	private int rightCollinearOrLeft(PolyPoint a, PolyPoint b, PolyPoint c){
		// 1, left turn, counter-clockwise
		// 0,  collinear
		// -1,  right turn, clockwise
		int turn = (b.x-a.x)*(c.y-a.y)-(c.x-a.x)*(b.y-a.y);
		return turn;
	}

	boolean lineIntersectionCheck(
			PolyPoint p1, PolyPoint q1, PolyPoint p2, PolyPoint q2) {
	  float a1 = p1.y - q1.y;
	  float b1 = q1.x - p1.x;
	  float c1 = q1.x * p1.y - p1.x * q1.y;

	  float a2 = p2.y - q2.y;
	  float b2 = q2.x - p2.x;
	  float c2 = q2.x * p2.y - p2.x * q2.y;

	  float det = a1 * b2 - a2 * b1;

	  if ( (Math.round(det * 1000) / 1000) == 0) {
		return false;
	  } else {
		float isectx = (b2 * c1 - b1 * c2) / det;
		float isecty = (a1 * c2 - a2 * c1) / det;
		if ((isBetween(isecty, p1.y, q1.y) == true) &&
		  (isBetween(isecty, p2.y, q2.y) == true) &&
		  (isBetween(isectx, p1.x, q1.x) == true) &&
		  (isBetween(isectx, p2.x, q2.x) == true)) {
		  return true;
		}
	  }
	  return false;
	}

	boolean isBetween(float val, float range1, float range2) {
	  float largeNum = range1;
	  float smallNum = range2;
	  if (smallNum > largeNum) {
		largeNum = range2;
		smallNum = range1;
	  }
	  if ((val < largeNum) && (val > smallNum)) {
		return true;
	  }
	  return false;
	}

}
