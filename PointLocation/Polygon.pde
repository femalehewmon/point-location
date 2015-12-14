
class Polygon extends Drawable {

  // TODO: don't allow intersecting edges

  private ArrayList<Point> points;
  private ArrayList<Edge> edges;

  Point testerPoint;
  boolean tryPoint = false;

  boolean isComplete = false;
  float equiThreshold = 3;

  float minX, maxX, minY, maxY;

  public Polygon() {
    this.points = new ArrayList<Point>();
    this.edges = new ArrayList<Edge>();
    this.testerPoint = new Point(0, 0);
    this.minX = Float.MIN_VALUE;
    this.minY = Float.MIN_VALUE;
    this.maxX = Float.MAX_VALUE;
    this.maxY = Float.MAX_VALUE;
  }

  void tryPointInPolygon() {
    // cannot try a point after polygon is complete
    if (!isComplete) {
      tryPoint = true;
    }
  }

  void addPoint(float x, float y) {
    // add point to polygon if polygon is not yet complete
    if (!isComplete) {
      if (points.size() > 0) {
        // if starting point clicked, within a threshold then finish polygon
        if ((Math.abs(points.get(0).x - x) <= equiThreshold) && (Math.abs(points.get(0).y - y) <= equiThreshold)) {
          finishPolygon();
        } else {
          // add edge between previous and just added points
          addPoint(new Point(x, y));
          addEdge(points.get(points.size() - 2), points.get(points.size() - 1));
        }
      } else {
        addPoint(new Point(x, y));
      }
    }
  }

  private void addPoint(Point point) {
    if (this.minX == Float.MIN_VALUE || point.x < this.minX) {
      this.minX = point.x;
    }
    if (this.minY == Float.MIN_VALUE || point.y < this.minY) {
      this.minY = point.y;
    }
    if (this.maxX == Float.MAX_VALUE || point.x > this.maxX) {
      this.maxX = point.x;
    }
    if (this.maxY == Float.MAX_VALUE || point.y > this.minY) {
      this.maxY = point.y;
    }

    points.add(point);
  }

  void addEdge(Point p1, Point p2) {
    edges.add(new Edge(p1, p2));
  }

  void finishPolygon() {
    isComplete = true;
    tryPoint = false;
    addEdge(points.get(points.size() - 1), points.get(0));
    //resizePolygon(0.50);
  }

  void resizePolygon(float scalingFactor) {
    int i;
    //float xcenter = this.maxX - this.minX;
    //float ycenter = this.maxY - this.minY;
    // get center of mass
    float xCenter = 0;
    float yCenter = 0;
    Point currPoint;
    Point nextPoint;
    for (i = 0; i < points.size() - 1; i++) {
      currPoint = points.get(i);
      nextPoint = points.get(i + 1);
      xCenter += (currPoint.x + nextPoint.x)*((currPoint.x*nextPoint.y) - (nextPoint.x*currPoint.y));
      yCenter += (currPoint.y + nextPoint.y)*((currPoint.x*nextPoint.y) - (nextPoint.x*currPoint.y));
    }
    float area = getSignedArea();
    xCenter = (1/(6*area))*xCenter;
    yCenter = (1/(6*area))*yCenter;
    
    for (i = 0; i < edges.size(); i++) {
      edges.get(i).resizeEdge(scalingFactor, xCenter, yCenter);
    }
    for (i = 0; i < points.size(); i++) {
      points.get(i).resizePoint(scalingFactor, xCenter, yCenter);
    }
  }

  float getSignedArea() {
    float sum = 0;
    Point currPoint;
    Point nextPoint;
    for (int i = 0; i < points.size() - 1; i++) {
      currPoint = points.get(i);
      nextPoint = points.get(i + 1);
      sum += (currPoint.x*nextPoint.y) - (nextPoint.x*currPoint.y);
    }
    return 0.5 * sum;
  }

  void render(View boundingView) {
    int i;
    for (i = 0; i < edges.size(); i++) {
      edges.get(i).render();
    }
    for (i = 0; i < points.size(); i++) {
      points.get(i).render();
    }
    if (tryPoint) {
      if (boundingView != null) {
        PVector point = boundingView.boundPoint(mouseX, mouseY);
        testerPoint.updatePosition(mouseX, mouseY);
      }
      if (points.size() > 0) {
        new Edge(points.get(points.size() - 1), testerPoint).render();
      }
      testerPoint.render();
    }
  }

  void render() {
    render(null);
  }
}

class Point {

  float x, y;
  float RAD;
  color cbackground, cstroke, chighlight;

  public Point(float _x, float _y, float _RAD, color _background, color _stroke, color _highlight) {
    this.x = _x;
    this.y = _y;
    this.RAD = _RAD;
    this.cbackground = _background;
    this.cstroke = _stroke;
    this.chighlight = _highlight;
  }

  public Point(float _x, float _y) { 
    this(_x, _y, 5, color(255, 0, 0), color(255, 0, 0), color(255, 0, 0));
  }

  void updatePosition(float _x, float _y) {
    this.x = _x;
    this.y = _y;
  }

  void render() {
    render(false);
  }

  void render(boolean isSelected) {
    color cfill = isSelected ? cbackground: chighlight;
    stroke(cstroke);
    fill(cfill);
    ellipse(x, y, RAD, RAD);
  }

  void resizePoint(float scalingFactor, float xCenter, float yCenter) {
    float scaledX = scalingFactor*(x - xCenter) + xCenter;
    float scaledY = scalingFactor*(y - yCenter) + yCenter;
    updatePosition(scaledX, scaledY);
  }
}

class Edge {  

  float x1, x2, y1, y2;
  color cstroke, chighlight;

  public Edge(float _x1, float _y1, float _x2, float _y2, color _stroke, color _highlight) {
    updatePosition(_x1, _y1, _x2, _y2);
    this.cstroke = _stroke;
    this.chighlight = _highlight;
  }

  public Edge(float _x1, float _y1, float _x2, float _y2) { 
    this(_x1, _y1, _x2, _y2, color(0), color(255, 0, 0));
  }

  public Edge(Point p1, Point p2) {
    this(p1.x, p1.y, p2.x, p2.y);
  }

  void updatePosition(float _x1, float _y1, float _x2, float _y2) {
    this.x1 = _x1;
    this.y1 = _y1;
    this.x2 = _x2;
    this.y2 = _y2;
  }

  void render() {
    render(false);
  }

  void render(boolean isSelected) {
    color fillColor = isSelected ? cstroke: chighlight;
    stroke(fillColor);
    line(x1, y1, x2, y2);
  }

  void resizeEdge(float scalingFactor, float xCenter, float yCenter) {
    float scaledX1 = scalingFactor*(x1 - xCenter) + xCenter;
    float scaledY1 = scalingFactor*(y1 - yCenter) + yCenter;
    float scaledX2 = scalingFactor*(x2 - xCenter) + xCenter;
    float scaledY2 = scalingFactor*(y2 - yCenter) + yCenter;
    updatePosition(scaledX1, scaledY1, scaledX2, scaledY2);
  }
}