
class CreatePolygon {

  int STEPS = 10;

  Canvas canvas;
  TriangleView triView;
  PolygonPL polygon;

  Polygon innerPoly = null;
  Polygon outerPoly = null;

  Triangulation triangulation;

  int stage = 0;
  int counter = 0;

  public CreatePolygon(Canvas canvas) {
    this.canvas = canvas;
    this.triView = viewFactory.getTriangleView(canvas.x1, canvas.y2, canvas.x1 + canvas.w/2, canvas.y1, canvas.x2, canvas.y2);
    this.polygon = new PolygonPL();
    this.triangulation = new Triangulation();
  }

  void render() {
    canvas.render();
    triView.render();
    polygon.render(triView);
    if (polygon.isComplete) {
      if (stage == 0) {
        if (counter >= STEPS) {
          println("Triangulated inner");
          triangulateInnerPolygon();
          stage = 1;
          counter = 0;
        }
        counter++;
      } else if (stage == 1) {
        if (counter >= STEPS) {
          println("Triangulated outer");
          triangulateOuterPolygon();
          stage = 2;
          counter = 0;
        }
        counter++;
      } else if (stage == 2) {
        if (counter >= STEPS) {
          println("Remove independent low vertex set");
          if (triangulation.removeLowDegreeIndependentSet(innerPoly)) {
            stage = 3;
          }
          counter = 0;
        }
        counter++;
      } else if (stage == 3) {
        println("here");
        stage = 4;
        //triangulation.rootTriang.buildTree(treeView);
        treeView.loadTree(triangulation);
      }
      triangulation.render();
      //polygon.render(triView);
    }
  }

  void triangulateInnerPolygon() {
    ArrayList<PolygonPoint> polyPoints = new ArrayList<PolygonPoint>();
    for (int i = 0; i < polygon.points.size (); i++) {
      polyPoints.add(new PolygonPoint((int)polygon.points.get(i).x, (int)polygon.points.get(i).y));
    }
    innerPoly = new Polygon(polyPoints);
    Poly2Tri.triangulate(innerPoly);
    triangulation.addTriangles((ArrayList)innerPoly.getTriangles());
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
    triangulation.addTriangles((ArrayList)outerPoly.getTriangles());
  }

  void loadDemo(String file) {
    String[] lines = loadStrings(file);
    for (int i = 0; i < lines.length; i++) {
      String[] split = split(lines[i], " ");
      polygon.addPoint(Float.parseFloat(split[0]), Float.parseFloat(split[1]));
    }
    polygon.finishPolygon();
  }

  void loadPoints(int[][] points) {
    for (int i = 0; i < points.length; i++) {
      polygon.addPoint(points[i][0], points[i][1]);
    }
    polygon.finishPolygon();
  }

  void handleMouseClickEvent() {
    if (triView.pointInView(mouseX, mouseY)) {
      println(mouseX + " " + mouseY);
      polygon.addPoint(mouseX, mouseY);
    }
  }

  void handleMousePressEvent() {
    if (triView.pointInView(mouseX, mouseY)) {
      polygon.tryPointInPolygon();
    }
  }
}