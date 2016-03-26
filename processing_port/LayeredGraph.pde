class LayeredGraph extends View {

	int numLayers;
	float ydiv;
	HashMap<Integer, ArrayList<Polygon>> shapes;
	HashMap<Integer, color> colors;
	boolean finalized = false;

	public LayeredGraph(int numLayers, float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.numLayers = numLayers;
		this.ydiv = h / numLayers;
		this.shapes = new HashMap<Integer, ArrayList<Polygon>>();
		this.colors = new HashMap<Integer, color>();
		for (int i = 0; i < numLayers; i++) {
			shapes[i] = new ArrayList<Polygon>();
			colors[i] = color(random(255), random(255), random(255));
		}
	}

	public void addShape(int layer, Polygon shape) {
		shapes[layer].add(shape);
		finalized = false;
	}

	public void render() {
		if (!finalized) {
			finalizeGraph();
		}
		// draw view background 
		fill(0);
		rect(x1, y1, w, h);
		for (int i = 0; i < numLayers; i++) {
			// draw layer background
			fill(colors[i]);
			rect(x1, h - (ydiv*(i+1)), w, ydiv);
			// draw layer shapes
			for (int j = 0; j < shapes[i].size(); j++) {
				shapes[i].get(j).render();
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
			xdiv = w / shapes[i].size();
			for (j = 0; j < shapes[i].size(); j++) {
				xpos = (xdiv * j) + (xdiv/2);
				shapes[i].get(j).move(new PolyPoint(xpos, ypos));
				// calculate scaling ratio for this shape
				xratio = xdiv / shapes[i].get(j).getWidth(); 
				yratio = ydiv / shapes[i].get(j).getHeight(); 
				if (xratio < minRatio) {
					minRatio = xratio;
				}
				if (yratio < minRatio) {
					minRatio = yratio;
				}
			}
		}
		// scale polygons with overall min scale to maintain relative sizes	
		for (i = 0; i < numLayers; i ++) {
			for (j = 0; j < shapes[i].size(); j++) {
				//shapes[i].get(j).scale(minRatio);
			}
		}

		finalized = true;
	}

}
