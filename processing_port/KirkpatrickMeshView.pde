class KirkpatrickMeshView extends View {

	LayeredMesh mesh;

	Polygon polygon;
	Polygon outerTri;
	ArrayList<Polygon> polygonTris;
	ArrayList<Polygon> outerTris;
	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	int layerToDraw;
	int subLayerToDraw;
	boolean drawPoly;
	boolean drawPolyTris;
	boolean drawOuterTri;
	boolean drawOuterTris;
	boolean drawLayers;

	public KirkpatrickMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.layerToDraw = 0;

		this.mesh = null;
		this.polygon = null;
		// create outer triangle
		this.outerTri = createPoly();
		this.outerTri.cFill = color(255);
		// +10 to give a slight border
		this.outerTri.addPoint( xCenter, y1 + 10 );
		this.outerTri.addPoint( x2 - 10, y2 - 10 );
		this.outerTri.addPoint( x1 + 10, y2 - 10 );

		this.polygonTris = new ArrayList<Polygon>();
		this.outerTris = new ArrayList<Polygon>();
		// a little crazy, but designed to hold sublayers.. a better way?
		this.subLayerTrisAdded = new ArrayList<ArrayList<ArrayList<Polygon>>>();
		this.subLayerTrisRemoved = new ArrayList<ArrayList<ArrayList<Polygon>>>();

		// ratio and position that the polygon will need to adjust to in order
	    // to fit in this view
		// values saved here and not directly applied for the sake of animation
		this.ratioToScalePoly = 1.0; // set when polygon is added to view
		this.xPosToMovePoly = this.xCenter;
		this.yPosToMovePoly = this.yCenter + (this.h / 4.0);

		this.finalized = false;
		this.drawPoly = false;
		this.drawPolyTris = false;
		this.drawOuterTri = false;
		this.drawOuterTris = false;
		this.drawLayers = false;
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		float wScale = (outerTri.getWidth() * 0.75 ) / polygon.getWidth();
		float hScale = (outerTri.getHeight() * 0.75 ) / polygon.getHeight();
		this.ratioToScalePoly = min(wScale, hScale);
	}

	public void setMesh( LayeredMesh mesh ) {
		int i;
		console.log("setting mesh in kpview");
		this.outerTris.clear();
		this.polygonTris.clear();
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh;
		ArrayList<Polygon> polys = this.mesh.getVisiblePolygonsByLayer( 0 );
		for( i = 0; i < polys.size(); i++ ) {
			if ( polys.get(i).parentId == this.polygon.id ) {
				this.polygonTris.add(polys.get(i));
			} else if ( polys.get(i).parentId == this.outerTri.id ) {
				this.outerTris.add(polys.get(i));
			}
		}

		for( i = 0; i < this.mesh.layers.size(); i++ ) {

		}
	}

	public boolean nextLevel() {
		this.layerToDraw++;
		return this.layerToDraw < this.mesh.layers.size();
	}

	public void render( boolean drawHoles ) {
		//super.render(); // draw view background
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for (int i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		if ( drawPoly ) {
			this.polygon.render();
		}
		if ( drawOuterTri ) {
			this.outerTri.render();
		}
		if ( drawPolyTris ) {
			for( int i; i < this.polygonTris.size(); i++ ) {
				if ( selectedShapes.contains(this.polygonTris.get(i).id) ) {
					this.polygonTris.get(i).selected = true;
				} else {
					this.polygonTris.get(i).selected = false;
				}
				this.polygonTris.get(i).render(true);
			}
		}
		if ( drawOuterTris ) {
			for( int i; i < this.outerTris.size(); i++ ) {
				if ( selectedShapes.contains(this.outerTris.get(i).id) ) {
					this.outerTris.get(i).selected = true;
				} else {
					this.outerTris.get(i).selected = false;
				}
				this.outerTris.get(i).render(true);
			}
		}
		if ( drawLayers ) {
			ArrayList<Polygon> polysToDraw = getLayerTris( this.layerToDraw );
			// draw requested layer
			for( int i; i < this.layerTris.get(this.layerToDraw).size(); i++ ) {
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
