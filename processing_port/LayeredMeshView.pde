class LayeredMeshView extends View {

	Mesh mesh;
	boolean finalized = false;

	int numLayers = 0;

	public LayeredMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
	}

	public void setMesh( Mesh mesh ) {
		this.mesh = mesh;
		this.finalized = false;
	}

	// Graham Scan!
	Polygon getConvexHull( ArrayList<Vertex> vs ) {
		int i, j;
		var vertices = new Array();

		// Find point with lowest coordinate, O(n) 
		vertices.push(vs.get(0));
		Vertex p = vertices[0];
		for ( i = 1; i < vs.size(); i++ ) {
			vertices.push(vs.get(i));
			if (vertices[i].y > p.y ) {
				p = vertices[i];
			} else if ( vertices[i].y == p.y ) {
				// if tie, use point with lowest x-coordinate
				if ( vertices[i].x < p.x ) {
					p = vertices[i];
				}
			}
		}

		console.log(p);

		// *** ----------------------------------------------------- ***
		// NOTE: Mixing javascript into java... use caution if changing!
		// *** ----------------------------------------------------- ***
		// Calculate angle between all points and p
		for ( i = 0; i < vertices.length; i++ ) {
			// use dot product to get cos(THETA), which can be 
			// subbed for the angle for this purpose
			vertices[i].angle = 
					(vertices[i].x * p.x) + (vertices[i].y * p.y);
			vertices[i].angle /= (vertices[i].getLength() * p.getLength());
			console.log(vertices[i].angle);
		}

		// Sort points in increasing order of angle with point p on x-axis
		// O( nlogn )
		vertices.sort(
				function(x, y) {
					return x.angle > y.angle;
				}
		);
		// *** ----------------------------------------------------- ***

		// Keep points that make left turns
		int n = vertices.length;	// number of points
		int m = 1;					// number of hull points

		Stack<Vertex> hullPoints = new Stack<Vertex>();
		hullPoints.push(points.get(0));

		hullPoints.add(vertices[0]);
		for ( i = 2; i < vertices.length; i++ ) {
			// while current 3 points don't make a left turn, pop the last point
			while (orientation(
						vertices[ m - 1 ], 
						vertices[ m ], 
						vertices[ i ]) <= 0) {
				if ( m > 1 ) {
					m -= 1;
				} else if ( i == vertices.length ) {
					break; // all points are co-linear
				} else {
					i += 1;
				}	
			}

			m += 1;
			Vertex swap = vertices[i];
			vertices.set(i, vertices[m]);
			vertices.set(m, swap);
		}

		Polygon chull = createPoly();
		for ( i = 0; i < hullPoints.length; i++ ) {
			chull.addPoint(hullPoints.get(i).x, hullPoints.get(i).y);
		}

		return chull;
	}

	private int orientation( Vertex v1, Vertex v2, Vertex v3 ) {
		// -1 = right turn
		//  0 = co-linear
		//  1 = left turn
		float value = (v2.x - v1.x)*(v3.y - v1.y) - (v2.y - v1.y)*(v3.x - v1.x);
		if ( value == 0 ) {
			return 0;
		}
		return value < 0 ? -1 : 1;
	}

	private void createKirkpatrickDataStructure() {
		ArrayList<Vertex> ildv = independentLowDegreeVertices();
		do {
			for ( int i = 0; i < ildv.size(); i++ ) {
				ArrayList<Edge> esv = mesh.edgesSurroundingVertex(ildv.get(i));
			}	

			// Get list of all vertices in face list to pass to getConvexHull
			ArrayList<Vertex> vertices = new ArrayList<Vertex>();
			for ( i = 0; i < faces.size(); i++ ) {
				ArrayList<Vertex> vof = mesh.verticesOfFace( faces.get(i) );
				for ( j = 0; j < vof.size(); j++ ) {
					if ( !vertices.contains( vof.get(j) ) ) {
						vertices.add( vof.get(j) );
					}
				}
			}

			ildv = independentLowDegreeVertices();
		} while ( ildv.size() > 3 );

		finalized = true;
	}

	ArrayList<Vertex> independentLowDegreeVertices() {
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

	private void finalizeLayeredMesh() {
		createKirkpatrickDataStructure();
	}

	public void render() {
		if ( !this.finalized ) {
			//finalizeLayeredMesh();
			this.finalized = true;
		}
		super.render(); // draw view background
	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		for (i = 0; i < numLayers; i++) {
			for (j = 0; j < shapes[i].size(); j++) {
				if (color(shapes[i].get(j).id) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = shapes[i].get(j).id;
					messages.add(msg);
				}
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
