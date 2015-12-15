
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
          mergePolygons(innerPoly, outerPoly);
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
        drawTriangulatedPoly(innerPoly, color(0, 255, 0));
        if (counter >= 100) {
          removeLowDegreeIndependentSet(innerPoly);
          triangulateInnerPolygon();
          drawTriangulatedPoly(innerPoly, color(0, 0, 255));
          counter = 0;
          println("end of stage 3: inner poly has " + innerPoly.getTriangles().size());
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

  TriangulationPoint maxLeft = null;
  TriangulationPoint maxTop = null;
  TriangulationPoint maxRight = null;

  void updateMaxPoints(TriangulationPoint tp) {
    if (maxLeft == null ||  tp.getX() < maxLeft.getX()) {
      maxLeft = tp;
    }
    if (maxTop == null || tp.getY() < maxTop.getY()) {
      maxTop = tp;
    }
    if (maxRight == null || tp.getX() > maxRight.getX()) {
      maxRight = tp;
    }
  }

  void mergePolygons(Polygon poly1, Polygon poly2) {
    ArrayList<DelaunayTriangle> triPoints = (ArrayList)poly2.getTriangles();
    poly1.addTriangles(triPoints);
    triPoints = (ArrayList)poly1.getTriangles();

    for (int i = 0; i < triPoints.size (); i++) {
      DelaunayTriangle currentTriangle = triPoints.get(i);
      TriangulationPoint p1 = triPoints.get(i).points[0];
      updateMaxPoints(p1);
      TriangulationPoint p2 = triPoints.get(i).points[1];
      updateMaxPoints(p2);
      TriangulationPoint p3 = triPoints.get(i).points[2];
      updateMaxPoints(p3);

      if (!polyPoints.contains(p1)) {  
        polyPoints.add(p1);
        triMap.put(p1, new ArrayList<DelaunayTriangle>());
      }

      if (!polyPoints.contains(p2)) {
        polyPoints.add(p2);
        triMap.put(p2, new ArrayList<DelaunayTriangle>());
      }

      if (!polyPoints.contains(p3)) {
        polyPoints.add(p3);
        triMap.put(p3, new ArrayList<DelaunayTriangle>());
      }

      triMap.get(p1).add(currentTriangle);
      triMap.get(p2).add(currentTriangle);
      triMap.get(p3).add(currentTriangle);
    }
    printHashMap();
  }

  void printHashMap() {
    println("HASH MAP:");
    for (TriangulationPoint key : triMap.keySet ()) {
      ArrayList<DelaunayTriangle> dtris = triMap.get(key);
      println("Point: " + key.getX() + " " + key.getY() + " has " + dtris.size() + " triangles");
      for (int i = 0; i < dtris.size (); i++) {
        println("  Triangle: " + getTriId((dtris.get(i))));
      }
    }
    println("");
  }

  String getTriId(DelaunayTriangle dtri) {
    TriangulationPoint p1 = dtri.points[0];
    TriangulationPoint p2 = dtri.points[1];
    TriangulationPoint p3 = dtri.points[2];
    return "p1 " + p1.getX() + " " + p1.getY() + " p2 " + p2.getX() + " " + p2.getY() + " p3 " + p3.getX() + " " + p3.getY();
  }

  ArrayList<TriangulationPoint> polyPoints = new ArrayList<TriangulationPoint>();
  HashMap<TriangulationPoint, ArrayList<DelaunayTriangle>> triMap = 
    new HashMap<TriangulationPoint, ArrayList<DelaunayTriangle>>();


  void removeLowDegreeIndependentSet(Polygon poly) {
    //for 1 point
    //step through all triangles
    ArrayList<TriangulationPoint> pointsToSearch = new ArrayList<TriangulationPoint>();
    for (TriangulationPoint key : triMap.keySet ()) {
      pointsToSearch.add(key);
    }
    println("Found " + pointsToSearch.size() + " to search");
    ArrayList<TriangulationPoint> neighbors = new ArrayList<TriangulationPoint>();
    for (int i = 0; i < pointsToSearch.size (); i++) {
      TriangulationPoint currPoint = pointsToSearch.get(i);
      if (currPoint == maxLeft || currPoint == maxTop || currPoint == maxRight) {
        // don't try to remove outer vertex points
        println("Skipping outer point");
        continue;
      }
      println("Looking at " + currPoint.getX() + " " + currPoint.getY());
      int degree = triMap.get(currPoint).size();
      if (degree <= 8 && !neighbors.contains(currPoint)) {
        println("point has degrees " + degree);
        ArrayList<DelaunayTriangle> connectedTris = triMap.get(currPoint);

        // maintain independent set but adding current points neighbors to a block list
        for (int k = 0; k < degree; k++) {
          neighbors.add(connectedTris.get(k).points[0]);
          neighbors.add(connectedTris.get(k).points[1]);
          neighbors.add(connectedTris.get(k).points[2]);
        }

        // for each triangle attached to deleted point, add edge points in order to create new polygon
        TriangulationPoint currHullPoint = null;
        ArrayList<PolygonPoint> emptyPolyPoints = new ArrayList<PolygonPoint>();
        int numberOfTriangles = connectedTris.size();
        // skip last triangle to prevent double adding start point
        for (int iter = 0; iter < numberOfTriangles - 1; iter++) {
          DelaunayTriangle currTri = null;
          if (currHullPoint == null) {
            currTri = connectedTris.get(iter);
          } else {
            boolean tmp = false;
            for (int itter = 0; itter < connectedTris.size (); itter++) {
              if (connectedTris.get(itter).contains(currHullPoint)) {
                currTri = connectedTris.get(itter);
                tmp = true;
                break;
              }
            }
            if (!tmp) {
              println("NEXT TRI NOT FOUND!!!");
            }
          }
          TriangulationPoint p1 = currTri.points[0];
          TriangulationPoint p2 = currTri.points[1];
          TriangulationPoint p3 = currTri.points[2];
          if (p1 == currPoint) {
            //use p2 and p3
            currHullPoint = addPointToList(emptyPolyPoints, p2, p3, currHullPoint);
          } else if (p2 == currPoint) {
            currHullPoint = addPointToList(emptyPolyPoints, p1, p3, currHullPoint);
          } else if (p3 == currPoint) {
            currHullPoint = addPointToList(emptyPolyPoints, p2, p1, currHullPoint);
          }
          connectedTris.remove(currTri);
        }
        // remove old point from hashmap
        triMap.remove(currPoint);
        println("REMOVED FROM MAP: " + currPoint.getX() + " " + currPoint.getY());

        println("size of empty poly " + emptyPolyPoints.size());

        Polygon emptyPoly = new Polygon(emptyPolyPoints);
        Poly2Tri.triangulate(emptyPoly);
        drawTriangulatedPoly(emptyPoly, color(0, 255, 255));

        //ArrayList<DelaunayTriangle> triPointsToMerge = (ArrayList)emptyPoly.getTriangles();
        //innerPoly.addTriangles(triPointsToMerge);
      }
    }
    printHashMap();
  }

  TriangulationPoint addPointToList(ArrayList<PolygonPoint> emptyPoly, TriangulationPoint p1, TriangulationPoint p2, TriangulationPoint currHullPoint) {
    TriangulationPoint tmpPoint;
    if (currHullPoint == null) {
      println("Added first point " + p1.getX() + " " + p1.getY());
      emptyPoly.add(new PolygonPoint(p1.getX(), p1.getY()));
      println("Added second point " + p2.getX() + " " + p2.getY());
      emptyPoly.add(new PolygonPoint(p2.getX(), p2.getY()));
      currHullPoint = p2;
    } else {
      // only add point that is not already added
      if (p1 == currHullPoint) {
        println("Added second point " + p2.getX() + " " + p2.getY());
        emptyPoly.add(new PolygonPoint(p2.getX(), p2.getY()));
        currHullPoint = p2;
      } else {
        println("Added first point " + p1.getX() + " " + p1.getY());
        emptyPoly.add(new PolygonPoint(p1.getX(), p1.getY()));
        currHullPoint = p1;
      }
    }
    return currHullPoint;
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

