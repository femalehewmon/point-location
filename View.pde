class View {

	float x1;
	float y1;
	float x2;
	float y2;
	float w;
	float h;
	float xCenter;
	float yCenter;
	color cFill;
	boolean visible;
	boolean finalized;
	boolean initialized;

	public View(float x1, float y1, float x2, float y2) {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
		this.w = x2 - x1;
		this.h = y2 - y1;
		this.xCenter = x1 + (w / 2.0);
		this.yCenter = y1 + (h / 2.0)
		this.cFill = color(0);
		this.visible = true;
		this.finalized = true;
		this.initialized = true;
	}

	public void render() {
		// draw background of view
		fill(cFill);
		rect(x1, y1, w, h);
	}

	public void setBackgroundColor(color cFill) {
		this.cFill = cFill;
	}

}
