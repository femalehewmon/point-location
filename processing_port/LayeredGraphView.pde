class LayeredGraphView extends View {

	LayeredMesh mesh;

	int layerToDraw;
	ArrayList<ArrayList<Integer>> layers;

	float ydiv;

	public LayeredGraphView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);

		this.mesh = null;
		this.layers = new ArrayList<ArrayList<Integer>>();
		this.layerToDraw = 0;

		this.ydiv = this.h;
	}

	public void setMesh( LayeredMesh mesh ) {
		this.layers.clear();
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.layers = flattenMesh();
	}

	private ArrayList<ArrayList<Integer>> flattenMesh() {
		int i, j;
		ArrayList<ArrayList<Integer>> flattenedMesh =
			new ArrayList<ArrayList<Integer>>();

		// set layer count
		this.ydiv = h / this.mesh.layers.size();

		// create flattened layer list and
		// move polygons to final positions and scales in layered graph
		int subPolyCount;
		ArrayList<Integer> subPolys;
		Polygon poly;
		float xdiv;
		float xpos, ypos;
		float minRatio;
		float xratio, yratio;
		for (i = 0; i < this.mesh.layers.size(); i ++) {
			// add new layer to flattened mesh as visual buffer
			// used to maintain same layering structure as kpMeshView
			flattenedMesh.add( new ArrayList<Integer> );

			// calculate vertical center position for polygons on this layer
			ypos = h - (ydiv * (i+1)) + (ydiv/2);
			// calculate horizontal division for all polygons on this layer
			int polyCount = 0;
			for( j = 0; j < mesh.layers.get(i).subLayers.size(); j++ ) {
				polyCount += mesh.layers.get(i).subLayers.get(j).
					getPolygonsAddedToLayer().size();
			}
			xdiv = w / (float)(polyCount);

			subPolyCount = 0;
			for (j = 0; j < mesh.layers.get(i).subLayers.size(); j++) {

				subPolys =
					mesh.layers.get(i).subLayers.get(j).getPolygonsAddedToLayer();

				minRatio = -1;
				for ( k = 0; k < subPolys.size(); k++ ) {
					// calculate position in layer of graph for this polygon
					xpos = x1 + (xdiv * subPolyCount) + (xdiv/2.0);

					// setup future partial move on render
					poly = mesh.polygons.get(subPolys.get(k));
					poly.animateMove( xpos, ypos, sceneControl.SCENE_DURATION);

					// calculate scaling ratio for this shape
					xratio = xdiv / poly.getWidth();
					yratio = ydiv / poly.getHeight();
					if (xratio < minRatio || minRatio == -1) {
						minRatio = xratio;
					}
					if (yratio < minRatio || minRatio == -1) {
						minRatio = yratio;
					}

					mesh.polygons.put( subPolys.get(k), poly );
					subPolyCount++;
				}

				// add list of sublayer polygons to graph levels to draw
				flattenedMesh.add(subPolys);
			}
		}

		Iterator<Integer> iterator = mesh.polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			// setup future partial scale on render
			Integer polyId = iterator.next();
			poly = mesh.polygons.get( polyId );
			poly.animateScale( minRatio, sceneControl.SCENE_DURATION );
			mesh.polygons.put( polyId, poly );
		}

		return flattenedMesh;
	}

	public boolean nextLevel() {
		this.layerToDraw += 1;
		return this.layerToDraw < this.layers.size();
	}

	public void render() {
		super.render(); // draw view background
		int i, j, k;

		if (!finalized) {
			finalizeView();
		}
		// get list of selected polygons
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for ( i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		// draw layer backgrounds
		for ( i = 0; i < this.mesh.layers.size(); i++) {
			fill(color(255));
			rect(x1, h - (ydiv*(i+1)), w, ydiv);
		}

		// render polygons
		for ( i = 0; i < layerToDraw; i++ ) {
			for ( j = 0; j < this.layers.get(i).size(); j++ ) {
				if( selectedShapes.contains( this.layers.get(i).get(j) )) {
					mesh.polygons.get( layers.get(i).get(j) ).selected = true;
				} else {
					mesh.polygons.get( layers.get(i).get(j) ).selected = false;
				}
				mesh.polygons.get( layers.get(i).get(j) ).render();
			}
		}
	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		for (i = 0; i < this.layers.size(); i++) {
			for (j = 0; j < this.layers.get(i).size(); j++) {
				if (color( this.layers.get(i).get(j) ) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = this.layers.get(i).get(j);
					messages.add(msg);
				}
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
