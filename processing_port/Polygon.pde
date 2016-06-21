
class Polygon {

	int id;
	ArrayList<PolyPoint> points;
	color cFill;
	color cStroke;
	color cHighlight;
	boolean selected;

	ArrayList<Polygon> holes;
	
	public Polygon(int id) {
		this.id = id;
		this.points = new ArrayList<PolyPoint>();
		this.cFill = color(random(255), random(255), random(255));
		this.cStroke = color(0);
		this.cHighlight = color(0, 0, 255);
		this.selected = false;

		this.holes = new ArrayList<Polygon>();
	}

	public void addPoint(float x, float y) {
		this.points.add(new PolyPoint(x, y));
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
				for(var j = 0; j < polyHolePoints.length; j++){
					hole_contour.push(
						new poly2tri.Point(hole.points[j].x, hole.points[j].y));
				}
				console.log("Added hole of size " + hole_contour.length);
				swctx.addHole(hole_contour);
			}
		}
		// triangulate, thanks to poly2tri
		swctx.triangulate();
		var p2t_tris = swctx.getTriangles();
		console.log(p2t_tris);
		for ( var i = 0; i < p2t_tris.length; i++) {
			console.log(p2t_tris[i]);
			Polygon tri = createPoly();
			tri.addPoint(p2t_tris[i].getPoint(0).x, p2t_tris[i].getPoint(0).y);
			tri.addPoint(p2t_tris[i].getPoint(1).x, p2t_tris[i].getPoint(1).y);
			tri.addPoint(p2t_tris[i].getPoint(2).x, p2t_tris[i].getPoint(2).y);
			triangles.add(tri);
		}

		return triangles;
	}

	public void render() {
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
	}

	public void move(PolyPoint newCenter) {
		PolyPoint currCenter = getCenter();	
		float xnew;
		float ynew;
		for (int i = 0; i < points.size(); i++ ) {
			xnew = newCenter.x + 
				(points.get(i).x - currCenter.x);
			ynew = newCenter.y + 
				(points.get(i).y - currCenter.y);
			points.get(i).move(xnew, ynew);
		}
		currCenter = getCenter();	
	}

	public void scale(float scaleRatio) {
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
	}

	public float getWidth() {
		float xMin = POSITIVE_INFINITY;
		float xMax = NEGATIVE_INFINITY;
		for (i = 0; i < points.size() - 1; i++) {
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
		for (i = 0; i < points.size() - 1; i++) {
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
		return new PolyPoint(cx, cy);
	}

}

class PolyPoint {

	float x;
	float y;
	
	public PolyPoint(float x, float y) {
		this.x = x;
		this.y = y;
	}

	public void move(float xnew, float ynew) {
		this.x = xnew;
		this.y = ynew;
	}

}

