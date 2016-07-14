
class Polygon {

	int id;
	int parentId;
	int childId;

	ArrayList<PolyPoint> points;
	color cFill;
	color cStroke;
	color cHighlight;
	boolean selected;
	boolean finalized;

	PolyPoint centerPoint;

	ArrayList<Polygon> holes;

	// used for animation
	PolyPoint moveToAnimate;
	boolean moveFinished;
	int moveStep;
	int moveDuration;
	float scaleToAnimate;
	boolean scaleFinished;
	int scaleStep;
	int scaleDuration;

	public Polygon(int id) {
		this.id = id;
		this.parentId = -1;
		this.childId = -1;

		this.points = new ArrayList<PolyPoint>();
		this.cFill = color(255);
		this.cStroke = color(0);
		this.cHighlight = color(0, 0, 255);
		this.selected = false;
		this.centerPoint = null;

		this.finalized = false;
		this.moveFinished = true;
		this.scaleFinished = true;
		this.newPosition = null;
		this.newScale = 1.0;

		this.holes = new ArrayList<Polygon>();
	}

	public Polygon copy() {
		// TODO: unable to do a non awkward constructor copy and
		// unsure of overriding clone in processing.js, thus copy
		Polygon copy = new Polygon(this.id);
		copy.id = this.id;
		copy.parentId = this.parentId;
		copy.childId = this.childId;
		copy.points = new ArrayList<PolyPoint>();
		for ( int i = 0; i < this.points.size(); i++ ) {
			copy.points.add(this.points.get(i).copy());
		}

		copy.cFill = this.cFill;
		copy.cStroke = this.cStroke;
		copy.cHighlight = this.cHighlight;
		copy.selected = this.selected;
		copy.centerPoint = null;

		copy.holes = new ArrayList<Polygon>();
		for ( int i = 0; i < this.holes.size(); i++ ) {
			copy.holes.add(this.holes.get(i).copy());
		}
		return copy;
	}

	public void addPoint(float x, float y) {
		this.points.add(new PolyPoint(x, y));
		this.centerPoint = null;
	}

	public void addHole(Polygon hole) {
		this.holes.add(hole);
	}

	ArrayList<Polygon> triangulate() {
		ArrayList<Polygon> triangles = new ArrayList<Polygon>();

		// use swctx to triangulate
		var contour = new Array();
		for(var i = 0; i < this.points.size(); i++){
			contour.push(new poly2tri.Point(points.get(i).x, points.get(i).y));
		}

		var swctx = new poly2tri.SweepContext(contour);

		// add holes if necessary
		if(holes.size() > 0){
			for (var i = 0; i < holes.size(); i++) {
				Polygon hole = holes.get(i);
				var hole_contour = new Array();
				for(var j = 0; j < hole.points.size(); j++){
					hole_contour.push(
						new poly2tri.Point(
							hole.points.get(j).x,
							hole.points.get(j).y));
				}
				console.log("Added hole of size " + hole_contour.length);
				swctx.addHole(hole_contour);
			}
		}
		// triangulate, thanks to poly2tri
		swctx.triangulate();
		var p2t_tris = swctx.getTriangles();
		for ( var i = 0; i < p2t_tris.length; i++ ) {
			Polygon tri = createPoly();
			tri.addPoint(p2t_tris[i].getPoint(0).x, p2t_tris[i].getPoint(0).y);
			tri.addPoint(p2t_tris[i].getPoint(1).x, p2t_tris[i].getPoint(1).y);
			tri.addPoint(p2t_tris[i].getPoint(2).x, p2t_tris[i].getPoint(2).y);
			triangles.add(tri);
		}

		// set parentId and color of all triangulated triangles
		for ( int i = 0; i < triangles.size(); i++ ) {
			triangles.get(i).parentId = this.id;
			triangles.get(i).cFill = this.cFill;
			triangles.get(i).cHighlight = this.cHighlight;
		}

		return triangles;
	}

	public void render( boolean renderVertices ) {
		if ( points.size() > 0 ) {
			update();

			// First, draw polygon
			beginShape();
			stroke(cStroke);
			if (selected) {
				fill(cHighlight);
			} else {
				fill(cFill);
			}

			for (int i = 0; i < points.size(); i++) {
				vertex(points.get(i).x, points.get(i).y);
			}
			// draw back to 1st vertex
			vertex(points.get(0).x, points.get(0).y);
			endShape();

			// draw shape onto pickbuffer
			pickbuffer.beginShape();
			pickbuffer.stroke(color(this.id));
			pickbuffer.fill(color(this.id));
			for (int i = 0; i < points.size(); i++) {
				pickbuffer.vertex(points.get(i).x, points.get(i).y);
			}
			pickbuffer.vertex(points.get(0).x, points.get(0).y);
			pickbuffer.endShape();

			// Now, draw vertices on top
			if ( renderVertices ) {
				PolyPoint currPoint;
				for ( int i = 0; i < points.size(); i++ ) {
					currPoint = points.get(i).render();
				}
			}
		}
	}

	public void render() {
		// by default, do not render vertices
		render( false );
	}

	private void update() {
		if ( !moveFinished ) {
			move( this.moveToAnimate.x, this.moveToAnimate.y,
					1 / (moveDuration - moveStep) );
			moveStep += 1;
			moveFinished = (moveStep >= moveDuration);
		}
		if ( !scaleFinished ) {
			scale( this.scaleToAnimate, 1.0 / (float)scaleDuration);
			scaleStep += 1;
			scaleFinished = (scaleStep >= scaleDuration);
		}
	}

	public void animateMove( float x, float y, int duration ) {
		this.moveToAnimate = new PolyPoint(x, y);
		this.moveFinished = false;
		this.moveStep = 0;
		this.moveDuration = duration;
	}

	public boolean move( float x, float y, float percentToMove ) {
		// percentToMove can be used for controlled animation
		PolyPoint currCenter = getCenter();
		PolyPoint newCenter = new PolyPoint(
				currCenter.x + ((x - currCenter.x) * percentToMove),
				currCenter.y + ((y - currCenter.y) * percentToMove));
		float xnew;
		float ynew;
		for (int i = 0; i < points.size(); i++ ) {
			xnew = newCenter.x +
				(points.get(i).x - currCenter.x);
			ynew = newCenter.y +
				(points.get(i).y - currCenter.y);
			points.get(i).move(xnew, ynew);
		}
		this.centerPoint = null;
	}

	public void move( float x, float y ) {
		move( x, y, 1.0 ); // move instantly
	}

	public void animateScale( float scaleRatio, int duration ) {
		this.scaleToAnimate = scaleRatio;
		this.scaleFinished = false;
		this.scaleStep = 0;
		this.scaleDuration = duration;
	}

	public void resizeToHeight( float height ) {
		if ( height < this.getHeight() ) {
			// scale down
			scale( height / this.getHeight() , 1.0);
		} else if ( height > this.getHeight() ) {
			// scale up
			scale( this.getHeight() / height , 1.0);
		}
	}

	public void resizeToWidth( float width ) {
		if ( width < this.getWidth() ) {
			// scale down
			scale( width / this.getWidth() , 1.0);
		} else if ( width > this.getWidth() ) {
			// scale up
			scale( this.getWidth() / width , 1.0);
		}
	}

	public void scale( float scaleRatio, float percentToScale ) {
		scaleRatio = 1.0 - ((1.0 - scaleRatio) * percentToScale);
		PolyPoint center = getCenter();
		float xnew;
		float ynew;
		for (int i = 0; i < points.size(); i++ ) {
			xnew = center.x +
			   ((points.get(i).x - center.x) * scaleRatio);
			ynew = center.y +
			   ((points.get(i).y - center.y) * scaleRatio);
			points.get(i).move(xnew, ynew);
		}
		this.centerPoint = null;
	}

	public void scale( float scaleRatio ) {
		scale( scaleRatio, 1.0 ); // scale instantly
	}

	public float getWidth() {
		float xMin = POSITIVE_INFINITY;
		float xMax = NEGATIVE_INFINITY;
		for (i = 0; i < points.size(); i++) {
			if (points.get(i).x < xMin) {
				xMin = points.get(i).x;
			}
			if (points.get(i).x > xMax) {
				xMax = points.get(i).x;
			}
		}
		return xMax - xMin;
	}

	public float getHeight() {
		float yMin = POSITIVE_INFINITY;
		float yMax = NEGATIVE_INFINITY;
		for (i = 0; i < points.size(); i++) {
			if (points.get(i).y < yMin) {
				yMin = points.get(i).y;
			}
			if (points.get(i).y > yMax) {
				yMax = points.get(i).y;
			}
		}
		return yMax - yMin;
	}

	public PolyPoint getCenter() {
		if ( this.centerPoint == null ) {
			int i, j;
			float cx;
			float cy;
			float area;
			for (i = 0; i < points.size(); i++) {
				j = i + 1;
				if (j >= points.size()) {
					j = 0; // wraparound for final operation
				}
				x0 = points.get(i).x;
				y0 = points.get(i).y;
				x1 = points.get(j).x;
				y1 = points.get(j).y;

				a = (x0*y1) - (x1*y0);
				cx += (x0 + x1)*a;
				cy += (y0 + y1)*a;
				area += a;
			}
			area *= 0.5;
			cx = cx / (6*area);
			cy = cy / (6*area);
			this.centerPoint = new PolyPoint(cx, cy);
		}
		return this.centerPoint;
	}

}

class PolyPoint {

	float x;
	float y;
	boolean selected;

	float size;
	color cFill;
	color cStroke;
	color cHighlight;

	public PolyPoint(float x, float y) {
		this.x = x;
		this.y = y;
		this.size = 10;
		this.cStroke = color(0);
		this.cFill = color(0);
		this.cHighlight = color(0, 0, 255);

		this.selected = false;
	}

	public PolyPoint copy() {
		// TODO: unable to do a non awkward constructor copy and
		// unsure of overriding clone in processing.js, thus copy
		PolyPoint copy = new PolyPoint(this.x, this.y);
		copy.size = this.size;
		copy.cStroke = this.cStroke;
		copy.cVertexFill = this.cVertexFill;
		copy.cVertexHighlight = this.cVertexHighlight;
		copy.selected = this.selected;
		return copy;
	}

	public void move(float xnew, float ynew) {
		this.x = xnew;
		this.y = ynew;
	}

	public void render() {
		stroke(cStroke);
		if ( selected ) {
			fill(cHighlight);
		} else {
			fill(cFill);
		}
		ellipse( this.x, this.y, this.size, this.size );
	}

	public boolean equals(Object obj) {
		if ( obj instanceof PolyPoint) {
			PolyPoint other = (PolyPoint) obj;
			return (other.x == x && other.y == y);
		} else if ( obj instanceof Vertex ) {
			Polygon other = (Vertex) obj;
			return (other.x == x && other.y == y);
		}
		return false;
	}

}

