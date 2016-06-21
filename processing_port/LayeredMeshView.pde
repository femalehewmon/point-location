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
