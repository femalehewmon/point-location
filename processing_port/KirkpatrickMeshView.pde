class KirkpatrickMeshView extends View {

	KirkpatrickMesh mesh;
	int numLayers;

	Polygon polygon;
	Polygon outerTri;
	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	boolean drawPolygon;
	boolean drawOuterTri;
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

		this.layerToDraw = -1;
		this.drawPolygon = true;
		this.drawOuterTri = false;
		this.finalized = false;
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		float wScale = (outerTri.getWidth() * 0.75 ) / polygon.getWidth();
		float hScale = (outerTri.getHeight() * 0.75 ) / polygon.getHeight();
		this.ratioToScalePoly = min(wScale, hScale);
	}

	public boolean nextLevel() {
		if ( this.layerToDraw < this.mesh.layers.size() - 1 ) {
			// there are still layers to draw
			this.layerToDraw++;
			return true;
		}
		return false;
	}

	public void render( boolean drawHoles ) {
		super.render(); // draw view background

		if ( layerToDraw < 0 ) {
			if ( drawOuterTri ) {
				this.outerTri.render();
			}
			if ( drawPolygon ) {
				this.polygon.render();
			}
		} else {
			int i;
			ArrayList<Polygon> polysToDraw =
				this.mesh.getPolygonsByLayer( layerToDraw );
			// draw requested layer
			for( i; i < polysToDraw.size(); i++ ) {
				polysToDraw.get(i).render();
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
		// TODO: re-enable!
		return;
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
