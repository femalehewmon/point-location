class View {

	float x1;
	float y1;
	float x2;
	float y2;
	float w;
	float h;
	color cFill;
	boolean visible;

	public View(float x1, float y1, float x2, float y2) {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
		this.w = x2 - x1;
		this.h = y2 - y1;
		this.cFill = color(0);
		this.visible = true;
	}

	public void render() {
		// draw background of view
		fill(cFill);
		rect(x1, y1, w, h);

		// clear pickbuffer
		/*
		pickbuffer.beginDraw();
		pickbuffer.fill(0);
		pickbuffer.rect(x1, y1, w, h);
		pickbuffer.endDraw();
		*/
	}

	public void setBackgroundColor(color cFill) {
		this.cFill = cFill;
	}

}
