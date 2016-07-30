class PolygonCreationView extends View {

	final int finalClickThreshold = 20;

	Polygon polygon;
	Polygon outerTri;

	public PolygonCreationView( float x1, float y1, float x2, float y2 ) {
		super(x1, y1, x2, y2);
		this.cFill = color(255, 255, 255);
		createOuterTriangle();
		reset();
	}

	public void reset() {
		setText(sceneControl.create);
		this.polygon = compGeoHelper.createPoly();
		this.polygon.cFill = color(random(255), random(255), random(255));
		this.polygon.finalized = false;
		this.finalized = false;
	}

	private void createOuterTriangle() {
		outerTri = compGeoHelper.createPoly();
		outerTri.cHighlight = color(255);
		outerTri.cFill = color(200, 200, 200);
		// +10 to give a slight border
		outerTri.addPoint( x1 + (w/4.0), y1 + 10 );
		outerTri.addPoint( xCenter - 10, y2 - 10 );
		outerTri.addPoint( x1 + 10, y2 - 10 );
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
		this.polygon.finalized = true;
	}

	public void demoRect() {
		this.polygon.addPoint(250, 200);
		this.polygon.addPoint(500, 200);
		this.polygon.addPoint(500, 400);
		this.polygon.addPoint(250, 400);
		this.polygon.finalized = true;
	}

	public void addPoint( float x, float y ) {
		// TODO: validate that new point does not create non crossing polygon

		// If user clicks within range of first point, try to complete the poly
		if ( this.polygon.points.size() >= 2 ) {
			float xDiff = Math.abs(this.polygon.points.get(0).x - x);
			float yDiff = Math.abs(this.polygon.points.get(0).y - y);
			if ( xDiff < finalClickThreshold && yDiff < finalClickThreshold ) {
				this.polygon.finalized = true;
			} else {
				this.polygon.addPoint(x, y);
			}
		} else {
			this.polygon.addPoint(x, y);
		}
	}

	public void onMousePress() {
		if ( visible && !finalized ) {
			if ( !polygon.finalized ) {
				addPoint( mouseX, mouseY );
			}
		}
	}

	public void centerAndResizePolygon() {
		float ratioToScalePoly = 1.0;
		Polygon tmp = this.polygon.copy();
		tmp.move( outerTri.getCenter().x, outerTri.getCenter().y );
		while( !this.outerTri.containsPolygon( tmp ) ){
			tmp.scale( 0.90 );
			ratioToScalePoly *= 0.90;
		}

		polygon.move( outerTri.getCenter().x, outerTri.getCenter().y );
		polygon.scale( ratioToScalePoly );
	}

	public void update() {
		if ( !this.finalized ) {
			if( !polygon.finalized ) {
				return true;
			} else {
				// polygon is finalized, center and resize
				setText(sceneControl.created);
				centerAndResizePolygon();
				this.finalized = true;
				return true;
			}
		}
		return false;
	}

	public void render() {
		if ( !visible) { return; }

		int i;
		if ( !this.polygon.finalized ) {

			// draw lines between points
			if ( this.polygon.points.size() > 0 ) {
				fill(color(0));
				for ( i = 0; i < this.polygon.points.size() - 1; i++ ) {
					line(   this.polygon.points.get(i).x,
							this.polygon.points.get(i).y,
							this.polygon.points.get(i + 1).x,
							this.polygon.points.get(i + 1).y );
				}
				// draw final black line between last point and mouse position
				line(this.polygon.points.get(i).x,
						this.polygon.points.get(i).y,
						mouseX, mouseY);
				// draw points
				for ( i = 0; i < this.polygon.points.size(); i++ ) {
					this.polygon.points.get(i).render();
				}
			}

			// draw point at mouse position
			stroke(color(0));
			fill(color(0));
			ellipse( mouseX, mouseY, 10, 10);

		} else {
			this.polygon.render();
		}
	}

}
