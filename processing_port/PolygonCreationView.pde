class PolygonCreationView extends View {

	Polygon polygon;

	public PolygonCreationView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.polygon = createPoly();
		this.finalized = false;
	}

	public void demo() {
		polygon.addPoint(w/4, h/8);
		polygon.addPoint(w/2, h/8);
		polygon.addPoint(w/3, h/4);
		polygon.addPoint(w/2-10, h/2-10);
		polygon.addPoint(w/4+10, h/2-10);
		this.finalized = true;
	}

	public void addPoint( float x, float y ) {
		this.polygon.addPoint(x, y);
	}

	public void render() {
		fill(this.cFill);
		rect(this.x1, this.y1, this.w, this.h);
		this.polygon.render();
	}

}
