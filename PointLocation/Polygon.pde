
class Polygon extends Drawable {

  // TODO: don't allow intersecting edges
  
  private ArrayList<Point> points;
  private ArrayList<Edge> edges;

  Point testerPoint;
  boolean tryPoint = false;

  boolean isComplete = false;
  float equiThreshold = 3;

  public Polygon() {
    super();
    this.points = new ArrayList<Point>();
    this.edges = new ArrayList<Edge>();
    this.testerPoint = new Point(0, 0);
  }

  void tryPoint() {
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
          points.add(new Point(x, y));
          addEdge(points.get(points.size() - 2), points.get(points.size() - 1));
        }
      } else {
        points.add(new Point(x, y));
      }
    }
  }

  void addEdge(Point p1, Point p2) {
    edges.add(new Edge(p1, p2));
  }

  void finishPolygon() {
    isComplete = true;
    tryPoint = false;
    addEdge(points.get(points.size() - 1), points.get(0));
  }

  void render() {
    int i;
    if (tryPoint) {
      testerPoint.updatePosition(mouseX, mouseY);
      if (points.size() > 0) {
        new Edge(points.get(points.size() - 1), testerPoint).render();
      }
    }
    for (i = 0; i < edges.size(); i++) {
      edges.get(i).render();
    }
    for (i = 0; i < points.size(); i++) {
      points.get(i).render();
    }
  }
}

class Point extends Drawable {

  float x, y;
  float rad;
  color background, stroke, highlight;

  public Point(float _x, float _y, float _rad, color _background, color _stroke, color _highlight) {
    super();
    this.x = _x;
    this.y = _y;
    this.rad = _rad;
    this.background = _background;
    this.stroke = _stroke;
    this.highlight = _highlight;
  }

  public Point(float _x, float _y) { 
    this(_x, _y, 5, color(0), color(0), color(0));
  }

  void updatePosition(float _x, float _y) {
    this.x = _x;
    this.y = _y;
  }

  void render() {
    render(false);
  }

  void render(boolean isSelected) {
    color fillColor = isSelected ? background: highlight;
    stroke(background);
    fill(fillColor);
    ellipse(x, y, rad, rad);
  }
}

class Edge extends Drawable {  

  float x1, x2, y1, y2;
  color stroke, highlight;

  public Edge(float _x1, float _y1, float _x2, float _y2, color _stroke, color _highlight) {
    super();
    this.x1 = _x1;
    this.y1 = _y1;
    this.x2 = _x2;
    this.y2 = _y2;
    this.stroke = _stroke;
    this.highlight = _highlight;
  }

  public Edge(float _x1, float _y1, float _x2, float _y2) { 
    this(_x1, _y1, _x2, _y2, color(0), color(255, 0, 0));
  }

  public Edge(Point p1, Point p2) {
    this(p1.x, p1.y, p2.x, p2.y);
  }

  void render() {
    render(false);
  }

  void render(boolean isSelected) {
    color fillColor = isSelected ? stroke: highlight;
    stroke(fillColor);
    line(x1, y1, x2, y2);
  }
}