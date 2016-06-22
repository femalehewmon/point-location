class LayeredMeshView extends View {

	Mesh mesh;

	int numLayers = 0;
	HashMap<Integer, ArrayList<Polygon>> shapesByLayer;
	HashMap<Integer, color> colorsByLayer;
	boolean finalized = false;

	public LayeredMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
	}

	public void setMesh( Mesh mesh ) {
		this.mesh = mesh;
		this.finalized = false;
	}

	public void render() {
		if ( !this.finalized ) {
			finalizeView();
		}
		super.render(); // draw view background
	}

	private void finalizeView() {
		createKirkpatrickDataStructure();
		finalized = true;
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

	private void createKirkpatrickDataStructure() {
		ArrayList<Vertex> ildv = independentLowDegreeVertices();
		do {

			// For each ildv
			//	- find all triangles surrounding vertex
			//	- find convex hull of triangles surrounding vertex, triangulate
			//	- remove original triangles surrounding vertex from mesh
		    //	- add new triangles from convex hull to mesh	
			for ( int i = 0; i < ildv.size(); i++ ) {
				// Get faces (triangles) surrounding ildv
				ArrayList<Face> faces = mesh.facesOfVertex( ildv.get(i) );
				// Get the convex hull of the triangles surrounding the ildv
				Polygon convex_hull = 
					compGeoHelper.getConvexHull( mesh.verticesOfFaces(faces) ); 
				// Remove triangles surrounding ildv from mesh
				mesh.removeFacesFromMesh( faces );
				// Add convex hull triangulation to mesh
				mesh.addTrianglesToMesh( convex_hull.triangulate );
			}	

			// Get new ildv for next layer
			ildv = independentLowDegreeVertices();
			numLayers += 1;

		} while ( ildv.size() > 3 );

		// Mesh should now consist of only one triangle with 3 vertices
		if ( mesh.vertices.size() != 3 ) {
			console.log("WARNING: mesh is greater than 3 vertices"); 
		}



		finalized = true;
	}

	private void addShape(int layer, Polygon shape) {
		shapesByLayer[layer].add(shape);

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
