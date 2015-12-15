class Triangulation {

  HashMap<TriangPoint, ArrayList<Triang>> triangMap;

  TriangPoint maxLeft = null;
  TriangPoint maxTop = null;
  TriangPoint maxRight = null;

  public Triangulation() {
    this.triangMap = new HashMap<TriangPoint, ArrayList<Triang>>();
  }

  void removeLowDegreeIndependentSet(Polygon poly) {
    //step through all triangles
    ArrayList<TriangPoint> pointsToSearch = new ArrayList<TriangPoint>();
    for (TriangPoint key : triangMap.keySet ()) {
      pointsToSearch.add(key);
    }
    println("Found " + pointsToSearch.size() + " to search");
    ArrayList<TriangPoint> neighbors = new ArrayList<TriangPoint>();
    for (int i = 0; i < pointsToSearch.size (); i++) {
      TriangPoint currPoint = pointsToSearch.get(i);
      if (currPoint == maxLeft || currPoint == maxTop || currPoint == maxRight) {
        // don't try to remove outer vertex points
        println("Skipping outer point");
        continue;
      }
      println("Looking at " + currPoint.x + " " + currPoint.y);
      int degree = triangMap.get(currPoint).size();
      if (degree <= 8 && !neighbors.contains(currPoint)) {
        println("point has degrees " + degree);
        ArrayList<Triang> connectedTris = triangMap.get(currPoint);

        // maintain independent set
        // done by adding current point's neighbors to a block list
        for (int k = 0; k < degree; k++) {
          neighbors.add(connectedTris.get(k).points[0]);
          neighbors.add(connectedTris.get(k).points[1]);
          neighbors.add(connectedTris.get(k).points[2]);
        }

        // for each triangle attached to deleted point
        // add edge points in order to create new polygon
        TriangPoint currHullPoint = null;
        ArrayList<PolygonPoint> emptyPolyPoints = new ArrayList<PolygonPoint>();
        int numberOfTriangles = connectedTris.size();
        for (int iter = 0; iter < numberOfTriangles - 1; iter++) {
          // skip last triangle to prevent double adding start point
          Triang currTri = null;
          if (currHullPoint == null) {
            currTri = connectedTris.get(iter);
          } else {
            boolean tmp = false;
            for (int itter = 0; itter < connectedTris.size (); itter++) {
              println("is this a match? " + connectedTris.get(itter).getId());
              fill(color(0, 255, 0));
              ellipse(width/2, height/2, 50, 50);
              if (connectedTris.get(itter).contains(currHullPoint)) {
                currTri = connectedTris.get(itter);
                tmp = true;
                break;
              }
            }
            if (!tmp) {
              println("NEXT TRI NOT FOUND!!! was looking for point " +
                currHullPoint.x + " " + currHullPoint.y);
            }
          }

          TriangPoint p1 = currTri.points[0];
          TriangPoint p2 = currTri.points[1];
          TriangPoint p3 = currTri.points[2];
          if (p1.x == currPoint.x && p1.y == currPoint.y) {
            //use p2 and p3
            currHullPoint = addPointToList(
            emptyPolyPoints, p2, p3, currHullPoint);
          } else if (p2.x == currPoint.x && p2.y == currPoint.y) {
            currHullPoint = addPointToList(
            emptyPolyPoints, p1, p3, currHullPoint);
          } else if (p3.x == currPoint.x && p3.y == currPoint.y) {
            currHullPoint = addPointToList(
            emptyPolyPoints, p2, p1, currHullPoint);
          }
          //connectedTris.remove(currTri);
          for (TriangPoint key : triangMap.keySet ()) {
            if (triangMap.get(key).contains(currTri)) {
              triangMap.get(key).remove(currTri);
            }
          }
        }
        // remove old point from hashmap
        triangMap.remove(currPoint);
        println("REMOVED FROM MAP: " + currPoint.x + " " + currPoint.y);

        println("size of empty poly " + emptyPolyPoints.size());


        Polygon emptyPoly = new Polygon(emptyPolyPoints);
        Poly2Tri.triangulate(emptyPoly);
        // drawTriangulatedPoly(emptyPoly, color(0, 255, 255));

        ArrayList<DelaunayTriangle> triPointsToMerge = (ArrayList)emptyPoly.getTriangles();
        // add new triangles to hash map
        for (int ittter = 0; ittter < triPointsToMerge.size (); ittter++) {
          addTriangle(triPointsToMerge.get(ittter));
        }

        Polygon newPoly = new Polygon(emptyPolyPoints);
        Poly2Tri.triangulate(newPoly);
        newPoly.addTriangles(triPointsToMerge);
      }
    }
    printHashMap();
  }

  TriangPoint addPointToList(
  ArrayList<PolygonPoint> emptyPoly, 
  TriangPoint p1, TriangPoint p2, 
  TriangPoint currHullPoint) {

    TriangulationPoint tmpPoint;
    if (currHullPoint == null) {
      println("Added first point " + p1.x + " " + p1.y);
      emptyPoly.add(new PolygonPoint(p1.x, p1.y));
      println("Added second point " + p2.x + " " + p2.y);
      emptyPoly.add(new PolygonPoint(p2.x, p2.y));
      currHullPoint = p2;
    } else {
      // only add point that is not already added
      if (p1 == currHullPoint) {
        println("Added second point " + p2.x + " " + p2.y);
        emptyPoly.add(new PolygonPoint(p2.x, p2.y));
        currHullPoint = p2;
      } else {
        println("Added first point " + p1.x + " " + p1.y);
        emptyPoly.add(new PolygonPoint(p1.x, p1.y));
        currHullPoint = p1;
      }
    }
    return currHullPoint;
  }


  public void addTriangles(ArrayList dts) {
    for (int i = 0; i < dts.size (); i++) {
      try {
        addTriangle((Triang)dts.get(i));
      } 
      catch(Exception e) {
        addTriangle((DelaunayTriangle)dts.get(i));
      }
    }
  }

  public void addTriangle(DelaunayTriangle dt) {
    TriangPoint tp1 = new TriangPoint(dt.points[0]);
    TriangPoint tp2 = new TriangPoint(dt.points[1]);
    TriangPoint tp3 = new TriangPoint(dt.points[2]);
    Triang tri = new Triang(tp1, tp2, tp3);
    addTriangle(tri);
  }

  public void addTriangle(Triang triang) {
    addPointToMap(triang.points[0], triang);
    addPointToMap(triang.points[1], triang);
    addPointToMap(triang.points[2], triang);
  }

  private void addPointToMap(TriangPoint tp) {
    addPointToMap(tp, null);
  }

  private void addPointToMap(TriangPoint tp, Triang tri) {
    if (!triangMap.containsKey(tp)) {
      triangMap.put(tp, new ArrayList<Triang>());
    }
    if (tri != null) {
      triangMap.get(tp).add(tri);
    }
  }

  void updateMaxPoints(TriangPoint tp) {
    if (maxLeft == null ||  tp.x < maxLeft.x) {
      maxLeft = tp;
    }
    if (maxTop == null || tp.y < maxTop.y) {
      maxTop = tp;
    }
    if (maxRight == null || tp.x > maxRight.x) {
      maxRight = tp;
    }
  }

  void printHashMap() {
    println("HASH MAP:");
    for (TriangPoint key : triangMap.keySet ()) {
      ArrayList<Triang> dtris = triangMap.get(key);
      println("Point: " + key.x + " " + key.y + " has " + dtris.size() + " triangles");
      for (int i = 0; i < dtris.size (); i++) {
        println("  Triangle: " + dtris.get(i).getId());
      }
    }
    println("");
  }
}

class TriangPoint {

  float x, y;

  public TriangPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public TriangPoint(TriangulationPoint p1) {
    this.x = (float)p1.getX();
    this.y = (float)p1.getY();
  }
}

class Triang extends Drawable {

  float y23, x32, y31, x13, det, minD, maxD;
  TriangPoint[] points;

  public Triang(float x1, float y1, float x2, float y2, float x3, float y3) {
    points = new TriangPoint[3];
    points[0] = new TriangPoint(x1, y1);
    points[1] = new TriangPoint(x2, y2);
    points[2] = new TriangPoint(x3, y3);
    this.y23 = y2 - y3;
    this.x32 = x3 - x2;
    this.y31 = y3 - y1;
    this.x13 = x1 - x3;
    this.det = y23 * x13 - x32 * y31;
    this.minD = Math.min(det, 0);
    this.maxD = Math.max(det, 0);
  }

  public Triang(TriangPoint p1, TriangPoint p2, TriangPoint p3) {
    this(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  }

  public boolean contains(TriangPoint tp) {
    if (points[0].x == tp.x && points[0].y == tp.y) {
      return true;
    }
    if (points[1].x == tp.x && points[1].y == tp.y) {
      return true;
    }
    if (points[2].x == tp.x && points[2].y == tp.y) {
      return true;
    }
    return false;
  }


  String getId() {
    TriangPoint p1 = points[0];
    TriangPoint p2 = points[1];
    TriangPoint p3 = points[2];
    return points[0].x + " " + points[0].y + ", " + 
      points[1].x + " " + points[1].y + ", " + 
      points[2].x + " " + points[2].y;
  }

  void render() {
  }

  boolean isSelected() {
    // http://stackoverflow.com/a/25346777
    double dx = mouseX - points[2].x;
    double dy = mouseY - points[2].y;
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
}

