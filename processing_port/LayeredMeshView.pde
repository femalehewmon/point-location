class LayeredMeshView extends View {

	Polygon poly;

	int numLayers = 0;
	HashMap<Integer, ArrayList<Polygon>> shapesByLayer;
	HashMap<Integer, color> colorsByLayer;
	boolean finalized = false;

	public LayeredMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.finalized = false;
	}

	public void setPolygon( Polygon poly ) {
		this.poly = poly;
		this.finalized = false;
	}

	public void render() {
		if ( !this.finalized ) {
			finalizeView();
		}
		super.render(); // draw view background
	}

	private void addShape(int layer, Polygon shape) {
		shapesByLayer[layer].add(shape);
	}

	private void addShapes(int layer, ArrayList<Polygon> shapes) {
		for ( int = 0; i < shapes.size(); i++ ) {
			addShape( layer, shapes.get(i) );
		}
	}

	private void finalizeView() {
		this.shapesByLayer.clear();
		this.colorsByLayer.clear();
		numLayers = 0;

		LayeredMesh mesh = 
			compGeoHelper.createKirkpatrickDataStructure( this.poly );
		for( int i = 0; i < mesh.layers.size(); i++ ) {
			for ( int j = 0; j < mesh.layers[i].size(); j++ ) {
				addShapes( i, mesh.layers[i] );
			}
		}
		finalized = true;
	}

	public void mouseUpdate() {
		// TODO: re-enable!
		return;
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		for (i = 0; i < numLayers; i++) {
			for (j = 0; j < shapesByLayer[i].size(); j++) {
				if (color(shapesByLayer[i].get(j).id) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = shapesByLayer[i].get(j).id;
					messages.add(msg);
				}
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
