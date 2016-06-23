class CompGeoHelper {

	public CompGeoHelper() {}

	public LayeredMesh createKirkpatrickDataStructure(
			Polygon poly, Polygon outerTri ){

		// A LayeredMesh will serve as Kirkpatrick's Data Structure
		LayeredMesh mesh = new LayeredMesh( );

		ArrayList<Polygon> base_triangles = poly.triangulate();
		mesh.addBaseTriangles( base_triangles );

		outerTri.addHole( poly );
		ArrayList<Polygon> outer_triangles = outerTri.triangulate();
		mesh.addTrianglesToLayer( 0, outer_triangles );

		ArrayList<Vertex> ildv = independentLowDegreeVertices( mesh );
		do {
			for ( int i = 0; i < ildv.size(); i++ ) {
				// Get faces (triangles) surrounding ildv
				ArrayList<Face> faces = mesh.facesOfVertex( ildv.get(i) );

				// Get the convex hull of the triangles surrounding the ildv
				Polygon convex_hull = 
					compGeoHelper.getConvexHull( mesh.verticesOfFaces(faces) ); 

				// Add convex hull triangulation to mesh
				mesh.addTrianglesToNextLayer( convex_hull.triangulate() );

				// Remove triangles surrounding ildv from mesh
				mesh.removeFacesFromMesh( faces );
			}	

			// Get new ildv for next layer
			ildv = independentLowDegreeVertices();

		} while ( ildv.size() > 3 );

		// Mesh should now consist of only one triangle with 3 vertices
		if ( mesh.vertices.size() != 3 ) {
			console.log("WARNING: mesh is greater than 3 vertices"); 
		}

		// TODO: add final triangle to mesh

		return mesh;
	}

	private ArrayList<Vertex> independentLowDegreeVertices() {
		ArrayList<Vertex> ildv = new ArrayList<Vertex>();
		ArrayList<Face> fov;
		for ( int i = 0; i < mesh.vertices.size; i++ ) {
			fov = mesh.facesOfVertex( mesh.vertices.get(i) );
			if ( fov.size() < 7 ) {
				ildv.add( mesh.vertices.get(i) ); // add ildv to list
			}
		}
		return ildv;
	}

	// Graham Scan!
	public Polygon getConvexHull( ArrayList<Vertex> vs ) {
		// *** ----------------------------------------------------- ***
		// NOTE: Mixing javascript into java... use caution if changing!
		// *** ----------------------------------------------------- ***
		int i;

		// convert input ArrayList to Javascript array
		var vertices = new Array();
		for ( i = 0; i < vs.size(); i++ ) {
			vertices.push(vs.get(i));
		}

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
			hullStack.push(vertices[ i ]);
			m += 1;
		}
		//console.log(hullStack);

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

}
