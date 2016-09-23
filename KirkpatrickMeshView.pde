class KirkpatrickMeshView extends View {

	LayeredMesh mesh;

	Polygon polygon;
	Polygon outerTri;

	int subScene;
	int EXPLAIN=1;
	int TRIANGULATE_POLY=2;
	int ADD_OUTER_TRI=3;
	int TRIANGULATE_OUTER_TRI=4;
	int MESH_TRAVERSAL=5;
	int ADD_ROOT_TRI=6;
	int explanation;
	boolean initialized;

	ArrayList<Integer> polygonsToDraw;
	ArrayList<Vertex> verticesToDraw;
	PolyPoint ildvToDraw;

	int layerToDraw;
	int subLayerToDraw;
	boolean layerInitialized;
	boolean drawOuterTriangle;

	public KirkpatrickMeshView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.layerToDraw = 1;
		this.subLayerToDraw = 0;
		this.layerInitialized = false;
		this.drawOuterTriangle = false;

		this.mesh = null;
		this.polygon = null;
		this.outerTri = null;

		this.polygonTris = new ArrayList<Integer>();
		this.polygonsToDraw = new ArrayList<Integer>();
		this.verticesToDraw = new ArrayList<Vertex>();
		this.ildvToDraw = null;

		this.initialized = false;
		this.finalized = false;
	}

	public void setMesh( LayeredMesh mesh, Polygon polygon, Polygon outerTri ){
		int i, j, k, l;

		this.polygon = polygon.copy();
		this.outerTri = outerTri.copy();

		reset();
		// add polygon to mesh as workaround for keying by ID
		this.polygonsToDraw.add(this.polygon.id);

		// clear previously set mesh
		this.ildvToDraw = null;
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.mesh.polygons.put(this.polygon.id, this.polygon);

		// set polygon and outer triangle tris
		Iterator<Integer> iterator = mesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( mesh.polygons.get(polyId).parentId == polygon.id ) {
				this.polygonTris.add(polyId);
			}
		}
	}

	public void reset() {
		subLayerToDraw = 0;
		layerToDraw = 1;
		polygonsToDraw.clear();
		verticesToDraw.clear();
		ildvToDraw = null;
		layerInitialized = false;

		drawOuterTriangle = false;
		outerTri.selected = false;

		subScene = EXPLAIN;
		explanation = 1;
		initialized = false;
		polygonsToDraw.add(polygon.id);

		this.finalized = false;
	}

	private boolean nextLevel() {
		if (subLayerToDraw >= mesh.layers.get(layerToDraw).subLayers.size()-1){
			if ( layerToDraw < mesh.layers.size() - 1 ) {
				subLayerToDraw = 0;
				layerToDraw++;
				layerInitialized = false;
			} else {
				subLayerToDraw = 0;
				layerToDraw++;
				layerInitialized = false;
				return false;
			}
		} else {
			subLayerToDraw++;
		}
		return true;
	}

	public boolean previousLevel() {
		if (subLayerToDraw == 0 ) {
			if ( layerInitialized ) {
				layerInitialized = false;
			} else if ( layerToDraw > 1 ) {
				layerToDraw--;
				console.log("sublayers " + layerToDraw );
				subLayerToDraw =
					mesh.layers.get(layerToDraw).subLayers.size() - 1;
				layerInitialized = true;
			} else {
				// keep layer as it was and return false to indicate
				// last layer exceeded
				return false;
			}
		} else {
			subLayerToDraw--;
		}

		return true;
	}

	private boolean nextSubScene() {
		switch(subScene) {
			case EXPLAIN:
				if ( explanation < 4 ) {
					subScene = EXPLAIN;
				} else if ( explanation == 4) {
					subScene = TRIANGULATE_POLY;
				} else {
					subScene = MESH_TRAVERSAL;
				}
				explanation++;
				break;
			case TRIANGULATE_POLY:
				subScene = ADD_OUTER_TRI;
				break;
			case ADD_OUTER_TRI:
				subScene = TRIANGULATE_OUTER_TRI;
				break;
			case TRIANGULATE_OUTER_TRI:
				subScene = EXPLAIN;
				break;
			case MESH_TRAVERSAL:
				subScene = ADD_ROOT_TRI;
				break;
		}
		return true;
	}

	private boolean previousSubScene() {
		console.log(subScene);
		switch(subScene) {
			case EXPLAIN:
				if ( explanation < 4 ) {
					subScene = EXPLAIN;
				} else if ( explanation == 4) {
					subScene = TRIANGULATE_POLY;
				} else {
					subScene = TRIANGULATE_OUTER_TRI;
				}
				explanation--;
				if ( explanation < 0 ){
					explanation = 0;
					return false;
				}
				break;
			case TRIANGULATE_POLY:
				subScene = EXPLAIN;
				break;
			case ADD_OUTER_TRI:
				subScene = TRIANGULATE_POLY;
				break;
			case TRIANGULATE_OUTER_TRI:
				subScene = ADD_OUTER_TRI;
				break;
			case MESH_TRAVERSAL:
				console.log("NO LONGER INITIALIED");
				initialized = false;
				subScene = EXPLAIN;
				return false;
				break;
			case ADD_ROOT_TRI:
				subScene = MESH_TRAVERSAL;
				break;
		}
		console.log(subScene);
		return true;
	}

	public boolean update() {
		// show polygon alone
		switch(subScene) {
			case EXPLAIN:
				if ( explanation == 1 ) {
					setText(sceneControl.explanation1);
				} else if ( explanation == 2 ){
					setText(sceneControl.explanation2);
				} else if ( explanation == 3 ){
					showPlaybackButton(true);
					setText(sceneControl.explanation3);
				} else {
					setText(sceneControl.before_begin);
				}
				return nextSubScene();
			case TRIANGULATE_POLY:
				setText(sceneControl.triangulate_poly);
				polygonsToDraw.clear();
				polygonsToDraw.addAll(
						mesh.getPolygonIdsByParentId(polygon.id));
				polygonsToDraw.addAll(
							mesh.layers.get(0).subLayers.get(1).
							getPolygonsAddedToLayer());
				return nextSubScene();
			case ADD_OUTER_TRI:
				setText(sceneControl.add_outer_tri);
				drawOuterTriangle = true;
				return nextSubScene();
			case TRIANGULATE_OUTER_TRI:
				setText(sceneControl.triangulate_outer_tri);
				polygonsToDraw.addAll(
						mesh.getPolygonIdsByParentId(outerTri.id));
				return nextSubScene();
			case MESH_TRAVERSAL:
				this.initialized = true;
				this.finalized = false;
				if( updateMeshTraversal() ){
					return true;
				}
				return nextSubScene();
			case ADD_ROOT_TRI:
				this.finalized = true;
				return false;
		}
	}

	public boolean rollback() {
		// show polygon alone
		switch(subScene) {
			case EXPLAIN:
				if ( explanation == 1 ) {
					setText(sceneControl.explanation1);
					return false;
				} else if ( explanation == 2 ){
					setText(sceneControl.explanation2);
				} else if ( explanation == 3 ){
					showPlaybackButton(true);
					setText(sceneControl.explanation3);
				} else {
					setText(sceneControl.before_begin);
				}
				return previousSubScene();
			case TRIANGULATE_POLY:
				polygonsToDraw.clear();
				return previousSubScene();
			case ADD_OUTER_TRI:
				setText(sceneControl.triangulate_poly);
				drawOuterTriangle = false;
				return previousSubScene();
			case TRIANGULATE_OUTER_TRI:
				setText(sceneControl.add_outer_tri);
				polygonsToDraw.removeAll(
						mesh.getPolygonIdsByParentId(outerTri.id));
				return previousSubScene();
			case MESH_TRAVERSAL:
				if( rollbackMeshTraversal() ){
					return true;
				}
				setText(sceneControl.triangulate_outer_tri);
				return previousSubScene();
			case ADD_ROOT_TRI:
				this.finalized = false;
				rollbackMeshTraversal();
				return previousSubScene();
		}
	}

	private boolean updateMeshTraversal() {
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

			// if final layer, do not set ILDV text
			setText(sceneControl.ildv_identified);

			// add all polygons visible on previous layer
			polygonsToDraw.clear();
			polygonsToDraw.addAll(
					mesh.getVisiblePolygonIdsByLayer(layerToDraw - 1));

			// add all ildv vertices to be removed on this layer
			layerInitialized = true;

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
				ArrayList<Integer> polysAdded =
					subLayer.getPolygonsAddedToLayer();
				ArrayList<Integer> polysRemoved =
					subLayer.getPolygonsRemovedFromLayer();
				ArrayList<Integer> verticesRemoved =
					subLayer.getVerticesRemovedFromLayer();

				if ( verticesRemoved.size() > 0 ) {
					setText(sceneControl.ildv_selected);
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
					setText(sceneControl.ildv_removed);
					for ( i = 0; i < polysRemoved.size(); i++ ) {
						polygonsToDraw.remove(
								polygonsToDraw.indexOf(
									polysRemoved.get(i)));
					}
				}

				if ( polysAdded.size() > 0 ) {
					setText(sceneControl.retriangulate);
					for ( i = 0; i < polysAdded.size(); i++ ) {
						polygonsToDraw.add(polysAdded.get(i));
					}
				}
			}

			return nextLevel();
		}
	}

	private void rollbackMeshTraversal() {
		if ( !previousLevel() ) {
			return false;
		}

		if ( !layerInitialized ) {
			// if final layer, do not set ILDV text
			setText(sceneControl.ildv_identified);
			verticesToDraw.clear();
		} else {
			int i;
			MeshLayer layer = mesh.layers.get( layerToDraw );
			if ( subLayerToDraw <= layer.subLayers.size() - 1 ) {
				MeshLayer subLayer = layer.subLayers.get(subLayerToDraw);

				// get list of polygons added and removed from current layer
				// Should be either a list of added or removed,
				// but check for and handle both
				ArrayList<Integer> polysAdded =
					subLayer.getPolygonsAddedToLayer();
				ArrayList<Integer> polysRemoved =
					subLayer.getPolygonsRemovedFromLayer();
				ArrayList<Integer> verticesRemoved =
					subLayer.getVerticesRemovedFromLayer();

				if ( verticesRemoved.size() > 0 ) {
					setText(sceneControl.ildv_removed);
					ildvToDraw.selected = false;
					verticesToDraw.add( ildvToDraw );
					ildvToDraw = null;
				}

				if ( polysRemoved.size() > 0 ) {
					setText(sceneControl.retriangulate);
					for ( i = 0; i < polysRemoved.size(); i++ ) {
						polygonsToDraw.add(polysRemoved.get(i));
					}
					// get previous subLayer ILDV
					subLayer = layer.subLayers.get(subLayerToDraw - 1);
					verticesRemoved = subLayer.getVerticesRemovedFromLayer();
					for ( i = 0; i < verticesRemoved.size(); i++ ) {
						PolyPoint ildv = new PolyPoint(
									verticesRemoved.get(i).x,
									verticesRemoved.get(i).y);
						ildv.cFill = color(0);
						ildvToDraw = ildv;
					}
				}

				if ( polysAdded.size() > 0 ) {
					setText(sceneControl.ildv_selected);
					for ( i = 0; i < polysAdded.size(); i++ ) {
						polygonsToDraw.remove(
								polygonsToDraw.indexOf(
									polysAdded.get(i)));
					}
				}
			}
		}
		return true;
	}

	public void render() {
		if(!visible){return;}

		int i, j;

		// select triangle under mouse hover
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		polygon.render();
		if( drawOuterTriangle ) {
			outerTri.render();
		}

		// draw polygons
		for( i = 0; i < polygonsToDraw.size(); i++ ) {
			// reverse highlight so triangles are white by default
			// highlight triangle with color if it:
			//  - belongs to the original polygon
			//  - the view is finalized and displaying the root triangle
			//  - is connected to the currently highlighted ILDV
			//  - is selected by the user by mouse hover
			Polygon currPoly = mesh.polygons.get(polygonsToDraw.get(i));
			if ( currPoly.parentId == polygon.id ||
					currPoly.id == polygon.id ||
					this.finalized ||
					( ildvToDraw != null &&
					currPoly.points.contains(ildvToDraw)) ||
					selectedShapes.contains(currPoly.id) ) {
				currPoly.selected = false;
			} else {
				currPoly.selected = true;
			}
			currPoly.render(false);
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
		if(!visible || finalized){return;}
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

