class KirkpatrickMeshView extends View {

	KirkpatrickMesh mesh;
	int numLayers;

	Polygon polygon;
	Polygon outerTri;
	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	boolean drawPolygon;
	boolean drawPolygonTris;
	boolean drawOuterTri;
	boolean drawLayers;
	int layerToDraw;

	public KirkpatrickMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.numLayers = 0;

		this.mesh = null;
		this.polygon = null;
		// create outer triangle
		this.outerTri = createPoly();
		this.outerTri.cFill = color(255);
		// +10 to give a slight border
		this.outerTri.addPoint( xCenter, y1 + 10 );
		this.outerTri.addPoint( x2 - 10, y2 - 10 );
		this.outerTri.addPoint( x1 + 10, y2 - 10 );

		// ratio and position that the polygon will need to adjust to in order
	    // to fit in this view
		// values saved here and not directly applied for the sake of animation
		this.ratioToScalePoly = 1.0; // set when polygon is added to view
		this.xPosToMovePoly = this.xCenter;
		this.yPosToMovePoly = this.yCenter + (this.h / 4.0);

		this.layerToDraw = -3;
		this.finalized = false;
		setupLevel();
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		float wScale = (outerTri.getWidth() * 0.75 ) / polygon.getWidth();
		float hScale = (outerTri.getHeight() * 0.75 ) / polygon.getHeight();
		this.ratioToScalePoly = min(wScale, hScale);
	}

	public void setupLevel( int layerToDraw ) {
		switch( layerToDraw ) {
			case -3:
				// polygon only
				this.drawPolygon = true;
				this.drawPolygonTris = false;
				this.drawOuterTri = false;
				this.drawLayers = false;
				break;
			case -2:
				// polygon triangulated
				this.drawPolygon = false;
				this.drawPolygonTris = true;
				this.drawOuterTri = false;
				this.drawLayers = false;
				break;
			case -1:
				// polygon triangulated with outer tri
				this.drawPolygon = false;
				this.drawPolygonTris = true;
				this.drawOuterTri = true;
				this.drawLayers = false;
				break;
			case 0:
				// start of normal layer processing
				this.drawPolygon = false;
				this.drawPolygonTris = false;
				this.drawOuterTri = false;
				this.drawLayers = true;
				break;
		}
		console.log("level setup");
	}

	public boolean nextLevel() {
		if ( this.layerToDraw < this.mesh.layers.size() - 1 ) {
			// there are still layers to draw
			this.layerToDraw++;
			setupLevel( this.layerToDraw );
			console.log("ready to draw next level of mesh: "+this.layerToDraw);
			return true;
		}
		console.log("!!!!!!!!FINAL STATE OF MESH!!!!!!!!!!");
		console.log(this.mesh.vertices.size() + " vertices");
		for( int i = 0; i < this.mesh.vertices.size(); i++ ){
			console.log(this.mesh.vertices.get(i));
		}
		console.log(this.mesh.edges.size() + " edges");
		for( int i = 0; i < this.mesh.edges.size(); i++ ){
			console.log(this.mesh.edges.get(i));
		}
		console.log(this.mesh.faces.size() + " faces");
		for( int i = 0; i < this.mesh.faces.size(); i++ ){
			console.log(this.mesh.faces.get(i));
		}
		return false;
	}

	public void render( boolean drawHoles ) {
		//super.render(); // draw view background
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for (int i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		if ( drawPolygon ) {
			this.polygon.render();
		}
		if ( drawOuterTri ) {
			this.outerTri.render();
		}
		if ( drawPolygonTris ) {
			ArrayList<Polygon> polysToDraw = this.mesh.getPolygonsByLayer( 0 );
			for( int i; i < polysToDraw.size(); i++ ) {
				if ( polysToDraw.get(i).parentId == this.polygon.id ) {
					if ( selectedShapes.contains(polysToDraw.get(i).id) ) {
						polysToDraw.get(i).selected = true;
					} else {
						polysToDraw.get(i).selected = false;
					}
					polysToDraw.get(i).render(true);
				}
			}
		}
		if ( drawLayers ) {
			ArrayList<Polygon> polysToDraw =
				this.mesh.getPolygonsByLayer( this.layerToDraw );
			// draw requested layer
			for( int i; i < polysToDraw.size(); i++ ) {
				if ( selectedShapes.contains(polysToDraw.get(i).id) ) {
					polysToDraw.get(i).selected = true;
				} else {
					polysToDraw.get(i).selected = false;
				}
				polysToDraw.get(i).render(true);
			}
		}
	}

	public void render() {
		// draw polygon only by default
		render( false );
	}

	public void finalizeView() {
		this.mesh = compGeoHelper.createKirkpatrickDataStructure(
				this.polygon, this.outerTri);
		finalized = true;
	}

	public void mouseUpdate() {
		return; // TODO: renable
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		ArrayList<Polygon> polysToDraw =
			this.mesh.getPolygonsByLayer( this.layerToDraw );
		for( int i; i < polysToDraw.size(); i++ ) {
			if (color(polysToDraw.get(i).id) == c) {
				Message msg = new Message();
				msg.k = MSG_TRIANGLE;
				msg.v = polysToDraw.get(j).id;
				messages.add(msg);
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
