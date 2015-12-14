
class CreatePolygon {

  Canvas canvas;
  TriangleView triView;
  Polygon polygon;

  public CreatePolygon(Canvas canvas) {
    this.canvas = canvas;
    this.triView = viewFactory.getTriangleView(canvas.x1, canvas.y2, canvas.x1 + canvas.w/2, canvas.y1, canvas.x2, canvas.y2);
    this.polygon = new Polygon();
  }

  void render() {
    canvas.render();
    triView.render();
    polygon.render(triView);
    if (polygon.isComplete) {
      triangulatePolygon(polygon);
    }
  }

  void triangulatePolygon(Polygon polygon) {
    float [][] points = new float[polygon.points.size()][2];
    for (int i =0; i < polygon.points.size(); i++) {
      points[i][0] = polygon.points.get(i).x;
      points[i][1] = polygon.points.get(i).y;
    }
    Delaunay del = new Delaunay(points);
    float[][] edges = del.getEdges();
    for (int i = 0; i < edges.length; i++) {
      float x1 = edges[i][0];
      float y1 = edges[i][1];
      float x2 = edges[i][2];
      float y2 = edges[i][3];
      line(x1, y1, x2, y2);
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