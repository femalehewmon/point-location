class LayeredGraph extends View {

	int numLayers;
	HashMap<Integer, ArrayList<Polygon>> shapes;

	public LayeredGraph(int numLayers, float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.numLayers = numLayers;
		this.shapes = new HashMap<Integer, ArrayList<Polygon>>();
		for (int i = 0; i < numLayers; i++) {
			shapes[i] = new ArrayList<Polygon>();
		}
	}

	public void addShape(int layer, Polygon shape) {
		shapes[layer].add(shape);
	}

	public void render() {
		for (int i = 0; i < numLayers; i++) {
			// draw layer background
			fill(255, 0, 0);
			rect(this.x1, this.y1, this.w, this.h);
			// draw layer shapes
			for (int j = 0; j < shapes[i].size(); j++) {
				shapes[i].get(j).render();
			}
		}
	}

}
