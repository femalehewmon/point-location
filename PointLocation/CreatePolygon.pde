
class CreatePolygon {

  Canvas canvas;
  TriangleView triView;
  PolygonPL polygon;
  Polygon triangulatedPoly = null;
  Polygon outerPoly = null;

  int stage = 0;
  int counter = 0;

  public CreatePolygon(Canvas canvas) {
    this.canvas = canvas;
    this.triView = viewFactory.getTriangleView(canvas.x1, canvas.y2, canvas.x1 + canvas.w/2, canvas.y1, canvas.x2, canvas.y2);
    this.polygon = new PolygonPL();
  }

  void render() {
    canvas.render();
    triView.render();
    polygon.render(triView);
    if (polygon.isComplete) {
      triangulateInnerPolygon();
      triangulateOuterPolygon();
    }
  }

  void triangulateInnerPolygon() {
    if (triangulatedPoly == null) {
      ArrayList<PolygonPoint> polyPoints = new ArrayList<PolygonPoint>();
      for (int i = 0; i < polygon.points.size (); i++) {
        polyPoints.add(new PolygonPoint((int)polygon.points.get(i).x, (int)polygon.points.get(i).y));
      }
      triangulatedPoly = new Polygon(polyPoints);
      Poly2Tri.triangulate(triangulatedPoly);
    }
    drawTriangulatedPoly(triangulatedPoly, color(0));
  }

  void triangulateOuterPolygon() {
    if (counter >= 100) {
      if (outerPoly == null) {
        outerPoly =  new Polygon(new PolygonPoint(triView.x1, triView.y1), 
        new PolygonPoint(triView.x2, triView.y2), new PolygonPoint(triView.x3, triView.y3));
        outerPoly.addHole(triangulatedPoly);
        Poly2Tri.triangulate(outerPoly);
      }
      drawTriangulatedPoly(outerPoly, color(255, 0, 0));
    } else {
      counter+=1;
    }
  }

  void drawTriangulatedPoly(Polygon poly, color col) {
    ArrayList<DelaunayTriangle> triPoints = (ArrayList)poly.getTriangles();
    for (int i = 0; i < triPoints.size (); i++) {
      TriangulationPoint p1 = triPoints.get(i).points[0];
      TriangulationPoint p2 = triPoints.get(i).points[1];
      TriangulationPoint p3 = triPoints.get(i).points[2];
      fill(0);
      stroke(col);
      line((float)p1.getX(), (float)p1.getY(), (float)p2.getX(), (float)p2.getY());
      line((float)p3.getX(), (float)p3.getY(), (float)p2.getX(), (float)p2.getY());
      line((float)p1.getX(), (float)p1.getY(), (float)p3.getX(), (float)p3.getY());
    }
  }

  void handleMouseClickEvent() {
    if (triView.pointInView(mouseX, mouseY)) {
      polygon.addPoint(mouseX, mouseY);
    }
  }

  void handleMousePressEvent() {
    if (triView.pointInView(mouseX, mouseY)) {
      polygon.tryPointInPolygon();
    }
  }
}

class TriangleView extends View {

  float x1, y1, x2, y2, x3, y3;
  float y23, x32, y31, x13, det, minD, maxD;

  public TriangleView(String id, float _x1, float _y1, float _x2, float _y2, float _x3, float _y3) {
    super(id);
    updateSize(_x1, _y1, _x2, _y2, _x3, _y3);
  }

  void updateSize(float _x1, float _y1, float _x2, float _y2, float _x3, float _y3) {
    this.x1 = _x1;
    this.y1 = _y1;
    this.x2 = _x2;
    this.y2 = _y2;
    this.x3 = _x3;
    this.y3 = _y3;
    this.y23 = y2 - y3;
    this.x32 = x3 - x2;
    this.y31 = y3 - y1;
    this.x13 = x1 - x3;
    this.det = y23 * x13 - x32 * y31;
    this.minD = Math.min(det, 0);
    this.maxD = Math.max(det, 0);
  }

  boolean pointInView(float x, float y) {
    // http://stackoverflow.com/a/25346777
    double dx = x - x3;
    double dy = y - y3;
    double a = y23 * dx + x32 * dy;
    if (a < minD || a > maxD)
      return false;
    double b = y31 * dx + x13 * dy;
    if (b < minD || b > maxD)
      return false;
    double c = det - a - b;
    if (c < minD || c > maxD)
      return false;
    return true;
  }

  PVector boundPoint(float x, float y) {
    PVector boundedPoint = new PVector(x, y);
    if (!pointInView(x, y)) {
      // TODO
    }
    return boundedPoint;
  }

  void render() {
    stroke(this.cstroke);
    fill(this.cbackground);
    triangle(x1, y1, x2, y2, x3, y3);
  }
}

