class LayeredGraphView extends View {

	LayeredMesh mesh;
	Polygon polygon;

	int layerToDraw;
	int subLayerToDraw;
	boolean layerInitialized;
	boolean meshTraversalComplete;

	float xDiv;
	float yDiv;
	float currScale;
	ArrayList<Integer> currPosition;
	ArrayList<Polygon> polygonsToDraw;
	ArrayList<Polygon> polygonsToHighlight;
	ArrayList<GraphEdge> graphEdgesToDraw;

	public LayeredGraphView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.cFill = color(255);

		this.mesh = null;
		this.polygon = null;

		this.layerToDraw = 1;
		this.subLayerToDraw = 0;
		this.layerInitialized = false;
		this.meshTraversalComplete = false;
		this.finalized = false;

		this.currPosition = new ArrayList<Integer>();
		this.currPosition.add(this.x1);
		this.currPosition.add(this.y2);
		this.yDiv = 0;
		this.xDiv = 0;
		this.currScale = 1.0;

		this.polygonsToDraw = new ArrayList<Polygon>();
		this.polygonsToHighlight = new ArrayList<Polygon>();
		this.graphEdgesToDraw = new ArrayList<GraphEdge>();
	}

	public void setMesh( LayeredMesh mesh, Polygon polygon ) {
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.polygon = polygon.copy();
		// must be called after mesh is set so yDiv can be calculated
		reset();
	}

	public void reset() {
		subLayerToDraw = 0;
		// skip rendering the first layer to align with update of kpMeshView
		layerToDraw = 0;

		polygonsToDraw.clear();
		polygonsToHighlight.clear();
		graphEdgesToDraw.clear();

		// initialize y position outside of bounds of view
		// this sets up positing correctly for first layer in graph
		this.yDiv = this.h / (this.mesh.layers.size());
		currPosition[0] = this.x1;
		currPosition[1] = this.y2 + yDiv/2.0;

		layerInitialized = false;
		meshTraversalComplete = false;
		finalized = false;
		// initialize first layer
		update();
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
		if ( !finalized ) {
			if( !updateMeshTraversal() ) {
				//addRootPolygon();
				setText(sceneControl.graph_complete);
				finalized = true;
			}
			return true;
		}
		return false;
	}

	public void addRootPolygon() {
		Polygon root =
			mesh.getVisiblePolygonsByLayer(mesh.layers.size() - 1).get(0);
		currPosition[0] = this.x1 + (w / 2.0);
		currPosition[1] -= yDiv;
		currScale = Math.min(xDiv / root.getWidth(), yDiv / root.getHeight());
		root.animateMove( currPosition[0], currPosition[1] );
		root.animateScale( currScale );
		polygonsToDraw.add( root );
	}

	public void updateMeshTraversal() {
		int i;
		if ( !layerInitialized ) {
			layerInitialized = true;

			MeshLayer currLayer = mesh.layers.get( layerToDraw );
			// calculate new x division based on number of triangles in layer
			xDiv = w / currLayer.getPolygonsAddedToLayer().size();

			// adjust starting position for new layer of triangles
			currPosition[0] = this.x1 + (xDiv / 2);
			currPosition[1] -= yDiv;
			ArrayList<Polygon> layerPolys =
				mesh.getPolygonsById(currLayer.getPolygonsAddedToLayer());
			// no polygons removed from first layer, so do not increase
			// the first visual layer in the graph unless not first layer
			/*
			if ( layerToDraw == 0 ) {
				currPosition[1] += yDiv;
			}
			*/
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
			polygonsToHighlight.clear();
			return true;
		}

		MeshLayer layer = mesh.layers.get( layerToDraw );
		MeshLayer subLayer = layer.subLayers.get( subLayerToDraw );
		if ( subLayer != null ) {

			// get list of polygons added to current subLayer
			// if new triangles added, add to graph
			Polygon currPoly;
			ArrayList<Integer> polysAdded = subLayer.getPolygonsAddedToLayer();
			if ( polysAdded.size() > 0 ) {
				for ( i = 0; i < polysAdded.size(); i++ ) {
					currPoly = mesh.polygons.get( polysAdded.get(i) );
					currPoly.move( currPosition[0], currPosition[1] );
					currPoly.scale( currScale );
					polygonsToDraw.add( currPoly );
					// increase x position to next location
					currPosition[0] += xDiv;
					for ( j = 0; j < polygonsToHighlight.size(); j++) {
						GraphEdge newEdge =
							new GraphEdge(currPoly,
									mesh.polygons.get(
										polygonsToHighlight.get(j)));
						graphEdgesToDraw.add(newEdge);
					}
				}
				// first layer should remain unconnected since
				// no vertices/triangles are removed
				if ( layerToDraw > 0 ) {
					polygonsToHighlight.addAll(polysAdded);
				}
			}
			ArrayList<Integer> verticesRemoved = subLayer.getVerticesRemovedFromLayer();
			if ( verticesRemoved.size() > 0 ) {
				polygonsToHighlight.clear();
				subLayer = layer.subLayers.get( subLayerToDraw + 1 );
				polygonsToHighlight = subLayer.getPolygonsRemovedFromLayer();
			}
		}

		return nextLevel();
	}

	public void render() {
		if(!visible){return;}
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

		// draw graph edges
		GraphEdge edge;
		for ( i = 0; i < this.graphEdgesToDraw.size(); i++ ) {
			this.graphEdgesToDraw.get(i).render();
		}


		// render polygons to draw
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			// flip true/false selected to show white majority of time
			if ( selectedShapes.contains(polygonsToDraw.get(i).id) ||
			  polygonsToDraw.get(i).parentId == this.polygon.id ||
			  polygonsToHighlight.contains(polygonsToDraw.get(i).id) ) {
				polygonsToDraw.get(i).selected = false;
			} else {
				polygonsToDraw.get(i).selected = true;
			}
			polygonsToDraw.get(i).render(false);
		}
	}

	public void mouseUpdate() {
		if(!visible){return;}
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		if ( layerToDraw < this.mesh.layers.size() ) {
			for( int i; i < polygonsToDraw.size(); i++ ) {
				if (polygonsToDraw.get(i).pickColor == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = polygonsToDraw.get(i).id;
					messages.add(msg);
				}
			}
		}
	}

}
