class KirkpatrickMeshView extends View {

	LayeredMesh mesh;

	Polygon polygon;
	Polygon outerTri;
	ArrayList<Integer> polygonTris;
	ArrayList<ArrayList<Integer>> layerTris;
	ArrayList<ArrayList<PolyPoint>> layerVertices;

	float ratioToScalePoly;
	float xPosToMovePoly;
	float yPosToMovePoly;

	int layerToDraw;
	boolean drawPoly;
	boolean drawPolyTris;
	boolean drawOuterTri;
	boolean drawLayers;

	public KirkpatrickMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.layerToDraw = 0;

		this.mesh = null;
		this.polygon = null;
		// create outer triangle
		this.outerTri = createPoly();
		//this.outerTri.cFill = color(100, 100, 100);
		// +10 to give a slight border
		this.outerTri.addPoint( xCenter, y1 + 10 );
		this.outerTri.addPoint( x2 - 10, y2 - 10 );
		this.outerTri.addPoint( x1 + 10, y2 - 10 );

		this.polygonTris = new ArrayList<Integer>();
		this.outerTris = new ArrayList<Integer>();
		this.layerTris = new ArrayList<ArrayList<Integer>>();
		this.layerVertices = new ArrayList<ArrayList<PolyPoint>>();

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
		this.drawLayers = false;
	}

	public void setPolygon( Polygon polygon ) {
		this.polygon = polygon;
		float wScale = (outerTri.getWidth() * 0.50 ) / polygon.getWidth();
		float hScale = (outerTri.getHeight() * 0.50 ) / polygon.getHeight();
		this.ratioToScalePoly = min(wScale, hScale);
	}

	public void setMesh( LayeredMesh mesh ) {
		int i, j, k, l;
		// clear previously set mesh
		this.outerTris.clear();
		this.polygonTris.clear();
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.layerTris.add( new ArrayList<Integer>() );
		this.layerVertices.add( new ArrayList<PolyPoint>() );

		// set polygon and outer triangle tris
		Iterator<Integer> iterator = mesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( mesh.polygons.get(polyId).parentId == polygon.id ) {
				this.polygonTris.add(polyId);
				this.layerTris.get(0).add( polyId );
			} else if ( mesh.polygons.get(polyId).parentId == outerTri.id ) {
				this.layerTris.get(0).add( polyId );
			}
		}

		flattenMesh();
	}

	private void flattenMesh() {
		// set per layer tris, split into sublayers
		ArrayList<MeshLayer> subLayers;
		ArrayList<Integer> polysAdded;
		ArrayList<Integer> polysRemoved;
		ArrayList<Vertex> verticesRemoved;
		for( i = 1; i < this.mesh.layers.size(); i++ ) {
			subLayers = mesh.layers.get(i).subLayers;
			// add buffer layers for frame with all ildv in layer marked
			this.layerTris.add(new ArrayList<Integer>(
						layerTris.get( layerTris.size() - 1 )));
			this.layerVertices.add(new ArrayList<PolyPoint>( ));
			for( j = 0; j < subLayers.size(); j++ ) {

				// initialize new layer with same polygons as last layer
				this.layerTris.add(new ArrayList<Integer>(
							layerTris.get( layerTris.size() - 1 )));
				// initialize new layer with same vertices as last layer
				//this.layerVertices.add(new ArrayList<PolyPoint>(
			    //			layerVertices.get(layerVertices.size() - 1)));
				this.layerVertices.add(new ArrayList<PolyPoint>( ));

				// get list of polygons added and removed from current layer
				// for KP data structure, should be either a list of added
				// or removed, but check for and handle both
				polysAdded = subLayers.get(j).getPolygonsAddedToLayer();
				polysRemoved = subLayers.get(j).getPolygonsRemovedFromLayer();
				verticesRemoved = subLayers.get(j).getVerticesRemovedFromLayer();
				for ( k = 0; k < verticesRemoved.size(); k++ ) {
					PolyPoint ildv = new PolyPoint(
							verticesRemoved.get(k).x,
							verticesRemoved.get(k).y);
					ildv.size = 20;
					ildv.cFill = color(0);
					this.layerVertices.get(layerVertices.size() - 1).add(ildv);
					// add this vertex to all previous subLayers before
					// the current subLayer since it is to be removed in
					// the next layer
					for ( l = 0; l <= j ; l++ ) {
						ildv = ildv.copy();
						ildv.size = 20;
						ildv.cFill = color(255);
						this.layerVertices.get(layerVertices.size() - l - 2).add(
								ildv);
					}
				}
				for ( k = 0; k < polysRemoved.size(); k++ ) {
					this.layerTris.get( layerTris.size() - 1 ).remove(
							this.layerTris.get( layerTris.size() - 1).indexOf(
								polysRemoved.get(k)) );
				}
				for ( k = 0; k < polysAdded.size(); k++ ) {
					this.layerTris.get( layerTris.size() - 1 ).add(
							polysAdded.get(k) );
				}
			}
		}
	}


	public boolean nextLevel() {
		this.layerToDraw += 1;
		if ( this.layerToDraw >= this.layerTris.size() ) {
			this.layerToDraw -= 1;
			return false;
		}
		return true;
	}

	public void render( boolean drawHoles ) {
		int i, j;
		//super.render(); // draw view background
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		ArrayList<Polygon> polysToDraw = new ArrayList<Polygon>();
		ArrayList<PolyPoint> verticesToDraw = new ArrayList<PolyPoint>();
		if ( drawPoly ) {
			this.polygon.render();
		}
		if ( drawPolyTris ) {
			polysToDraw = this.mesh.getPolygonsById(this.polygonTris);
		}
		if ( drawOuterTri || drawLayers ) {
			this.outerTri.render();
		}
		if ( drawLayers ) {
			// draw polygons up to requested layer
			polysToDraw = this.mesh.getPolygonsById(
					this.layerTris.get(this.layerToDraw));
			// draw vertices up to requested layer
			verticesToDraw = this.layerVertices.get(layerToDraw);
		}

		// render polygons to draw
		for( i = 0; i < polysToDraw.size(); i++ ) {
			if ( this.layerToDraw < layerTris.size() - 2 ) {
				if ( this.polygonTris.contains(polysToDraw.get(i).id) ||
				  (!this.layerTris.get(this.layerToDraw + 1).contains(
					 polysToDraw.get(i).id) )) {
					polysToDraw.get(i).selected = false;
				} else {
					polysToDraw.get(i).selected = true;
				}
			} else {
				polysToDraw.get(i).selected = false;
			}
			polysToDraw.get(i).render(false);
		}

		// render vertices to draw
		for( i = 0; i < verticesToDraw.size(); i++ ) {
			verticesToDraw.get(i).render();
		}
	}

	public void render() {
		// draw polygon only by default
		render( false );
	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		if ( layerToDraw < this.layerTris.size() ) {
			ArrayList<Integer> polysToDraw =
				this.layerTris.get( this.layerToDraw );
			for( int i; i < polysToDraw.size(); i++ ) {
				if (color(polysToDraw.get(i)) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = polysToDraw.get(i);
					messages.add(msg);
				}
			}
			// show pick buffer on button press
			//if (keyPressed) {
			//	image(pickbuffer, 0, 0);
			//}
		}
	}

}
