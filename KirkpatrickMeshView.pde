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

	ArrayList<Polygon> polygonsToDraw;
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
		this.polygonsToDraw = new ArrayList<Polygon>();
		this.verticesToDraw = new ArrayList<Vertex>();
		this.ildvToDraw = null;

		this.initialized = true;
		this.finalized = false;
	}

	public void setMesh( LayeredMesh mesh, Polygon polygon, Polygon outerTri ){
		int i, j, k, l;

		this.polygon = polygon.copy();
		this.outerTri = outerTri.copy();

		reset();
		this.polygonsToDraw.add(this.polygon);

		// clear previously set mesh
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
		polygonsToDraw.add(polygon);

		this.finalized = false;
	}

	private boolean nextLevel() {
		if (subLayerToDraw >= mesh.layers.get(layerToDraw).subLayers.size()-1){
			if ( layerToDraw < mesh.layers.size() - 1 ) {
				subLayerToDraw = 0;
				layerToDraw++;
				layerInitialized = false;
			} else {
				// keep layer as it was and return false to indicate
				// last layer exceeded
				return false;
			}
		} else {
			subLayerToDraw++;
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
					initialized = true;
					subScene = MESH_TRAVERSAL;
				}
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

	public boolean update() {
		// show polygon alone
		switch(subScene) {
			case EXPLAIN:
				if ( explanation == 1 ) {
					$("#play-button").hide();
					setText(sceneControl.explanation1);
				} else if ( explanation == 2 ){
					setText(sceneControl.explanation2);
				} else if ( explanation == 3 ){
					$("#play-button").show();
					setText(sceneControl.explanation3);
				} else {
					setText(sceneControl.before_begin);
				}
				explanation++;
				return nextSubScene();
			case TRIANGULATE_POLY:
				setText(sceneControl.triangulate_poly);
				polygonsToDraw.clear();
				polygonsToDraw.addAll(
						mesh.getPolygonsByParentId(polygon.id));
				polygonsToDraw.addAll(mesh.getPolygonsById(
							mesh.layers.get(0).subLayers.get(1).
							getPolygonsAddedToLayer()));
				return nextSubScene();
			case ADD_OUTER_TRI:
				setText(sceneControl.add_outer_tri);
				drawOuterTriangle = true;
				return nextSubScene();
			case TRIANGULATE_OUTER_TRI:
				setText(sceneControl.triangulate_outer_tri);
				polygonsToDraw.addAll(mesh.getPolygonsByParentId(outerTri.id));
				return nextSubScene();
			case MESH_TRAVERSAL:
				if( updateMeshTraversal() ){
					return true;
				}
				return nextSubScene();
			case ADD_ROOT_TRI:
				this.finalized = true;
				return false;
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
					mesh.getVisiblePolygonsByLayer(layerToDraw - 1));

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
									mesh.polygons.get(polysRemoved.get(i))));
					}
				}

				if ( polysAdded.size() > 0 ) {
					setText(sceneControl.retriangulate);
					for ( i = 0; i < polysAdded.size(); i++ ) {
						polygonsToDraw.add( mesh.polygons.get(polysAdded.get(i)) );
					}
				}
			}

			return nextLevel();
		}
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
			if ( polygonsToDraw.get(i).parentId == polygon.id ||
					polygonsToDraw.get(i).id == polygon.id ||
					this.finalized ||
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
		if(!visible || finalized){return;}
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
