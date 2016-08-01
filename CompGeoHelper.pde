class CompGeoHelper {

	public CompGeoHelper() {}

	Polygon createPoly() {
		unique_poly_id++;
		return new Polygon(unique_poly_id);
	}

	public LayeredMesh createKirkpatrickDataStructure(
			Polygon poly, Polygon outerTri ){
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

		// triangulate the outer triangle with a hole in the middle for
		// the original polygon
		if(DEBUG){
		console.log("triangulate and add outer tri to kp");
		}
		outerTri.addHole( poly );
		//outerTri.cFill = layerColors.get( layerColors.size() - 1 );
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
			// create new layer to force a frame on the final full triangle
			//int currLayer = mesh.createNewLayer();
			//mesh.removeFacesFromLayer(
		//			currLayer, new ArrayList<Face>(mesh.faces));
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

	// Graham Scan!
	public Polygon getConvexHull( ArrayList<Vertex> vs ) {
		console.log(vs.size());
		for ( int i = 0; i < vs.size(); i++ ) {
			console.log(vs.get(i));
		}
		if ( vs.size() <= 2 ) {
			console.log("ERROR: Cannot create convex hull of < 3 vertices!");
			return null;
		}
		// *** ----------------------------------------------------- ***
		// NOTE: Mixing javascript into java... use caution if changing!
		// *** ----------------------------------------------------- ***
		int i;

		// convert input ArrayList to Javascript array
		var vertices = new Array();
		for ( i = 0; i < vs.size(); i++ ) {
			vertices.push(vs.get(i));
		}
		console.log(vs);
		console.log(vertices);

		Vertex p = getLowestPoint( vertices );
		vertices = sortByRadialAngle( p, vertices );

		// Remove and re-add lowest point from list to ensure that it is the
		// first element in the list of vertices
		vertices.splice(vertices.indexOf(p),1);
		vertices.unshift(p);

		// Keep points that make left turns
		int n = vertices.length;	// number of points
		int m = 1;					// number of hull points

		//Stack<Vertex> hullStack = new Stack<Vertex>();
		var hullStack = [];

		// lowest point and next sort point are guaranteed to be on the hull
		hullStack.push(vertices[0]);
		hullStack.push(vertices[1]);

		for ( i = 2; i < vertices.length; i++ ) {
			// while current 3 points don't make left turn, pop the last point
			//console.log("orientation of " + (m - 1) + " " + m + " " + i);
			while (orientation(
						hullStack[ m - 1 ],
						hullStack[ m ],
						vertices[ i ]) <= 0) {
				//console.log("inner orientation of " + (m - 1) + " " + m + " " + i);
				if ( m > 1 ) {
					// pop last point from stack, not on the CH
					//console.log("pop last added point from stack");
					m -= 1;
					hullStack.pop();
				} else {
					if ( i == vertices.length ) {
						//console.log("all points are collinear");
						break; // all points are collinear
					}
					//console.log("go to next point");
					i += 1;
				}
			}

			// left turn found, push points of last turn onto stack
			//console.log("push vertex " + i);
			hullStack.push(vertices[i]);
			m += 1;
		}
		console.log(hullStack);

		Polygon chull = createPoly();
		for ( i = 0; i <= m; i++ ) {
			chull.addPoint(hullStack[i].x, hullStack[i].y);
		}

		return chull;
	}

	private var sortByRadialAngle( Vertex p, var vertices ) {
		// Calculate angle between all points and p
		for ( i = 0; i < vertices.length; i++ ) {
			// use dot product to get cos(THETA), which can be
			// subbed for the angle for this purpose
			//vertices[i].angle =
			//		(vertices[i].x * p.x) + (vertices[i].y * p.y);
			//vertices[i].angle /= (vertices[i].getLength() * p.getLength());
			vertices[i].angle =
				Math.atan2(vertices[i].y - p.y, vertices[i].x - p.x);
		}

		// Sort points in increasing order of angle with point p on x-axis
		// O( nlogn )
		vertices.sort(
				function(x, y) {
					if ( x.angle == y.angle ) {
						return x.getDistance(p) < y.getLength(p);
					} else {
						return x.angle < y.angle;
					}
				}
		);

		return vertices;
	}

	private Vertex getLowestPoint( var vertices ) {
		// Find point with lowest coordinate, O(n)
		Vertex p = vertices[0];
		for ( i = 0; i < vertices.length; i++ ) {
			if (vertices[i].y > p.y ) {
				p = vertices[i];
			} else if ( vertices[i].y == p.y ) {
				// if tie, use point with lowest x-coordinate
				if ( vertices[i].x < p.x ) {
					p = vertices[i];
				}
			}
		}
		return p;
	}

	private int orientation( Vertex v1, Vertex v2, Vertex v3 ) {
		// -1 = right turn
		//  0 = co-linear
		//  1 = left turn
		float value = ((v2.x - v1.x)*(v3.y - v1.y)) -
				      ((v2.y - v1.y)*(v3.x - v1.x));
		if ( value == 0 ) {
			return 0;
		}
		// typically this should be 0 ? 1 : 1
		// but because we are working with processing, the space is inverted
		// such that (0,0) is in the top left, and (1,1) is bottom right
		return value > 0 ? -1 : 1;
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
