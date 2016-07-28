class LayeredGraphView extends View {

	LayeredMesh mesh;

	int MODE_ON_ADD = 1;
	int MODE_ON_REMOVE = 2;
	int MODE;

	int layerToDraw;
	int subLayerToDraw;
	boolean layerInitialized;

	float xDiv;
	float yDiv;
	float currScale;
	ArrayList<Integer> currPosition;
	ArrayList<Polygon> polygonsToDraw;

	public LayeredGraphView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.cFill = color(255);

		this.mesh = null;

		this.layerToDraw = 0;
		this.subLayerToDraw = 0;
		this.layerInitialized = false;

		this.currPosition = new ArrayList<Integer>();
		this.currPosition.add(this.x1);
		this.currPosition.add(this.y2);
		this.yDiv = 0;
		this.xDiv = 0;

		this.polygonsToDraw = new ArrayList<Polygon>();

		this.MODE = MODE_ON_REMOVE;
		console.log("Graph ending position " + y2);
	}

	public void setMesh( LayeredMesh mesh ) {
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.yDiv = this.h / (this.mesh.layers.size() - 1);
		// initialize y position outside of bounds of view
		// this sets up positing correctly for first layer in graph
		this.currPosition[1] = this.y2 + yDiv/2.0;
		console.log("starting yPos = " + currPosition[1]);
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

	public void update() {
		int i;
		if ( !layerInitialized ) {
			layerInitialized = true;

			MeshLayer currLayer = mesh.layers.get( layerToDraw );
			// calculate new x division based on number of triangles in layer
			if ( MODE == MODE_ON_ADD ) {
				xDiv = w / currLayer.getPolygonsAddedToLayer().size();
			} else if ( MODE == MODE_ON_REMOVE ) {
				xDiv = w / currLayer.getPolygonsRemovedFromLayer().size();
			}

			// adjust starting position for new layer of triangles
			currPosition[0] = this.x1 + (xDiv / 2);
			currPosition[1] -= yDiv;
			ArrayList<Polygon> layerPolys;
			if ( MODE == MODE_ON_ADD ) {
				layerPolys =
					mesh.getPolygonsById(currLayer.getPolygonsAddedToLayer());
			} else if ( MODE == MODE_ON_REMOVE ) {
				layerPolys =
					mesh.getPolygonsById(currLayer.getPolygonsRemovedFromLayer());
				// no polygons removed from first layer, so do not increase
				// the first visual layer in the graph unless not first layer
				if ( layerToDraw == 0 ) {
					currPosition[1] += yDiv;
				}
			}
			// calculate new scaling factor based on triangles in new layer
			double maxWidth  = -1;
			double maxHeight = -1;
			for( i = 0; i < layerPolys.size(); i++ ) {
				if( layerPolys.get(i).getWidth() > maxWidth ) {
					maxWidth = layerPolys.get(i).getWidth();
				}
				if( layerPolys.get(i).getHeight() > maxHeight ) {
					maxHeight = (layerPolys.get(i).getHeight() * 1.1);
				}
			}
			currScale = Math.min( xDiv / maxWidth, yDiv / maxHeight );

			return true;
		} else {

			MeshLayer layer = mesh.layers.get( layerToDraw );
			MeshLayer subLayer = layer.subLayers.get( subLayerToDraw );

			// get list of polygons added to current subLayer
			// if new triangles added, add to graph
			Polygon currPoly;
			ArrayList<Integer> polysAdded;
			if ( MODE == MODE_ON_ADD ) {
				 polysAdded = subLayer.getPolygonsAddedToLayer();
			} else if ( MODE == MODE_ON_REMOVE ) {
				 polysAdded = subLayer.getPolygonsRemovedFromLayer();
			}
			for ( i = 0; i < polysAdded.size(); i++ ) {
				currPoly = mesh.polygons.get( polysAdded.get(i) );
				currPoly.move( currPosition[0], currPosition[1] );
				currPoly.scale( currScale );
				polygonsToDraw.add( currPoly );
				// increase x position to next location
				currPosition[0] += xDiv;
			}

			return nextLevel();
		}

	}

	public void render() {
		//noStroke();
		//super.render(); // draw view background
		int i, j, k;

		// get list of selected polygons
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		// render polygons to draw
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			if ( selectedShapes.contains(polygonsToDraw.get(i).id) ) {
				polygonsToDraw.get(i).selected = true;
			} else {
				polygonsToDraw.get(i).selected = false;
			}
			polygonsToDraw.get(i).render(false);
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
