class PointLocationView extends View {

	LayeredMesh mesh;
	ArrayList<ArrayList<Integer>> layers;
	int layerToDraw;

	PolyPoint pointSelected;

	public PointLocationView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.layers = new ArrayList<ArrayList<Integer>>();
		this.mesh = null;
		this.layerToDraw = 0;
		this.pointSelected = null;
	}

	public void setMesh( LayeredMesh mesh ) {
		if ( this.mesh != null ) {
			this.mesh.clear();
		}
		this.mesh = mesh.copy();
		resetSearch();
	}

	private void resetSearch() {
		this.layerToDraw = 0;
		this.layers.clear();
		this.layers.add( mesh.getVisiblePolygonIdsByLayer(
					mesh.layers.size() - 1) );
	}

	public boolean evaluatePoint( float x, float y ) {
		if(!mesh.polygons.get(this.layers.get(0).get(0)).containsPoint(x, y)){
			// only evaluate points placed inside the outer triangle
			return false;
		}

		this.pointSelected = new PolyPoint(x , y);

		// clear layers from previously evaluated point
		this.layers.clear();

		// generate array of visible polygons per search layer
		ArrayList<Integer> visiblePolys =
			mesh.getVisiblePolygonIdsByLayer(mesh.layers.size() - 1);

		int i;
		Polygon visiblePoly;
		do {
			this.layers.add( visiblePolys );
			ArrayList<Integer> nextLayer = new ArrayList<Integer>();
			for ( i = 0; i < visiblePolys.size(); i++ ) {
				visiblePoly = mesh.polygons.get(visiblePolys.get(i));
				if ( visiblePoly.containsPoint( x, y ) ){
					Iterator<Integer> iterator =
						mesh.polygons.keySet().iterator();
					while( iterator.hasNext() ) {
						Integer polyId = iterator.next();
						if ( mesh.polygons.get(polyId).childId ==
								visiblePoly.parentId) {
							if(mesh.polygons.get(polyId).containsPoint(x, y)){
								mesh.polygons.get(polyId).selected = true;
							} else {
								mesh.polygons.get(polyId).selected = false;
							}
							nextLayer.add( polyId );
						}
					}
				}
			}
			visiblePolys = nextLayer;
		} while ( visiblePolys.size() > 0 )
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

	public void render() {
		int i, j;

		// highlight all selected layers to current point
		for ( i = 0; i <= layerToDraw; i++ ) {
			for ( j = 0; j < this.layers.get(i).size(); j++ ) {
				if( this.mesh.polygons.get(
						this.layers.get(i).get(j)).selected) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = this.layers.get(i).get(j);
					messages.add(msg);
				}

			}
		}

		// draw polygons in current layer
		for ( j = 0; j < this.layers.get(layerToDraw).size(); j++ ) {
			Polygon poly = this.mesh.polygons.get(
					this.layers.get(layerToDraw).get(j)).render();
		}

		// draw selected point that is currently being evaluated
		if ( pointSelected != null ) {
			pointSelected.render();
		}
	}

}
