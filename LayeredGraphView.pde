class LayeredGraphView extends View {

	LayeredMesh mesh;
	Polygon polygon;

	int layerToDraw;
	int subLayerToDraw;
	boolean layerInitialized;
	boolean meshTraversalComplete;
	int lastSelected = -1;

	float xDiv;
	float yDiv;
	float currScale;
	ArrayList<Polygon> polygonsToDraw;
	ArrayList<Polygon> polygonsToHighlight;
	ArrayList<MeshLayerEdge> graphEdgesToDraw;
	ArrayList<MeshLayerEdge> selectedEdges;

	HashMap<Integer, GraphPosition> graphLayout;

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

		this.polygonsToDraw = new ArrayList<Polygon>();
		this.polygonsToHighlight = new ArrayList<Polygon>();
		this.graphEdgesToDraw = new ArrayList<MeshLayerEdge>();
		this.selectedEdges = new ArrayList<MeshLayerEdge>();

		this.graphLayout = new HashMap<Integer, GraphPosition>();
	}

	public void setMesh( LayeredMesh mesh, Polygon polygon ) {
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.polygon = polygon.copy();
		// must be called after mesh is set so yDiv can be calculated
		reset();

		setupGraphLayout();
	}

	public void reset() {
		subLayerToDraw = 0;
		// skip rendering the first layer to align with update of kpMeshView
		layerToDraw = 0;

		polygonsToDraw.clear();
		polygonsToHighlight.clear();
		graphEdgesToDraw.clear();
		selectedEdges.clear();

		layerInitialized = false;
		meshTraversalComplete = false;
		finalized = false;
		// initialize first layer
		update();
	}

	private boolean nextLevel() {
		if ( subLayerToDraw >=
				mesh.layers.get(layerToDraw).subLayers.size() - 1 ){
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

	public void setupGraphLayout() {
		int i, j;

		graphLayout.clear();

		float xDiv;
		float yDiv = this.h / (this.mesh.layers.size());

		float xPos = this.x1;
		float yPos = this.y2 + yDiv/2.0;
		double maxWidth  = -1;
		double maxHeight = -1;
		float currScale = -1;

		MeshLayer currLayer;
		ArrayList<Polygon> layerPolys;
		for ( i = 0; i < mesh.layers.size(); i++ ) {
			currLayer = mesh.layers.get( i );

			// get Polygons removed from this layer
			layerPolys = mesh.getPolygonsById(
						currLayer.getPolygonsRemovedFromLayer());

			// calculate the X position for each polygon on this layer
			xDiv = w / currLayer.getPolygonsRemovedFromLayer().size();

			// calculate the scaling factor for this layer
			maxWidth  = -1;
			maxHeight = -1;
			for( j = 0; j < layerPolys.size(); j++ ) {
				if( layerPolys.get(j).getWidth() > maxWidth ) {
					maxWidth = layerPolys.get(j).getWidth();
				}
				if( layerPolys.get(j).getHeight() > maxHeight ) {
					maxHeight = (layerPolys.get(j).getHeight() * 1.1);
				}
			}
			currScale = Math.min( xDiv / maxWidth, yDiv / maxHeight );

			xPos = this.x1 + (xDiv / 2.0);
			for ( j = 0; j < layerPolys.size(); j++ ) {
				graphPosition = new GraphPosition(xPos, yPos, currScale);
				graphLayout.put(layerPolys.get(j).id, graphPosition);
				xPos += xDiv;
				console.log("ADDING gp for " + layerPolys.get(j).id);
			}

			// update the Y position for the next layer
			yPos -= yDiv;
		}

		// Finally, add the root polygon position
		// done separately because it is never removed from the mesh
		Polygon root =
			mesh.getVisiblePolygonsByLayer(mesh.layers.size() - 1).get(0);
		graphPosition = new GraphPosition(this.x1 + (w/2.0), yPos,
				Math.min(xDiv / root.getWidth(), yDiv / root.getHeight()));
		graphLayout.put( root.id, graphPosition );
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
			polygonsToHighlight.clear();
			graphEdgesToDraw.clear();
			return true;
		}

		MeshLayer layer = mesh.layers.get( layerToDraw );
		MeshLayer subLayer = layer.subLayers.get( subLayerToDraw );
		if ( subLayer != null ) {

			// get list of polygons added to current subLayer
			// if new triangles added, add to graph
			Polygon currPoly;
			ArrayList<Integer> polysAdded = subLayer.getPolygonsAddedToLayer();
			GraphPosition graphPosition;
			if ( polysAdded.size() > 0 ) {
				for ( i = 0; i < polysAdded.size(); i++ ) {
					currPoly = mesh.polygons.get( polysAdded.get(i) );
					graphPosition = graphLayout.get( polysAdded.get(i) );
					console.log(graphPosition);
					console.log(currPoly.id);

					// adjust polygon to position in graph
					currPoly.move( graphPosition.x, graphPosition.y );
					currPoly.scale( graphPosition.scale );
					polygonsToDraw.add( currPoly );

					// add edges from newly added polygons to the currently
					// highlighted polygons (last removed)
					for ( j = 0; j < polygonsToHighlight.size(); j++) {
						MeshLayerEdge newEdge =
							new MeshLayerEdge(currPoly,
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

			ArrayList<Integer> verticesRemoved =
				subLayer.getVerticesRemovedFromLayer();
			if ( verticesRemoved.size() > 0 ) {
				// clear currently displayed graph edges and highlighted polys
				polygonsToHighlight.clear();
				graphEdgesToDraw.clear();
				// set just removed polygons to highlight
				subLayer = layer.subLayers.get( subLayerToDraw + 1 );
				polygonsToHighlight = subLayer.getPolygonsRemovedFromLayer();
				// [commented] highlight all the way down the graph
				// from the removed polygons
				/*
				graphEdgesToDraw.addAll(
						mesh.getMultipleChildMeshConnections(
							polygonsToHighlight, true, null));
				*/
			}
		}

		return nextLevel();
	}

	public void render() {
		if(!visible){return;}
		int i, j, k;

		// get list of selected polygons
		ArrayList<Integer> selected = new ArrayList<Integer>();
		boolean polySelected = false;
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				polySelected = true;
				// should be made to handle multiple selected polys,
				// but this view can only have one selected at a time,
				// so leaving it for now
				if ( messages.get(i).v != lastSelected ) {
					lastSelected = messages.get(i).v;
					selectedEdges.clear();
					selectedEdges.addAll(
							mesh.getChildMeshConnections(
								messages.get(i).v, true, null));
				}
				selected.add(messages.get(i).v);
			}
		}

		// draw graph edges
		for ( i = 0; i < this.graphEdgesToDraw.size(); i++ ) {
			this.graphEdgesToDraw.get(i).render();
		}
		if ( polySelected ) {
			// draw selected graph edges
			for ( i = 0; i < selectedEdges.size(); i++ ) {
				selectedEdges.get(i).render();
				if (selectedEdges.get(i).start != null) {
					selected.add(selectedEdges.get(i).start.id);
				}
				if (selectedEdges.get(i).end != null) {
					selected.add(selectedEdges.get(i).end.id);
				}
			}
		}

		// render polygons to draw
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			// flip true/false selected to show white majority of time
			if ( selected.contains(polygonsToDraw.get(i).id) ||
			  ( (layerToDraw == 0 || (layerToDraw == 1 && subLayerToDraw == 0))
				&& polygonsToDraw.get(i).parentId == this.polygon.id ) ||
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

class GraphPosition{
	float x;
	float y;
	float scale;
	public GraphPosition(float x, float y, float scale) {
		this.x = x;
		this.y = y;
		this.scale = scale;
	}
}
