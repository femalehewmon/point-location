class PointLocationView extends View {

	Polygon polygon;
	LayeredMesh kpMesh;
	LayeredMesh lgraphMesh;
	ArrayList<ArrayList<Integer>> layers;
	int layerToDraw;

	PolyPoint pointSelected;

	public PointLocationView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.polygon = null;
		this.kpMesh = null;
		this.lgraphMesh = null;

		this.layers = new ArrayList<ArrayList<Integer>>();
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
		kpMesh.polygons.get(this.layers.get(0).get(0)).selected = false;
		console.log("CFILL OF MAIN POLYGON");
		console.log(kpMesh.polygons.get(this.layers.get(0).get(0)));
	}

	public boolean evaluatePoint( float x, float y ) {
		if( !inMeshBounds(x, y) ) {
			// only evaluate points placed inside the outer triangle
			return false;
		} else {
			kpMesh.polygons.get(this.layers.get(0).get(0)).selected = true;
		}

		this.pointSelected = new PolyPoint(x , y);

		// clear layers from previously evaluated point
		this.layers.clear();

		// generate array of visible polygons per search layer
		ArrayList<Integer> visiblePolys =
			kpMesh.getVisiblePolygonIdsByLayer(kpMesh.layers.size() - 1);

		int i;
		Polygon visiblePoly;
		do {
			this.layers.add( visiblePolys );
			ArrayList<Integer> nextLayer = new ArrayList<Integer>();
			for ( i = 0; i < visiblePolys.size(); i++ ) {
				visiblePoly = kpMesh.polygons.get(visiblePolys.get(i));
				if ( visiblePoly.containsPoint( x, y ) ){
					Iterator<Integer> iterator =
						kpMesh.polygons.keySet().iterator();
					while( iterator.hasNext() ) {
						Integer polyId = iterator.next();
						if ( kpMesh.polygons.get(polyId).childId ==
								visiblePoly.parentId ) {
							if(kpMesh.polygons.get(polyId).containsPoint(x, y)){
								kpMesh.polygons.get(polyId).selected = true;
							} else {
								kpMesh.polygons.get(polyId).selected = false;
							}
							nextLayer.add( polyId );
						}
					}
				}
			}
			visiblePolys = nextLayer;
		} while ( visiblePolys.size() > 0 )
		this.layers.add( visiblePolys );
	}

	public boolean nextLevel() {
		this.layerToDraw += 1;
		if ( this.layerToDraw >= this.layers.size() ) {
			this.pointSelected = null;
			resetSearch();
			return false;
		}
		return true;
	}

	public void drawConnectedPolygons( Polygon poly, boolean recurse ) {
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( poly.parentId == lgraphMesh.polygons.get(polyId).childId ) {
				line(poly.getCenter().x,
						poly.getCenter().y,
						lgraphMesh.polygons.get(polyId).getCenter().x,
						lgraphMesh.polygons.get(polyId).getCenter().y);
				if ( recurse ) {
					drawConnectedPolygons( lgraphMesh.polygons.get(polyId),
						   recurse	);
				}
			}
			/*
			else if (poly.childId == lgraphMesh.polygons.get(polyId).parentId){
				line( lgraphMesh.polygons.get(polyId).getCenter().x,
						lgraphMesh.polygons.get(polyId).getCenter().y,
						poly.getCenter().x,
						poly.getCenter().y);
			}
			*/
		}
	}

	public void render() {
		int i, j;

		if ( this.polygon != null ) {
			this.polygon.render();
		}

		// Get list of selected polygons and draw graph edges
		ArrayList<Polygon> connected = new ArrayList<Polygon>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				drawConnectedPolygons(
						lgraphMesh.polygons.get(messages.get(i).v), true);
			}
		}

		ArrayList<Integer> selectedPolys = new ArrayList<Integer>();
		for ( i = 0; i <= layerToDraw; i++ ) {
			for ( j = 0; j < this.layers.get(i).size(); j++ ) {
				if( this.kpMesh.polygons.get(
						this.layers.get(i).get(j)).selected) {
					selectedPolys.add(this.layers.get(i).get(j));
					if ( i == layerToDraw ) {
						drawConnectedPolygons(lgraphMesh.polygons.get(
									this.layers.get(i).get(j)), false);
					}
				}
			}
		}

		// draw all polygons in layered graph mesh
		Iterator<Integer> iterator = lgraphMesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			if ( selectedPolys.contains(polyId) ) {
				lgraphMesh.polygons.get(polyId).selected = true;
			} else {
				lgraphMesh.polygons.get(polyId).selected = false;
			}
			lgraphMesh.polygons.get(polyId).render();
		}

		// draw polygons in current layer
		for ( j = 0; j < this.layers.get(layerToDraw).size(); j++ ) {
			Polygon poly = this.kpMesh.polygons.get(
					this.layers.get(layerToDraw).get(j)).render();
		}

		// draw selected point that is currently being evaluated
		if ( pointSelected != null ) {
			pointSelected.render();
		} else if( inMeshBounds( mouseX, mouseY ) ) {
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
