
class Polygon {

	int id;
	int parentId;
	int childId;

	ArrayList<PolyPoint> points;
	color cFill;
	color cStroke;
	color cHighlight;
	float cAlpha;
	boolean selected;
	boolean finalized;

	PolyPoint centerPoint;

	ArrayList<Polygon> holes;

	ArrayList<Animation> animations;

	public Polygon(int id) {
		this.id = id;
		this.parentId = -1;
		this.childId = -1;

		this.points = new ArrayList<PolyPoint>();
		this.cFill = color(random(255), random(255), random(255));
		this.cStroke = color(0);
		this.cHighlight = color(255);
		this.cAlpha = 255;
		this.selected = false;
		this.centerPoint = null;

		this.finalized = false;
		this.moveFinished = true;
		this.scaleFinished = true;
		this.newPosition = null;
		this.newScale = 1.0;

		this.holes = new ArrayList<Polygon>();
		this.animations = new ArrayList<Animation>();
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
		copy.cAlpha = this.cAlpha;
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

	public boolean containsPolygon( Polygon poly ) {
		boolean contained = true;
		for ( int i = 0; i < poly.points.size(); i++ ) {
			contained =
				this.containsPoint(poly.points.get(i).x, poly.points.get(i).y);
			if( !contained ) {
				break;
			}
		}
		return contained;
	}

	public boolean containsPoint( float x, float y ) {
		// Ray crossing algorithm, based on implementation described in
		// Computation Geometry in C, 2nd Edition, J. O'Rourke
		int i, j;

		ArrayList<PolyPoint> originCentered = new ArrayList<PolyPoint>();
		// shift so that the point in question is the origin
		// done for algorithm clarity
		for ( i = 0; i < this.points.size(); i++ ) {
			originCentered.add( this.points.get(i).copy() );
			originCentered.get( i ).move(
					originCentered.get(i).x - x,
					originCentered.get(i).y - y );
		}

		int crossings = 0;
		for ( i = 0; i < originCentered.size(); i++ ) {
			j = ( i + originCentered.size() - 1 ) % originCentered.size();
			// if the edge straddles the x axis
			if ( ( (originCentered.get(i).y > 0) &&
						(originCentered.get(j).y <= 0) ) ||
					( (originCentered.get(j).y > 0) &&
					  (originCentered.get(i).y <= 0) )) {
				// compute intersection with x axis
				x = ((originCentered.get(i).x * originCentered.get(j).y -
						originCentered.get(j).x * originCentered.get(i).y) /
					(originCentered.get(j).y - originCentered.get(i).y));
				if ( x > 0 ) {
					crossings += 1;
				}
			}
		}

		// polygon contains point it an odd number of crossings found
		return (( crossings % 2 ) == 1);
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
				if ( DEBUG) {
				console.log("Added hole of size " + hole_contour.length);
				}
				swctx.addHole(hole_contour);
			}
		}
		// triangulate, thanks to poly2tri
		swctx.triangulate();
		var p2t_tris = swctx.getTriangles();
		for ( var i = 0; i < p2t_tris.length; i++ ) {
			Polygon tri = compGeoHelper.createPoly();
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
				fill(cHighlight, cAlpha);
			} else {
				fill(cFill, cAlpha);
			}

			for (int i = 0; i < points.size(); i++) {
				vertex(points.get(i).x, points.get(i).y);
			}
			// draw back to 1st vertex
			vertex(points.get(0).x, points.get(0).y);
			endShape();

			// draw shape onto pickbuffer
			pickbuffer.beginShape();
			//pickbuffer.stroke(color(this.id));
			pickbuffer.noStroke();
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
		if ( animations.size() > 0 ) {
			// apply all animations in order they were added
			for ( int i = 0; i < animations.size(); i++ ) {
				animations.get(i).apply(this);
			}
			// remove any animations that are now complete
			for ( int i = animations.size() - 1; i >= 0; i-- ) {
				if( animations.get(i).isComplete ) {
					animations.remove(i);
				}
			}
		}
	}

	public void animateMove( float x, float y ) {
		MoveAnimation animation = new MoveAnimation(x, y);
		this.animations.add(animation);
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

	public void animateScale( float scaleRatio, int duration ) {
		ScaleAnimation animation = new ScaleAnimation(scaleRatio);
		this.animations.add(animation);
	}

	public void scale( float scaleRatio, float percentToScale ) {
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

	public String valueOf() {
		return this.x + " " + this.y;
	}

	public boolean equals(Object obj) {
		return this.valueOf() == obj.valueOf();
	}

}

class Animation {

	boolean isComplete;
	float animationStep;
	int animationDuration;

	int animationFixedStep;
	int animationRelativeStep;

	Polygon polygon;

	public Animation() {
		this.isComplete = false;
		this.animationStep = 0;
		// minus steps to prevent jagged end to animation
		this.animationDuration = sceneControl.sceneDuration-2;
	}

	public void apply() {
		animationStep++;
		if ( animationStep >= animationDuration ) {
			isComplete = true;
		}
	}
}

class MoveAnimation extends Animation {

	int x;
	int y;

	public MoveAnimation(int x, int y) {
		super();
		this.x = x;
		this.y = y;
	}

	public void apply( Polygon poly ) {
		super.apply();
		poly.move(x, y, 1.0 / ( animationDuration - animationStep + 1) );
		PolyPoint center = poly.getCenter();
	}
}

class ScaleAnimation extends Animation {

	float scale;

	public ScaleAnimation(float scale) {
		super();
		this.scale = scale;
	}

	public void apply( Polygon poly ) {
		super.apply();
		float val1 = 1 - ((1.0 - scale)/animationDuration) * (animationStep+1);
		float val2 = 1 - ((1.0 - scale)/animationDuration) * (animationStep);
		poly.scale(val1 / val2);
	}
}


