
class Polygon {

	String id;
	ArrayList<PolyPoint> points;
	
	public Polygon(String id) {
		this.id = id;
		this.points = new ArrayList<PolyPoint>();
	}

	public void addPoint(float x, float y) {
		points.add(new PolyPoint(x, y));
	}

	public void render() {
		//fill(0, 0, 0);
		noFill();
		beginShape();
		for (int i = 0; i < points.size(); i++) {
			vertex(points.get(i).x, points.get(i).y);
		}	
		endShape();
	}

	public void move(PolyPoint newCenter) {
		PolyPoint currCenter = getCenter();	
		float xnew;
		float ynew;
		for (int i = 0; i < points.size(); i++ ) {
			xnew = newCenter.x + 
				(currCenter.x - points.get(i).x);
			ynew = newCenter.y + 
				(currCenter.y - points.get(i).y);
			points.get(i).move(xnew, ynew);
		}
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

	private PolyPoint getCenter() {
		int i, j;
		float cx;
		float cy;
		float area;
		for (i = 0; i < points.size() - 1; i++) {
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
