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
	ArrayList<Integer> polygonsToDraw;
	ArrayList<MeshLayerEdge> edgesToDraw;

	int currLevel;
	int maxLevelReached;

	public LayeredGraphView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.cFill = color(255);

		this.mesh = null;

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

		this.polygonsToDraw = new ArrayList<Integer>();
		this.edgesToDraw = new ArrayList<MeshLayerEdge>();
	}

	public void setMesh( LayeredMesh mesh, Polygon polygon ) {
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.polygon = polygon;
		// must be called after mesh is set so yDiv can be calculated
		reset();
	}

	public void reset() {
		subLayerToDraw = 0;
		// skip rendering the first layer to align with update of kpMeshView
		layerToDraw = 1;
		currLevel = 1;
		maxLevelReached = currLevel;

		polygonsToDraw.clear();
		edgesToDraw.clear();

		// initialize y position outside of bounds of view
		// this sets up positing correctly for first layer in graph
		this.yDiv = this.h / (this.mesh.layers.size());
		currPosition[0] = this.x1;
		currPosition[1] = this.y2 + yDiv/2.0;

		layerInitialized = false;
		meshTraversalComplete = false;
		finalized = false;
	}

	private boolean nextLevel() {
		if (subLayerToDraw >= mesh.layers.get(layerToDraw).subLayers.size()-1){
			subLayerToDraw = 0;
			layerToDraw++;
			layerInitialized = false;
		} else {
			subLayerToDraw++;
		}
		maxLevelReached =
			(currLevel > maxLevelReached) ? currLevel : maxLevelReached;
		return ( layerToDraw <= mesh.layers.size() - 1 );
	}

	private boolean previousLevel() {
		meshTraversalComplete = false;
		if (subLayerToDraw == 0 ) {
			if ( layerInitialized ) {
				layerInitialized = false;
			} else {
				if ( layerToDraw > 1 ) {
					layerToDraw--;
					subLayerToDraw =
						mesh.layers.get(layerToDraw).subLayers.size() - 1;
					layerInitialized = true;
				} else {
					layerToDraw--;
					subLayerToDraw =
						mesh.layers.get(layerToDraw).subLayers.size() - 1;
					// keep layer as it was and return false to indicate
					// last layer exceeded
					return false;
				}
			}
		} else {
			layerInitialized = true;
			subLayerToDraw--;
		}

		return true;
	}

	public void update() {
		if ( !finalized ) {
			if ( !meshTraversalComplete ) {
				meshTraversalComplete = !updateMeshTraversal();
			} else {
				// one additional update round to add final polygon to top of graph
				addRootPolygon();
				setText(sceneControl.graph_complete);
				finalized = true;
			}
			return true;
		}
		return false;
	}

	public void rollback() {
		if ( meshTraversalComplete ) {
			meshTraversalComplete = false;
		}
		rollbackMeshTraversal();
	}

	public void addRootPolygon() {
		Polygon root =
			mesh.getVisiblePolygonsByLayer(mesh.layers.size() - 1).get(0);
		PolyPoint polyCenter = polygon.getCenter();
		root.move( polyCenter.x, polyCenter.y );
		currPosition[0] = this.x1 + (w / 2.0);
		currPosition[1] -= yDiv;
		currScale = Math.min(xDiv / root.getWidth(), yDiv / root.getHeight());
		root.animateMove( currPosition[0], currPosition[1] );
		root.animateScale( currScale );
		polygonsToDraw.add( root.id );
		//edgesToDraw.add( root.id );
	}

	public void updateMeshTraversal() {
		int i;
		if ( !layerInitialized ) {
			layerInitialized = true;

			// initialized should only be done if layer has not yet
			// been reached
			if ( currLevel == maxLevelReached ) {
				MeshLayer currLayer = mesh.layers.get( layerToDraw );
				// calculate new x division based on number of triangles in layer
				xDiv = w / currLayer.getPolygonsRemovedFromLayer().size();

				// adjust starting position for new layer of triangles
				currPosition[0] = this.x1 + (xDiv / 2);
				currPosition[1] -= yDiv;
				ArrayList<Polygon> layerPolys = mesh.getPolygonsById(
							currLayer.getPolygonsRemovedFromLayer());
				// no polygons removed from first layer, so do not increase
				// the first visual layer in the graph unless not first layer
				if ( layerToDraw == 0 ) {
					currPosition[1] += yDiv;
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
			}
			return true;
		} else {

			MeshLayer layer = mesh.layers.get( layerToDraw );
			MeshLayer subLayer = layer.subLayers.get( subLayerToDraw );

			// get list of polygons added to current subLayer
			// if new triangles added, add to graph
			Polygon currPoly;
			ArrayList<Integer> polysAdded =
				subLayer.getPolygonsRemovedFromLayer();
			if ( polysAdded.size() > 0 ) {
				for ( i = 0; i < polysAdded.size(); i++ ) {
					currPoly = mesh.polygons.get( polysAdded.get(i) );
					if ( currLevel == maxLevelReached ) {
						currPoly.move( currPosition[0], currPosition[1] );
						currPoly.scale( currScale );
						// increase x position to next location
						currPosition[0] += xDiv;
					}
					polygonsToDraw.add( currPoly.id );
					edgesToDraw.addAll(
							mesh.getChildMeshConnections(
								currPoly.id, false, null));
				}
			} else {
				edgesToDraw.clear();
			}

			currLevel++;
			return nextLevel();
		}
	}

	public boolean rollbackMeshTraversal() {
		if ( !previousLevel() ) {
			return false;
		}
		if ( layerInitialized ) {
			MeshLayer layer = mesh.layers.get( layerToDraw );
			if ( subLayerToDraw <= layer.subLayers.size() - 1 ) {
				MeshLayer subLayer = layer.subLayers.get( subLayerToDraw );

				// get list of polygons added to current subLayer
				// if new triangles added, add to graph
				Polygon currPoly;
				ArrayList<Integer> polysAdded =
					subLayer.getPolygonsRemovedFromLayer();
				for ( i = 0; i < polysAdded.size(); i++ ) {
					currPoly = mesh.polygons.get( polysAdded.get(i) );
					polygonsToDraw.remove(polygonsToDraw.indexOf(currPoly.id));
				}
				edgesToDraw.clear();
			}
			currLevel--;
		}
		return true;
	}

	public void render() {
		if(!visible){return;}
		//noStroke();
		//super.render(); // draw view background
		int i, j, k;

		// get list of selected polygons
		ArrayList<Integer> selected = new ArrayList<Integer>();
		ArrayList<MeshLayerEdge> selectedEdges = new ArrayList<MeshLayerEdge>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				if (polygonsToDraw.contains( messages.get(i).v) ) {
					// should be made to handle multiple selected polys,
					// but this view can only have one selected at a time,
					// so leaving it for now
					selectedEdges.clear();
					selectedEdges.addAll(
							mesh.getChildMeshConnections(
								messages.get(i).v, true, null));
					//selected.add(messages.get(i).v);
				}
			}
		}

		// draw selected graph edges
		for ( i = 0; i < selectedEdges.size(); i++ ) {
			fill(color(0));
			selectedEdges.get(i).render();
			/*
			if (selectedEdges.get(i).start != null) {
				selected.add(selectedEdges.get(i).start.id);
			}
			if (selectedEdges.get(i).end != null) {
				selected.add(selectedEdges.get(i).end.id);
			}
			*/
		}
		for ( i = 0; i < edgesToDraw.size(); i++ ) {
			edgesToDraw.get(i).render();
		}

		// render polygons to draw
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			if ( selected.contains(polygonsToDraw.get(i)) ) {
				mesh.polygons.get(polygonsToDraw.get(i)).selected = true;
			} else {
				mesh.polygons.get(polygonsToDraw.get(i)).selected = false;
			}
			mesh.polygons.get(polygonsToDraw.get(i)).render(false);
		}
	}

	public void mouseUpdate() {
		if(!visible){return;}
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		if ( layerToDraw < this.mesh.layers.size() ) {
			for( int i; i < polygonsToDraw.size(); i++ ) {
				if (mesh.polygons.get(polygonsToDraw.get(i)).pickColor == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = polygonsToDraw.get(i);
					messages.add(msg);
				}
			}
		}
	}

}

