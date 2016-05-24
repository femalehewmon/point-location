class LayeredMeshView extends View {

	Mesh mesh;

	int numLayers;
	HashMap<Integer, ArrayList<Polygon>> shapes;
	HashMap<Integer, color> colorsByLayer;
	boolean finalized = false;


	public LayeredMeshView( ArrayList<Polygon> tris ) {
		super();
		this.shapesByLayer = new HashMap<Integer, ArrayList<Polygon>>();
		this.colorsByLayer = new HashMap<Integer, color>();
		for (int i = 0; i < numLayers; i++) {
			shapesByLayer[i] = new ArrayList<Polygon>();
			colorsByLayer[i] = color(random(255), random(255), random(255));
		}

		this.mesh = new Mesh();
		this.mesh.addTrianglesToMesh( tris );
	}

	private void createKirkpatrickDataStructure() {
		ArrayList<Vertex> ildv = independentLowDegreeVertices();
		do {
			for ( int i = 0; i < ildv.size(); i++ ) {


			}	
			ildv = independentLowDegreeVertices();
		} while ( ildv.size() > 3 );

		finalized = true;
	}

	ArrayList<Vertex> independentLowDegreeVertices() {
		ArrayList<Vertex> ildv = new ArrayList<Vertex>();
		for ( int i = 0; i < vertices.size; i++ ) {
			if ( edgesOfVertex( vertices.get(i) ).size() < 7 ) {
				ildv.add( vertices.get(i) ); // add ildv to list
			}
		}
		return ildv;
	}

	ArrayList<Edge> edgesSurroundingVertex( Vertex v ) {
		ArrayList<Edge> esv = new ArrayList<Edge>();

		ArrayList<Face> fov = facesOfVertex( v );
		Face curr_face;
		Edge curr_edge;
		ArrayList<Edge> curr_eof;
		for ( int i = 0; i < fov.size(); i++ ) {
			curr_face = fov.get(i);
			curr_eof = edgesOfFace( curr_face );
			// assume face has only 3 edges (TODO: validate)
			for ( int j = 0; j < 3; j++ ) {
				curr_edge = curr_eof.get(j);
				if ( !curr_edge.containsVertex(v) && !esv.contains(curr_edge) ) {
					esv.add( curr_edge );
				}
			}
		}
		return esv;
	}

	public void addShape(int layer, Polygon shape) {
		shapes[layer].add(shape);
		finalized = false;
	}

	public void render() {
		super.render(); // draw view background
		if (!finalized) {
			finalizeGraph();
		}
		// get list of selected polygons
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for (int i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		for (int i = 0; i < numLayers; i++) {
			// draw layer background
			fill(colorsByLayer[i]);
			rect(x1, h - (ydiv*(i+1)), w, ydiv);
			// draw layer shapes
			for (int j = 0; j < shapes[i].size(); j++) {
				if (selectedShapes.contains(shapes[i].get(j).id)) {
					shapes[i].get(j).selected = true;
				} else {
					shapes[i].get(j).selected = false;
				}
				shapes[i].get(j).render();
			}
		}
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
