class LayeredGraphView extends View {

	LayeredMesh mesh;

	int layerToDraw;
	ArrayList<ArrayList<Integer>> layers;

	float yborder;
	float ydiv;

	public LayeredGraphView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.cFill = color(255);

		this.mesh = null;
		this.layers = new ArrayList<ArrayList<Integer>>();
		this.layerToDraw = 0;

		this.yborder = 40;
		this.ydiv = this.h - this.yborder;
	}

	public void setMesh( LayeredMesh mesh ) {
		this.layers.clear();
		if ( this.mesh != null ) {
			this.mesh.clear();
		}

		this.mesh = mesh.copy();
		this.layers = flattenMesh();
	}

	private ArrayList<ArrayList<Integer>> flattenMeshAddOnCreation() {
		int i, j;
		ArrayList<ArrayList<Integer>> flattenedMesh =
			new ArrayList<ArrayList<Integer>>();

		// set layer count
		this.ydiv = (h - yborder) / this.mesh.layers.size();

		// create flattened layer list and
		// move polygons to final positions and scales in layered graph
		int subPolyCount;
		ArrayList<Integer> subPolys;
		Polygon poly;
		float xdiv;
		float xpos, ypos;
		float minRatio = -1;
		float xratio, yratio;
		for (i = 0; i < this.mesh.layers.size(); i ++) {
			// add new layer to flattened mesh as visual buffer
			// used to maintain same layering structure as kpMeshView
			if ( i > 0 ) {
				flattenedMesh.add( new ArrayList<Integer> );
			}

			// calculate vertical center position for polygons on this layer
			ypos = (h - (yborder / 2.0)) - (ydiv * (i+1)) + (ydiv/2);
			// calculate horizontal division for all polygons on this layer
			int polyCount = 0;
			for( j = 0; j < mesh.layers.get(i).subLayers.size(); j++ ) {
				polyCount += mesh.layers.get(i).subLayers.get(j).
					getPolygonsAddedToLayer().size();
			}
			xdiv = w / (float)(polyCount);

			subPolyCount = 0;
			for (j = 0; j < mesh.layers.get(i).subLayers.size(); j++) {

				minRatio = -1;
				subPolys =
					mesh.layers.get(i).subLayers.get(j).getPolygonsAddedToLayer();
				for ( k = 0; k < subPolys.size(); k++ ) {
					// calculate position in layer of graph for this polygon
					xpos = x1 + (xdiv * subPolyCount) + (xdiv/2.0);

					// setup future partial move on render
					poly = mesh.polygons.get(subPolys.get(k));
					//poly.animateMove( xpos, ypos, sceneControl.SCENE_DURATION);
					poly.move( xpos, ypos );

					if ( minRatio == -1 || minRatio > ydiv / poly.getHeight()) {
						minRatio = (ydiv) / poly.getHeight();
					}
					if ( minRatio == -1 || minRatio > xdiv / poly.getWidth() ) {
						minRatio = (xdiv) / poly.getWidth();
					}

					mesh.polygons.put( subPolys.get(k), poly );
					subPolyCount++;
				}

				// scale polygons with minRatio from layer
				for ( k = 0; k < subPolys.size(); k++ ) {
					poly = mesh.polygons.get(subPolys.get(k));
					poly.scale( minRatio );
					//poly.animateScale( minRatio, sceneControl.SCENE_DURATION );
					mesh.polygons.put( subPolys.get(k), poly );
				}

				// add list of sublayer polygons to graph levels to draw
				flattenedMesh.add(subPolys);
			}
		}

		return flattenedMesh;
	}

	private ArrayList<ArrayList<Integer>> flattenMesh() {
		int i, j;
		ArrayList<ArrayList<Integer>> flattenedMesh =
			new ArrayList<ArrayList<Integer>>();

		// set layer count
		this.ydiv = (h - yborder) / (this.mesh.layers.size());

		// create flattened layer list and
		// move polygons to final positions and scales in layered graph
		int subPolyCount;
		ArrayList<Integer> subPolys;
		Polygon poly;
		float xdiv;
		float xpos, ypos;
		float minRatio = -1;
		float xratio, yratio;
		for (i = 0; i < this.mesh.layers.size(); i ++) {
			// add new layer to flattened mesh as visual buffer
			// used to maintain same layering structure as kpMeshView
			if ( i > 0 ) {
				flattenedMesh.add( new ArrayList<Integer> );
			}

			// calculate vertical center position for polygons on this layer
			ypos = (h - (yborder / 2.0)) - (ydiv * (i)) + (ydiv/2);
			// calculate horizontal division for all polygons on this layer
			int polyCount = 0;
			for( j = 0; j < mesh.layers.get(i).subLayers.size(); j++ ) {
				polyCount += mesh.layers.get(i).subLayers.get(j).
					getPolygonsRemovedFromLayer().size();
			}
			xdiv = w / (float)(polyCount);

			subPolyCount = 0;
			for (j = 0; j < mesh.layers.get(i).subLayers.size(); j++) {

				minRatio = -1;
				subPolys =
					mesh.layers.get(i).subLayers.get(j).
					getPolygonsRemovedFromLayer();

				for ( k = 0; k < subPolys.size(); k++ ) {
					// calculate position in layer of graph for this polygon
					xpos = x1 + (xdiv * subPolyCount) + (xdiv/2.0);

					// setup future partial move on render
					poly = mesh.polygons.get(subPolys.get(k));
					//poly.animateMove( xpos, ypos, sceneControl.SCENE_DURATION);
					poly.move( xpos, ypos );

					if ( minRatio == -1 || minRatio > ydiv / poly.getHeight()) {
						minRatio = (ydiv) / poly.getHeight();
					}
					if ( minRatio == -1 || minRatio > xdiv / poly.getWidth() ) {
						minRatio = (xdiv) / poly.getWidth();
					}

					mesh.polygons.put( subPolys.get(k), poly );
					subPolyCount++;
				}

				// scale polygons with minRatio from layer
				for ( k = 0; k < subPolys.size(); k++ ) {
					poly = mesh.polygons.get(subPolys.get(k));
					poly.scale( minRatio );
					//poly.animateScale( minRatio, sceneControl.SCENE_DURATION );
					mesh.polygons.put( subPolys.get(k), poly );
				}

				// add list of sublayer polygons to graph levels to draw
				flattenedMesh.add(subPolys);
			}
		}

		// add final full outer triangle to flattenedMesh
		subPolys =
			mesh.getVisiblePolygonIdsByLayer(mesh.layers.size() - 1);
		ypos = (h - (yborder / 2.0)) - (ydiv * mesh.layers.size()) + (ydiv/2);
		// calculate position in layer of graph for this polygon
		xpos = x1 + (w / 2.0);

		// setup future partial move on render
		poly = mesh.polygons.get(subPolys.get(0));
		poly.move( xpos, ypos );
		poly.resizeToHeight( ydiv );

		mesh.polygons.put( subPolys.get(0), poly );
		flattenedMesh.add(subPolys);

		return flattenedMesh;
	}

	public boolean nextLevel() {
		this.layerToDraw += 1;
		return this.layerToDraw < this.layers.size();
	}

	public void render() {
		//noStroke();
		//super.render(); // draw view background
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
			noStroke();
			fill(255);
			//fill(mesh.layerColors.get(i), 50);
			rect(x1, (h - yborder/2.0) - (ydiv*(i+1)), w, ydiv);
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
		// show pick buffer on button press
		//if (keyPressed) {
		//	image(pickbuffer, 0, 0);
		//}
	}

}
