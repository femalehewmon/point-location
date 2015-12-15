
class CreatePolygon {

  Canvas canvas;
  TriangleView triView;
  PolygonPL polygon;

  Polygon innerPoly = null;
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
      if (stage == 0) {
        triangulateInnerPolygon();
        drawTriangulatedPoly(innerPoly, color(0));
        if (counter >= 100) {
          stage = 1;
          counter = 0;
        }
        counter++;
      } else if (stage == 1) {
        triangulateOuterPolygon();
        drawTriangulatedPoly(innerPoly, color(0));
        drawTriangulatedPoly(outerPoly, color(255, 0, 0));
        if (counter >= 100) {
          stage = 2;
          counter = 0;
          mergePolygons(innerPoly, outerPoly);
        }
        counter++;
      } else if (stage == 2) {
        drawTriangulatedPoly(innerPoly, color(0, 255, 0));
        stage = 3;
        counter = 0;
        mergePolygons(innerPoly, outerPoly);
      } else if (stage == 3) {
        drawTriangulatedPoly(innerPoly, color(0, 255, 0));
        if (counter >= 100) {
          removeLowDegreeIndependentSet(innerPoly);
          triangulateInnerPolygon();
          drawTriangulatedPoly(innerPoly, color(0, 0, 255));
          counter = 0;
        }
        counter++;
      }
    }
  }

  void triangulateInnerPolygon() {
    triangulateInnerPolygon(false);
  }

  void triangulateInnerPolygon(boolean force) {
    if (force || innerPoly == null) {
      ArrayList<PolygonPoint> polyPoints = new ArrayList<PolygonPoint>();
      for (int i = 0; i < polygon.points.size (); i++) {
        polyPoints.add(new PolygonPoint((int)polygon.points.get(i).x, (int)polygon.points.get(i).y));
      }
      innerPoly = new Polygon(polyPoints);
      Poly2Tri.triangulate(innerPoly);
    }
  }

  void triangulateOuterPolygon() {
    if (outerPoly == null) {
      outerPoly =  new Polygon(
      new PolygonPoint(triView.x1, triView.y1), 
      new PolygonPoint(triView.x2, triView.y2), 
      new PolygonPoint(triView.x3, triView.y3));
      outerPoly.addHole(innerPoly);
      Poly2Tri.triangulate(outerPoly);
    }
  }

  void mergePolygons(Polygon poly1, Polygon poly2) {
    ArrayList<DelaunayTriangle> triPoints = (ArrayList)poly2.getTriangles();
    poly1.addTriangles(triPoints);
    triPoints = (ArrayList)poly1.getTriangles();

    for (int i = 0; i < triPoints.size (); i++) {
      TriangulationPoint p1 = triPoints.get(i).points[0];
      TriangulationPoint p2 = triPoints.get(i).points[1];
      TriangulationPoint p3 = triPoints.get(i).points[2];
      if (!polyPoints.contains(p1)) {  
        polyPoints.add(p1);
        triMap.put(p1, new ArrayList<DelaunayTriangle>());
        println("adding " + p1.getX() + " " + p1.getY() + " " + i);
      }

      if (!polyPoints.contains(p2)) {
        polyPoints.add(p2);
        triMap.put(p2, new ArrayList<DelaunayTriangle>());
        println("adding " + p2.getX() + " " + p2.getY() + " " + i);
      }

      if (!polyPoints.contains(p3)) {
        polyPoints.add(p3);
        triMap.put(p3, new ArrayList<DelaunayTriangle>());
        println("adding " + p3.getX() + " " + p3.getY() + " " + i);
      }

      triMap.get(p1).add(triPoints.get(i));
      triMap.get(p2).add(triPoints.get(i));
      triMap.get(p3).add(triPoints.get(i));
    }
  }

  int[][] adj = null;
  ArrayList<TriangulationPoint> polyPoints = new ArrayList<TriangulationPoint>();
  HashMap<TriangulationPoint, ArrayList<DelaunayTriangle>> triMap = 
    new HashMap<TriangulationPoint, ArrayList<DelaunayTriangle>>();

  void removeLowDegreeIndependentSet(Polygon poly) {

    PolygonPoint pp = poly.getPoint();
    println("pp is " + poly.getPoints().size());

    ArrayList<TriangulationPoint> triipoints = (ArrayList)poly.getPoints();
    for (int i= 0; i < triipoints.size (); i++) {
      println("trii point " + triipoints.get(i).getX() + " " + triipoints.get(i).getY()+ " " + ((PolygonPoint)triipoints.get(i)).getNext());
    }

    if (adj == null) {
      adj = new int[polyPoints.size()][polyPoints.size()];
      ArrayList<DelaunayTriangle> dTris = (ArrayList)poly.getTriangles();
      for (int i = 0; i < dTris.size (); i++) {
        TriangulationPoint p1 = dTris.get(i).points[0];
        TriangulationPoint p2 = dTris.get(i).points[1];
        TriangulationPoint p3 = dTris.get(i).points[2];
        adj[polyPoints.indexOf(p1)][polyPoints.indexOf(p2)] = 1;
        adj[polyPoints.indexOf(p1)][polyPoints.indexOf(p3)] = 1;
        adj[polyPoints.indexOf(p3)][polyPoints.indexOf(p2)] = 1;
        adj[polyPoints.indexOf(p2)][polyPoints.indexOf(p1)] = 1;
        adj[polyPoints.indexOf(p3)][polyPoints.indexOf(p1)] = 1;
        adj[polyPoints.indexOf(p2)][polyPoints.indexOf(p3)] = 1;
      }
    }
    //for 1 point
    //step through all triangles
    ArrayList<Integer> neighbors = new ArrayList<Integer>();
    for (int i = 0; i < adj.length; i++) {
      int degree = 0;
      ArrayList<Integer> currNeighbors = new ArrayList<Integer>();
      for (int j = 0; j < adj.length; j++) {
        if (adj[i][j] > 0) {
          degree++;
          currNeighbors.add(j);
        }
      }
      if (degree <= 8) {
        if (!neighbors.contains(i)) {
          for (int k = 0; k < currNeighbors.size (); k++) {
            neighbors.add(currNeighbors.get(k));
          }
          println("removing point! " + polyPoints.get(i).getX() + " " + polyPoints.get(i).getY() + " " + ((PolygonPoint)polyPoints.get(i)).getNext());
          triipoints.remove(polyPoints.get(i));
          for (TriangulationPoint key : triMap.keySet ()) {
            
          }
        }
      }
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

