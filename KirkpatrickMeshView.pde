class KirkpatrickMeshView extends View {

	LayeredMesh mesh;

	Polygon polygon;
	Polygon outerTri;

	ArrayList<Polygon> polygonsToDraw;
	ArrayList<Vertex> verticesToDraw;
	PolyPoint ildvToDraw;

	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	int layerToDraw;
	int subLayerToDraw;
	boolean layerInitialized;
	boolean drawOuterTriangle;
	boolean drawPolygon;

	public KirkpatrickMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.layerToDraw = 0;
		this.subLayerToDraw = 0;
		this.layerInitialized = false;
		this.drawOuterTriangle = false;
		this.drawPolygon = true;

		this.mesh = null;
		this.polygon = null;
		// create outer triangle
		this.outerTri = compGeoHelper.createPoly();
		this.outerTri.cHighlight = color(255);
		this.outerTri.cFill = color(200, 200, 200);
		// +10 to give a slight border
		this.outerTri.addPoint( xCenter, y1 + 10 );
		this.outerTri.addPoint( x2 - 10, y2 - 10 );
		this.outerTri.addPoint( x1 + 10, y2 - 10 );

		this.polygonTris = new ArrayList<Integer>();
		this.polygonsToDraw = new ArrayList<Polygon>();
		this.verticesToDraw = new ArrayList<Vertex>();
		this.ildvToDraw = null;

		// ratio and position that the polygon will need to adjust to in order
	    // to fit in this view
		// values saved here and not directly applied for the sake of animation
		this.ratioToScalePoly = 1.0; // set when polygon is added to view
		this.xPosToMovePoly = this.outerTri.getCenter().x;
		this.yPosToMovePoly = this.outerTri.getCenter().y;// + (this.h / 8.0);

		this.finalized = false;
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		// calculate amount to scale -- better way to do this?
		// inner polygon should be able to be misshapen, so can't
		// generalize entire width to specific scale
		float totalScale = 1.0;
		Polygon tmp = this.polygon.copy();
		tmp.move( xPosToMovePoly, yPosToMovePoly );
		while( !this.outerTri.containsPolygon( tmp ) ){
			tmp.scale( 0.90 );
			totalScale *= 0.90;
		}
		this.ratioToScalePoly = totalScale;
	}

	public void setMesh( LayeredMesh mesh ) {
		int i, j, k, l;
		// clear previously set mesh
		this.polygonsToDraw.clear();
		this.verticesToDraw.clear();
		this.ildvToDraw = null;
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();

		// set polygon and outer triangle tris
		Iterator<Integer> iterator = mesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( mesh.polygons.get(polyId).parentId == polygon.id ) {
				this.polygonTris.add(polyId);
			}
		}
	}

	public void displayOuterTriangle() {
		this.drawOuterTriangle = true;
		this.drawPolygon = false;
		this.outerTri.selected = true;
	}

	public void resetDisplay() {
		subLayerToDraw = 0;
		layerToDraw = 0;
		polygonsToDraw.clear();
		layerInitialized = false;
		drawOuterTriangle = false;
		outerTri.selected = false;
	}

	private boolean nextLevel() {
		if (subLayerToDraw >= mesh.layers.get(layerToDraw).subLayers.size()-1){
			subLayerToDraw = 0;
			layerToDraw++;
			layerInitialized = false;
		} else {
			subLayerToDraw++;
		}
		return ( layerToDraw <= mesh.layers.size() - 1 );
	}

	public boolean update() {
		int i;
		// Visualization progression:
		// - If first subLayer in layer, draw all previously visible polygons
		// and all ILDV to be removed in this layer (not highlighted)
		// - Draw sublayer with current ildv to be removed highlighted
		// - Draw sublayer with polygons attached to ildv removed (has hole)
		// - Draw sublayer with polygons created to fill hole
		// Repeat
		// This progression is made easier because layeredMesh was built
		// so that each step, except the first, is on a different subLayer

		if ( !layerInitialized ) {
			// add all ildv vertices to be removed on this layer
			layerInitialized = true;
			// outerTri's selected color (dark gray) used to show hole
			outerTri.selected = false;

			// verticesToDraw should be empty, verify
			if ( verticesToDraw.size() > 0 ) {
				console.log( "WARNING: vertices to draw should be empty " +
						"on first subLayer");
			}
			verticesToDraw.clear();

			ArrayList<Vertex> verticesRemoved =
				mesh.layers.get( layerToDraw ).getVerticesRemovedFromLayer();
			for( i = 0; i < verticesRemoved.size(); i++ ) {
				PolyPoint ildv = new PolyPoint(
							verticesRemoved.get(i).x,
							verticesRemoved.get(i).y);
				ildv.size = 20;
				ildv.cFill = color(0);
				verticesToDraw.add( ildv );
			}
			return true;
		} else {
			ildvToDraw = null;
			MeshLayer subLayer =
				mesh.layers.get( layerToDraw ).subLayers.get( subLayerToDraw );
			// get list of polygons added and removed from current layer
			// Should be either a list of added or removed,
			// but check for and handle both
			if ( subLayer != null ) {
				polysAdded = subLayer.getPolygonsAddedToLayer();
				polysRemoved = subLayer.getPolygonsRemovedFromLayer();
				verticesRemoved = subLayer.getVerticesRemovedFromLayer();

				if ( verticesRemoved.size() > 0 ) {
					for ( i = 0; i < verticesRemoved.size(); i++ ) {
						Vertex ildv = verticesRemoved.get(i);
						if ( verticesToDraw.contains( ildv ) ) {
							ildvToDraw = verticesToDraw.get(
									verticesToDraw.indexOf(ildv));
							verticesToDraw.remove(ildvToDraw);
						}
					}
				}

				if ( polysRemoved.size() > 0 ) {
					for ( i = 0; i < polysRemoved.size(); i++ ) {
						polygonsToDraw.remove(
								polygonsToDraw.indexOf(
									mesh.polygons.get(polysRemoved.get(i))));
					}
				}

				if ( polysAdded.size() > 0 ) {
					for ( i = 0; i < polysAdded.size(); i++ ) {
						polygonsToDraw.add( mesh.polygons.get(polysAdded.get(i)) );
					}
				}
			}

			return nextLevel();
		}
	}

	public void render() {
		int i, j;

		// select triangle under mouse hover
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		if( drawOuterTriangle ) {
			outerTri.render();
		}
		if ( drawPolygon ) {
			polygon.render();
		}

		// draw polygons
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			// reverse highlight so triangles are white by default
			// highlight triangle with color if it:
			//  - belongs to the original polygon
			//  - is connected to the currently highlighted ILDV
			//  - is selected by the user by mouse hover
			if ( polygonsToDraw.get(i).parentId == polygon.id ||
					( ildvToDraw != null &&
					polygonsToDraw.get(i).points.contains(ildvToDraw)) ||
					selectedShapes.contains(polygonsToDraw.get(i).id) ) {
				polygonsToDraw.get(i).selected = false;
			} else {
				polygonsToDraw.get(i).selected = true;
			}
			polygonsToDraw.get(i).render(false);
		}

		// draw vertices
		for( i = 0; i < verticesToDraw.size(); i++ ) {
			verticesToDraw.get(i).render();
		}

		// draw ildv vertex
		if( ildvToDraw != null ) {
			ildvToDraw.selected = true;
			ildvToDraw.render();
		}

	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		if ( layerToDraw < this.mesh.layers.size() ) {
			for( int i; i < polygonsToDraw.size(); i++ ) {
				if (color(polygonsToDraw.get(i)) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = polygonsToDraw.get(i);
					messages.add(msg);
				}
			}
		}
	}

}
