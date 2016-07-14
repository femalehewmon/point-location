class PointLocationView extends View {

	LayeredMesh kpMesh;
	LayeredMesh lgraphMesh;
	ArrayList<ArrayList<Integer>> layers;
	int layerToDraw;

	PolyPoint pointSelected;

	public PointLocationView( float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);

		this.kpMesh = null;
		this.lgraphMesh = null;

		this.layers = new ArrayList<ArrayList<Integer>>();
		this.layerToDraw = 0;

		this.pointSelected = null;
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
	}

	public boolean evaluatePoint( float x, float y ) {
		if(!kpMesh.polygons.get(this.layers.get(0).get(0)).containsPoint(x, y)){
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

		ArrayList<Integer> selectedPolys = new ArrayList<Integer>();
		for ( i = 0; i <= layerToDraw; i++ ) {
			for ( j = 0; j < this.layers.get(i).size(); j++ ) {
				if( this.kpMesh.polygons.get(
						this.layers.get(i).get(j)).selected) {
					selectedPolys.add(this.layers.get(i).get(j));
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
		}
	}

}
