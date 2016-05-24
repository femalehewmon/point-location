class LayeredGraphView extends View {

	int numLayers;
	float ydiv;
	HashMap<Integer, ArrayList<Polygon>> shapesByLayer;
	HashMap<Integer, color> colorsByLayer;
	boolean finalized = false;

	public LayeredGraphView(
			int numLayers, float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.numLayers = numLayers;
		this.ydiv = h / numLayers;
		this.shapesByLayer = new HashMap<Integer, ArrayList<Polygon>>();
		this.colorsByLayer = new HashMap<Integer, color>();
		for (int i = 0; i < numLayers; i++) {
			shapesByLayer[i] = new ArrayList<Polygon>();
			colorsByLayer[i] = color(random(255), random(255), random(255));
		}
	}

	public void addShape(int layer, Polygon shape) {
		shapesByLayer[layer].add(shape);
		finalized = false;
	}

	public void render() {
		super.render(); // draw view background
		if (!finalized) {
			finalizeGraph();
		}
		// get list of selected polygons
		ArrayList<Integer> selectedShapes = new ArrayList<Integer>();
		for (int i = 0; i < messages.size(); i++) {
			if (messages.get(i).k == MSG_TRIANGLE) {
				selectedShapes.add(messages.get(i).v);
			}
		}

		for (int i = 0; i < numLayers; i++) {
			// draw layer background
			fill(colorsByLayer[i]);
			rect(x1, h - (ydiv*(i+1)), w, ydiv);
			// draw layer shapes
			for (int j = 0; j < shapesByLayer[i].size(); j++) {
				if (selectedShapes.contains(shapesByLayer[i].get(j).id)) {
					shapesByLayer[i].get(j).selected = true;
				} else {
					shapesByLayer[i].get(j).selected = false;
				}
				shapesByLayer[i].get(j).render();
			}
		}
	}

	private void finalizeGraph() {
		int i, j;
		float xdiv;
		float xpos, ypos;
		float minRatio = POSITIVE_INFINITY;
		float xratio, yratio;
		// move polygons to final positions in layered graph
		for (i = 0; i < numLayers; i ++) {
			ypos = h - (ydiv * (i+1)) + (ydiv/2);
			xdiv = w / shapesByLayer[i].size();
			for (j = 0; j < shapesByLayer[i].size(); j++) {
				xpos = (xdiv * j) + (xdiv/2);
				shapesByLayer[i].get(j).move(new PolyPoint(xpos, ypos));
				// calculate scaling ratio for this shape
				xratio = xdiv / shapesByLayer[i].get(j).getWidth(); 
				yratio = ydiv / shapesByLayer[i].get(j).getHeight(); 
				if (xratio < minRatio) {
					minRatio = xratio;
				}
				if (yratio < minRatio) {
					minRatio = yratio;
				}
			}
		}
		// scale polygons with overall min scale to maintain relative sizes	
		println("Min scale ratio is " + minRatio);
		for (i = 0; i < numLayers; i ++) {
			for (j = 0; j < shapesByLayer[i].size(); j++) {
				shapesByLayer[i].get(j).scale(minRatio);
			}
		}

		finalized = true;
	}

	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		for (i = 0; i < numLayers; i++) {
			for (j = 0; j < shapesByLayer[i].size(); j++) {
				if (color(shapesByLayer[i].get(j).id) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = shapesByLayer[i].get(j).id;
					messages.add(msg);
				}
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}

}
