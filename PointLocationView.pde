class PointLocationView extends View {

	Polygon polygon;
	LayeredMesh kpMesh;
	LayeredMesh lgraphMesh;
	ArrayList<ArrayList<Integer>> layers;
	ArrayList<ArrayList<Polygon>> kpLayers;
	ArrayList<ArrayList<Polygon>> graphLayers;

	ArrayList<ArrayList<GraphEdge>> edges;

	int layerToDraw;

	ArrayList<Integer> containingPolygons;
	int containingPathToDraw = 0;

	PolyPoint pointSelected;

	public PointLocationView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.polygon = null;
		this.kpMesh = null;
		this.lgraphMesh = null;

		this.layers = new ArrayList<ArrayList<Integer>>();
		this.kpLayers = new ArrayList<ArrayList<Polygon>>();
		this.edges = new ArrayList<ArrayList<GraphEdge>>();

		this.containingPolygons = new ArrayList<Integer>();
		this.layerToDraw = 0;

		this.pointSelected = null;
	}

	public void setPolygon( Polygon poly ) {
		this.polygon = poly;
	}

	public void setMesh( LayeredMesh kpMesh, LayeredMesh lgraphMesh ) {
		if ( this.kpMesh != null ) {
			this.kpMesh.clear();
		}
		if ( this.lgraphMesh != null ) {
			this.lgraphMesh.clear();
		}

		this.kpMesh = kpMesh.copy();
		this.lgraphMesh = lgraphMesh.copy();

		resetSearch();
	}

	private void resetSearch() {
		this.layerToDraw = 0;
		this.layers.clear();
		this.layers.add( kpMesh.getVisiblePolygonIdsByLayer(
					kpMesh.layers.size() - 1) );
		this.kpLayers.clear();
		this.kpLayers.add(
				kpMesh.getPolygonsById(
				kpMesh.getVisiblePolygonIdsByLayer(kpMesh.layers.size() - 1)));
		this.edges.clear();
		this.edges.add( new ArrayList<ArrayList<GraphEdge>>() );
		this.containingPolygons.clear();

	}

	public boolean evaluatePoint( float x, float y ) {
		if( !inMeshBounds(x, y) ) {
			// only evaluate points placed inside the outer triangle
			return false;
		}

		this.pointSelected = new PolyPoint(x , y);

		// clear layers from previously evaluated point
		this.layers.clear();
		this.kpLayers.clear();
		this.edges.clear();

		// generate array of visible polygons per search layer
		ArrayList<Polygon> visiblePolys =
			kpMesh.getPolygonsById(
				kpMesh.getVisiblePolygonIdsByLayer(kpMesh.layers.size() - 1));

		ArrayList<GraphEdge> pathEdges = new ArrayList<GraphEdge>();
		pathEdges.add(
				new GraphEdge(
					null,
					lgraphMesh.polygons.get(visiblePolys.get(0).id)));
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

					this.containingPolygons.add( visiblePoly.id );
					if ( pathEdges.size() > 0 ) {
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
			if ( this.kpLayers.size() > 0 ) {
				this.kpLayers.add( visiblePolys );
				this.edges.add( pathEdges );
			}

			// add layer containing true path polygons and next layer edges
			//this.kpLayers.add( visiblePolys );
			//this.edges.add( nextEdges );
			//this.edges.get(this.edges.size() - 1).addAll(pathEdges);

			// add layer containing next layer polygons and edges
			this.kpLayers.add( nextLayer );
			this.edges.add(nextEdges);
			this.edges.get(this.edges.size() - 1).addAll(pathEdges);

			// set next layer as currently visible polygons
			visiblePolys = nextLayer;
		} while ( visiblePolys.size() > 0 )
		console.log(this.kpLayers.size());
		console.log(this.edges.size());
	}

	public boolean nextLevel() {
		this.layerToDraw += 1;
		if ( this.layerToDraw >= this.kpLayers.size() ) {
			this.pointSelected = null;
			resetSearch();
			return false;
		}
		return true;
	}

	public ArrayList<GraphEdge> drawConnectedPolygons(
			Polygon poly, boolean recurse ) {
		ArrayList<GraphEdge> connected = new ArrayList<GraphEdge>();
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
					connected.addAll(
							drawConnectedPolygons(
								lgraphMesh.polygons.get(polyId), recurse ));
				}
			}
		}
		return connected;
	}

	public void render() {
		int i, j;

		if ( this.polygon != null ) {
			this.polygon.render();
		}

		// Get list of selected polygons and draw graph edges
		ArrayList<Integer> selected = new ArrayList<Integer>();
		// no mouse hover effect during point location
		if ( pointSelected == null ) {
			ArrayList<GraphEdge> connected = new ArrayList<GraphEdge>();
			for ( i = 0; i < messages.size(); i++) {
				if (messages.get(i).k == MSG_TRIANGLE) {
					connected.addAll(drawConnectedPolygons(
							lgraphMesh.polygons.get(messages.get(i).v), true));
					selected.add(messages.get(i).v);
				}
			}
			for ( i = 0; i < connected.size(); i++ ) {
				connected.get(i).render();
				if (connected.get(i).start != null) {
					selected.add(connected.get(i).start.id);
				}
				if (connected.get(i).end != null) {
					selected.add(connected.get(i).end.id);
				}
			}
		} else {
			selected.add( kpLayers.get(0).get(0).id );
		}

		// draw kpMesh polygons in current layer
		Polygon poly;
		for ( i = 0; i < this.kpLayers.get(layerToDraw).size(); i++ ) {
			poly = this.kpLayers.get(layerToDraw).get(i);
			poly.render();
		}
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
			if ( selected.contains(polyId) ){
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
		return kpMesh.polygons.get(layers.get(0).get(0)).containsPoint(x, y);
	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i;
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if (color(polyId) == c) {
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

}
