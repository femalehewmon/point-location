class PointLocationView extends View {

	PolyPoint pointSelected;					// the user selected point

	Polygon polygon;							// original polygon
	Polygon root;								// top polygon in graph
	// both meshes required because while the polygons hold mutual IDs,
	// they are independent objects that are positioned and sized differently
	LayeredMesh kpMesh;							// mesh of KP data structure
	LayeredMesh lgraphMesh;						// mesh of layered graph

	int layerToDraw;							// current layer to draw
	ArrayList<ArrayList<Polygon>> kpLayers;		// renderable layers
	ArrayList<ArrayList<GraphEdge>> edges;		// renderable edges
	// NOTE: graph layers drawn based off of kpLayers since IDs are shared

	// used to speed up graph edge drawing on mouse hover selection
	// prevents re-recursive search on each render loop
	int lastSelected = -1;
	boolean pointInside;
	ArrayList<GraphEdge> selectedEdges;

	public PointLocationView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.pointSelected = null;
		this.pointInside = false;

		this.polygon = null;
		this.root = null;
		this.kpMesh = null;
		this.lgraphMesh = null;

		this.layerToDraw = 0;
		this.kpLayers = new ArrayList<ArrayList<Polygon>>();
		this.edges = new ArrayList<ArrayList<GraphEdge>>();

		this.selectedEdges = new ArrayList<GraphEdge>();
	}

	public void setMesh(
			LayeredMesh kpMesh, LayeredMesh lgraphMesh, Polygon polygon ) {

		this.polygon = polygon;

		if ( this.kpMesh != null ) {
			this.kpMesh.clear();
		}
		if ( this.lgraphMesh != null ) {
			this.lgraphMesh.clear();
		}

		this.kpMesh = kpMesh.copy();
		this.lgraphMesh = lgraphMesh.copy();
		this.root = kpMesh.polygons.get(
				kpMesh.getVisiblePolygonIdsByLayer(
					kpMesh.layers.size() - 1).get(0));
		reset();
	}

	private void reset() {
		this.finalized = false;
		setText(sceneControl.place_point);

		this.pointSelected = null;

		this.layerToDraw = 0;
		this.kpLayers.clear();
		this.kpLayers.add( new ArrayList<Polygon>() );
		this.kpLayers.get(this.kpLayers.size() - 1).add(root);
		this.edges.clear();
		this.edges.add( new ArrayList<GraphEdge>() );
	}

	public boolean evaluatePoint( float x, float y ) {
		if( !inMeshBounds(x, y) || this.pointSelected != null ) {
			// only evaluate points placed inside the outer triangle
			return false;
		}

		setText(sceneControl.point_locating);
		this.pointInside = false;

		this.pointSelected = new PolyPoint(x , y);

		// clear layers from previously evaluated point
		this.kpLayers.clear();
		this.edges.clear();

		// generate array of visible polygons per search layer
		ArrayList<Polygon> visiblePolys = new ArrayList<Polygon>();
		visiblePolys.add( root );

		ArrayList<GraphEdge> pathEdges = new ArrayList<GraphEdge>();
		ArrayList<Polygon> nextLayer;
		ArrayList<GraphEdge> nextEdges;

		int i;
		Polygon visiblePoly;
		do {

			nextLayer = new ArrayList<Polygon>();
			nextEdges = new ArrayList<GraphEdge>();

			// create new copy of visiblePolys to work with in next layer
			visiblePolys = new ArrayList<Polygon>(visiblePolys);
			pathEdges = new ArrayList<GraphEdge>(pathEdges);

			for ( i = visiblePolys.size() - 1; i >= 0 ; i-- ) {
				visiblePoly = visiblePolys.get(i);
				if ( visiblePoly.containsPoint( x, y ) ) {

					// check if tri belongs to the original polygon
					if ( visiblePoly.parentId == polygon.id ) {
						this.pointInside = true;
					}

					if ( pathEdges.size() == 0 ) {
						pathEdges.add(
								new GraphEdge(
									lgraphMesh.polygons.get(root.id),
									lgraphMesh.polygons.get(visiblePoly.id)));
					} else {
						pathEdges.add(
								new GraphEdge(
									pathEdges.get(pathEdges.size() - 1).end,
									lgraphMesh.polygons.get(visiblePoly.id)));
					}

					Iterator<Integer> iterator =
						kpMesh.polygons.keySet().iterator();
					while( iterator.hasNext() ) {
						Integer polyId = iterator.next();
						if ( kpMesh.polygons.get(polyId).childId ==
								visiblePoly.parentId ) {

							// add polygon to next layer
							nextLayer.add( kpMesh.polygons.get(polyId) );
							// add edge to next layer
							nextEdges.add(
									new GraphEdge(
										lgraphMesh.polygons.get(visiblePoly.id),
										lgraphMesh.polygons.get(polyId)));
						}
					}
				} else {
					visiblePolys.remove(visiblePoly);
				}
			}

			// add layer containing only true path polygons and edges
			this.kpLayers.add( visiblePolys );
			this.edges.add( pathEdges );

			// add layer containing next layer polygons and edges
			this.kpLayers.add( nextLayer );
			this.edges.add(nextEdges);
			this.edges.get(this.edges.size() - 1).addAll(pathEdges);

			// set next layer as currently visible polygons
			visiblePolys = nextLayer;

		} while ( visiblePolys.size() > 0 )
	}

	public boolean update() {
		if ( pointSelected != null && !finalized ) {
			if( !nextLevel() ) {
				if ( pointInside ) {
					setText(sceneControl.point_inside);
				} else {
					setText(sceneControl.point_outside);
				}
				finalized = true;
			}
			return true;
		}
		return false;
	}

	private boolean nextLevel() {
		this.layerToDraw += 1;
		if ( this.layerToDraw >= this.kpLayers.size() - 1 ) {
			return false;
		}
		return true;
	}

	public ArrayList<GraphEdge> findConnectedParentEdges(
			Polygon poly, boolean recurse){
		ArrayList<GraphEdge> connected = new ArrayList<GraphEdge>();
		ArrayList<GraphEdge> subConnected;
		GraphEdge edge;
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( poly.childId == lgraphMesh.polygons.get(polyId).parentId ) {
				edge = new GraphEdge(
						poly,
						lgraphMesh.polygons.get(polyId));
				if ( !connected.contains(edge) ) {
					connected.add(edge);
				}
				if ( recurse ) {
					// prevents same edge being drawn over multiple times
					subConnected = findConnectedParentEdges(
								lgraphMesh.polygons.get(polyId), recurse );
					for ( i = 0; i < subConnected.size(); i++ ){
						if ( !connected.contains(subConnected.get(i)) ) {
							connected.add(subConnected.get(i));
						}
					}
				}
			}
		}
		return connected;
	}

	public ArrayList<GraphEdge> findConnectedEdges(
			Polygon poly, boolean recurse ) {
		int i;
		ArrayList<GraphEdge> connected = new ArrayList<GraphEdge>();
		ArrayList<GraphEdge> subConnected;
		GraphEdge edge;
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( poly.parentId == lgraphMesh.polygons.get(polyId).childId ) {
				edge = new GraphEdge(
						poly,
						lgraphMesh.polygons.get(polyId));
				if ( !connected.contains(edge) ) {
					connected.add(edge);
				}
				if ( recurse ) {
					// prevents same edge being drawn over multiple times
					subConnected = findConnectedEdges(
								lgraphMesh.polygons.get(polyId), recurse );
					for ( i = 0; i < subConnected.size(); i++ ){
						if ( !connected.contains(subConnected.get(i)) ) {
							connected.add(subConnected.get(i));
						}
					}
				}
			}
		}
		return connected;
	}

	public void render() {
		if(!visible){return;}

		int i, j;

		if ( this.polygon != null ) {
			this.polygon.render();
		}

		// Get list of selected polygons and draw graph edges
		ArrayList<Integer> selected = new ArrayList<Integer>();
		boolean polySelected = false;
		// no mouse hover effect during point location
		if ( pointSelected == null ) {
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
								findConnectedEdges(
								lgraphMesh.polygons.get(
									messages.get(i).v), true));
						/*
						selectedEdges.addAll(
								findConnectedParentEdges(
								lgraphMesh.polygons.get(
									messages.get(i).v), true));
						*/
					}
					selected.add(messages.get(i).v);
				}
			}
		}

		// draw edges visible due to mouse hover selection of nodes
		if ( polySelected ) {
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

		// draw kpMesh polygons in current layer
		Polygon poly;
		for ( i = 0; i < this.kpLayers.get(layerToDraw).size(); i++ ) {
			poly = this.kpLayers.get(layerToDraw).get(i);
			// always 'highlight' the root triangle
			if ( poly.id == root.id ) {
				poly.selected = false;
			}
			poly.render();
		}

		// draw graph edges
		GraphEdge edge;
		for ( i = 0; i < this.edges.get(layerToDraw).size(); i++ ) {
			edge = this.edges.get(layerToDraw).get(i);
			edge.render();
			if (edge.start != null) {
				selected.add(edge.start.id);
			}
			if (edge.end != null) {
				selected.add(edge.end.id);
			}
		}

		// draw all polygons in layered graph mesh
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			polyId = iterator.next();
			// true/false flipped on selected to fill polygons with color
			// when in focus
			if ( selected.contains(polyId) ||
					lgraphMesh.polygons.get(polyId).parentId == polygon.id ){
				lgraphMesh.polygons.get(polyId).selected = false;
			} else {
				lgraphMesh.polygons.get(polyId).selected = true;
			}

			lgraphMesh.polygons.get(polyId).render();
		}

		// draw selected point that is currently being evaluated
		if ( pointSelected != null ) {
			pointSelected.render();
		} else if( inMeshBounds( mouseX, mouseY ) ) {
			// if no point selected, draw ellipse at mouse tip
			stroke(color(0));
			fill(color(0));
			ellipse( mouseX, mouseY, 10, 10);
		}
	}

	public boolean inMeshBounds( float x, float y ) {
		return root.containsPoint(x, y);
	}

	public void onMousePress() {
		if ( visible && pointSelected == null ) {
			evaluatePoint( mouseX, mouseY );
		}
	}

	public void mouseUpdate() {
		if(!visible){return;}
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if (lgraphMesh.polygons.get(polyId).pickColor == c) {
				Message msg = new Message();
				msg.k = MSG_TRIANGLE;
				msg.v = polyId;
				messages.add(msg);
			}
		}
	}

}

class GraphEdge {

	Polygon start;
	Polygon end;

	public GraphEdge( Polygon start, Polygon end ) {
		this.start = start;
		this.end = end;
	}

	public void render() {
		if ( start != null && end  != null ) {
			fill(color(0));
			line( start.getCenter().x, start.getCenter().y,
					end.getCenter().x, end.getCenter().y);
		}
	}

	public boolean equals(Object obj) {
		if ( obj instanceof GraphEdge ) {
			GraphEdge other = (GraphEdge) obj;
			return ((other.start.id == start.id && other.end.id == end.id) || (
						other.start.id == end.id && other.end.id == start.id));
		}
		return false;
	}

}
