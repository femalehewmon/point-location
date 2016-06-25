class LayeredMeshView extends View {

	LayeredMesh mesh;

	Polygon polygon;
	Polygon outerTri;
	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	int numLayers = 0;
	HashMap<Integer, ArrayList<Polygon>> shapesByLayer;
	HashMap<Integer, color> colorsByLayer;
	boolean finalized = false;

	boolean drawPolygn = true;
	boolean drawOuterTri = false;

	public LayeredMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.cFill = color(255);
		this.finalized = false;
		this.mesh = null;

		this.polygon = null;
		// ratio and position that the polygon will need to adjust to in order
	    // to fit in this view
		// values saved here and not directly applied for the sake of animation
		this.ratioToScalePoly = 1.0; // set when polygon is added to view
		this.xPosToMovePoly = this.xCenter;
		this.yPosToMovePoly = this.yCenter + (this.h / 4.0);

		// create outer triangle
		this.outerTri = createPoly();
		this.outerTri.cFill = color(255);
		// +10 to give a slight border
		this.outerTri.addPoint( xCenter, y1 + 10 );
		this.outerTri.addPoint( x2 - 10, y2 - 10 );
		this.outerTri.addPoint( x1 + 10, y2 - 10 );
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		float wScale = (outerTri.getWidth() * 0.75 ) / polygon.getWidth();
		float hScale = (outerTri.getHeight() * 0.75 ) / polygon.getHeight();
		this.ratioToScalePoly = min(wScale, hScale);
		finalizeView();
	}

	public void render( int layerToDraw, boolean drawHoles ) {
		//super.render(); // draw view background
		//if ( !this.finalized ) {
		//		finalizeView();
		//	}

		if ( layerToDraw < 0 ) {
			if ( drawOuterTri ) {
				this.outerTri.render();
			}
			if ( drawPolygon ) {
				this.polygon.render();
			}
		} else {

		}
	}

	public void render() {
		// draw polygon only by default
		render( -1, false );
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

		this.mesh = compGeoHelper.createKirkpatrickDataStructure(
				this.polygon, this.outerTri);

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
