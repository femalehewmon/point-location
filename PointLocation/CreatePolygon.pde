
class CreatePolygon {

  Canvas canvas;
  TriangleView triView;
  PolygonPL polygon;

  Polygon innerPoly = null;
  Polygon outerPoly = null;

  Triangulation triang;

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
    if (!polygon.isComplete) {
      polygon.render(triView);
    } else {
      if (stage == 0) {
        triangulateInnerPolygon();
        drawTriangulatedPoly(innerPoly, color(0));
        if (counter >= 100) {
          stage = 1;
          counter = 0;
          println("end of stage 1: inner poly has " + innerPoly.getTriangles().size());
        }
        counter++;
      } else if (stage == 1) {
        triangulateOuterPolygon();
        drawTriangulatedPoly(innerPoly, color(0));
        drawTriangulatedPoly(outerPoly, color(255, 0, 0));
        if (counter >= 100) {
          stage = 2;
          counter = 0;
          triang = mergePolygons(innerPoly, outerPoly);
          println("end of stage 2: outer poly has " + outerPoly.getTriangles().size());
          println("end of stage 2: inner poly has " + innerPoly.getTriangles().size());
        }
        counter++;
      } else if (stage == 2) {
        drawTriangulatedPoly(innerPoly, color(0, 255, 0));
        stage = 3;
        counter = 0;
        println("end of stage 22: inner poly has " + innerPoly.getTriangles().size());
      } else if (stage == 3) {
        //drawTriangulatedPoly(innerPoly, color(0, 255, 0));
        triang.render();
        if (counter >= 100) {
          if (!done) {
            done = !triang.removeLowDegreeIndependentSet(innerPoly);
            println("end of stage 3: inner poly has " + innerPoly.getTriangles().size());
          }
          //triangulateInnerPolygon();
          //drawTriangulatedPoly(innerPoly, color(0, 0, 255));
          counter = 0;
        }
        counter++;
      }
    }

    //polygon.render(triView);
  }

  boolean done = false;

  void triangulateInnerPolygon() {
    triangulateInnerPolygon(false);
  }

  void triangulateInnerPolygon(boolean force) {
    if (force || innerPoly == null) {
      if (innerPoly != null) {
        innerPoly.clearTriangulation();
      }
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

  Triangulation mergePolygons(Polygon poly1, Polygon poly2) {
    ArrayList<DelaunayTriangle> triPoints = (ArrayList)poly2.getTriangles();
    poly1.addTriangles(triPoints);
    triPoints = (ArrayList)poly1.getTriangles();
    Triangulation completeTriangulation = new Triangulation();
    completeTriangulation.addTriangles(triPoints);
    return completeTriangulation;
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

