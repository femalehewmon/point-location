class PolygonCreationView extends View {

	final int finalClickThreshold = 20;
	Polygon polygon;

	public PolygonCreationView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.polygon = createPoly();
		this.cFill = color(255, 255, 255);
		this.finalized = false;
	}

	public void demo() {
		this.polygon.addPoint( 253, 206 );
		this.polygon.addPoint( 482, 146 );
		this.polygon.addPoint( 535, 406 );
		this.polygon.addPoint( 328, 552 );
		this.polygon.addPoint( 374, 304 );
		this.polygon.addPoint( 125, 604 );
		this.polygon.addPoint( 63,  281 );
		this.polygon.addPoint( 224, 343 );
		this.polygon.addPoint( 128, 104 );
		this.finalized = true;
	}

	public void demoRect() {
		this.polygon.addPoint(250, 200);
		this.polygon.addPoint(500, 200);
		this.polygon.addPoint(500, 400);
		this.polygon.addPoint(250, 400);
		this.finalized = true;
	}

	public void addPoint( float x, float y ) {
		// TODO: validate that new point does not create non crossing polygon

		// If user clicks within range of first point, try to complete the poly
		if ( this.polygon.points.size() >= 2 ) {
			float xDiff = Math.abs(this.polygon.points.get(0).x - x);
			float yDiff = Math.abs(this.polygon.points.get(0).y - y);
			if ( xDiff < finalClickThreshold && yDiff < finalClickThreshold ) {
				this.finalized = true;
			} else {
				this.polygon.addPoint(x, y);
			}
		} else {
			this.polygon.addPoint(x, y);
		}
		console.log("add point " + x + " " + y);
	}

	public void render() {
		int i;
		fill(this.cFill);
		rect(this.x1, this.y1, this.w, this.h);

		if ( this.finalized ) {
			this.polygon.render( true );
		} else {
			// draw black lines between points
			fill(color(0));
			for ( i = 0; i < this.polygon.points.size() - 1; i++ ) {
				line(   this.polygon.points.get(i).x,
						this.polygon.points.get(i).y,
						this.polygon.points.get(i + 1).x,
						this.polygon.points.get(i + 1).y );
			}
			// draw points
			for ( i = 0; i < this.polygon.points.size(); i++ ) {
				this.polygon.points.get(i).render();
			}
		}
	}

}
