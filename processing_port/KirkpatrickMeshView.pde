class KirkpatrickMeshView extends View {

	KirkpatrickMesh mesh;

	Polygon polygon;
	Polygon outerTri;
	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	int layerToDraw;
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
		this.mesh = kpMesh;
	}

	public boolean nextLevel() {
		this.layerToDraw++;
		return this.layerToDraw < this.mesh.layers.size();
	}

	public ArrayList<Polygon> getPolygonTris() {
		ArrayList<Polygon> polygonTris = new ArrayList<Polygon>();
		ArrayList<Polygon> polys = this.mesh.getPolygonsByLayer( 0 );
		for( int i; i < polys.size(); i++ ) {
			if ( polys.get(i).parentId == this.polygon.id ) {
				polygonTris.add(polys.get(i));
			}
		}
		return polygonTris;
	}

	public ArrayList<Polygon> getOuterTris() {
		ArrayList<Polygon> outerTris = new ArrayList<Polygon>();
		ArrayList<Polygon> polys = this.mesh.getPolygonsByLayer( 0 );
		for( int i; i < polys.size(); i++ ) {
			if ( polys.get(i).parentId == this.outerTri.id ) {
				outerTris.add(polys.get(i));
			}
		}
		return outerTris;
	}

	public ArrayList<Polygon> getLayerTris() {
		return this.mesh.getPolygonsByLayer( this.layerToDraw );
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
			ArrayList<Polygon> polysToDraw = getPolygonTris();
			for( int i; i < polysToDraw.size(); i++ ) {
				if ( selectedShapes.contains(polysToDraw.get(i).id) ) {
					polysToDraw.get(i).selected = true;
				} else {
					polysToDraw.get(i).selected = false;
				}
				polysToDraw.get(i).render(true);
			}
		}
		if ( drawOuterTris ) {
			ArrayList<Polygon> polysToDraw = getOuterTris();
			for( int i; i < polysToDraw.size(); i++ ) {
				if ( selectedShapes.contains(polysToDraw.get(i).id) ) {
					polysToDraw.get(i).selected = true;
				} else {
					polysToDraw.get(i).selected = false;
				}
				polysToDraw.get(i).render(true);
			}
		}
		if ( drawLayers ) {
			ArrayList<Polygon> polysToDraw = getLayerTris( this.layerToDraw );
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
