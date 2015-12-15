class Triangulation {

  Triang rootTriang;
  HashMap<String, ArrayList<Triang>> triangMap;

  TriangPoint maxLeft = null;
  TriangPoint maxTop = null;
  TriangPoint maxRight = null;

  public Triangulation() {
    this.rootTriang = null;
    this.triangMap = new HashMap<String, ArrayList<Triang>>();
  }

  public void render() {    
    for (String key : triangMap.keySet ()) {
      ArrayList<Triang> triangs = triangMap.get(key);
      for (int i = 0; i < triangs.size (); i++) {
        triangs.get(i).render();
      }
    }
  }

  boolean removeLowDegreeIndependentSet(Polygon poly) {
    //step through all triangles
    ArrayList<String> pointsToSearch = new ArrayList<String>();
    for (String key : triangMap.keySet ()) {
      pointsToSearch.add(key);
    }

    ArrayList<String> neighbors = new ArrayList<String>();
    // add outer triangle points to prevent deletion
    neighbors.add(maxLeft.id);
    neighbors.add(maxTop.id);
    neighbors.add(maxRight.id);

    // still more to reduce
    if (pointsToSearch.size() != neighbors.size()) {
      ArrayList<Triang> removedTriangles = new ArrayList<Triang>(); // kept to assign child/parent relationships
      for (int i = 0; i < pointsToSearch.size (); i++) {
        TriangPoint currPoint = new TriangPoint(pointsToSearch.get(i));
        if (currPoint.id.equals(maxLeft.id) || currPoint.id.equals(maxTop.id) || currPoint.id.equals(maxRight.id)) {
          // don't try to remove outer vertex points
          continue;
        }

        int degree = triangMap.get(currPoint.id).size();
        if (degree <= 8 && !neighbors.contains(currPoint.id)) {
          ArrayList<Triang> connectedTris = triangMap.get(currPoint.id);

          // maintain independent set
          // done by adding current point's neighbors to a block list
          for (int k = 0; k < degree; k++) {
            neighbors.add(connectedTris.get(k).points[0].id);
            neighbors.add(connectedTris.get(k).points[1].id);
            neighbors.add(connectedTris.get(k).points[2].id);
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
                if (connectedTris.get(itter).contains(currHullPoint)) {
                  currTri = connectedTris.get(itter);
                  tmp = true;
                  break;
                }
              }
              if (!tmp) {
                println("NEXT TRI NOT FOUND!!! was looking for point " +
                  currHullPoint.x + " " + currHullPoint.y);
                printHashMap();
                return false;
              }
            }

            TriangPoint p1 = currTri.points[0];
            TriangPoint p2 = currTri.points[1];
            TriangPoint p3 = currTri.points[2];
            if (p1.id.equals(currPoint.id)) {
              //use p2 and p3
              currHullPoint = addPointToList(
              emptyPolyPoints, p2, p3, currHullPoint);
            } else if (p2.id.equals(currPoint.id)) {
              currHullPoint = addPointToList(
              emptyPolyPoints, p1, p3, currHullPoint);
            } else if (p3.id.equals(currPoint.id)) {
              currHullPoint = addPointToList(
              emptyPolyPoints, p2, p1, currHullPoint);
            }
            removedTriangles.add(currTri);
            removeTriangle(currTri);
          }
          // remove old point from hashmap
          removePoint(currPoint);

          // triangulate the hole left behind
          Polygon emptyPoly = new Polygon(emptyPolyPoints);
          Poly2Tri.triangulate(emptyPoly);
          ArrayList<DelaunayTriangle> triPointsToMerge = (ArrayList)emptyPoly.getTriangles();
          // add new triangles to hash map
          for (int ittter = 0; ittter < triPointsToMerge.size (); ittter++) {
            Triang newTriangle = new Triang(triPointsToMerge.get(ittter));
            for (int k = 0; k < removedTriangles.size (); k++) {
              removedTriangles.get(k).addParent(newTriangle);
              newTriangle.addChild(removedTriangles.get(k));
            }
            addTriangle(newTriangle);
            rootTriang = newTriangle;
          }
        }
        return false;
      }
    } else {
      // set if fully reduced, you are done!
      return true;
    }
    return false; // not sure why it would get here
  }

  TriangPoint addPointToList(
  ArrayList<PolygonPoint> emptyPoly, 
  TriangPoint p1, TriangPoint p2, 
  TriangPoint currHullPoint) {

    TriangulationPoint tmpPoint;
    if (currHullPoint == null) {
      emptyPoly.add(new PolygonPoint(p1.x, p1.y));
      emptyPoly.add(new PolygonPoint(p2.x, p2.y));
      currHullPoint = p2;
    } else {
      // only add point that is not already added
      if (p1.id.equals(currHullPoint.id)) {
        emptyPoly.add(new PolygonPoint(p2.x, p2.y));
        currHullPoint = p2;
      } else {
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
    //printHashMap();
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

  public void removePoint(TriangPoint tp) {
    triangMap.remove(tp.id); // remove list of triangles for this point
    for (String key : triangMap.keySet ()) {
      ArrayList<Triang> triangs = triangMap.get(key);
      boolean removeTriang = false;
      for (int i = 0; i < triangs.size (); i++) { // for list of triangles for each point
        if (triangs.get(i).contains(tp)) { // if triangle contains point, remove triangle
          removeTriangle(triangs.get(i));
        }
      }
    }
  }

  public void removeTriangle(Triang triang) {
    int removeCount = 0;
    for (String key : triangMap.keySet ()) {
      if (triangMap.get(key).contains(triang)) {
        triangMap.get(key).remove(triang);
        removeCount ++;
      }
    }
  }

  private void addPointToMap(TriangPoint tp) {
    addPointToMap(tp, null);
  }

  private void addPointToMap(TriangPoint tp, Triang tri) {
    updateMaxPoints(tp);
    if (!triangMap.containsKey(tp.id)) {
      triangMap.put(tp.id, new ArrayList<Triang>());
    }
    if (tri != null) {
      triangMap.get(tp.id).add(tri);
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
    for (String key : triangMap.keySet ()) {
      ArrayList<Triang> dtris = triangMap.get(key);
      println("Point: " + key + " has " + dtris.size() + " triangles");
      for (int i = 0; i < dtris.size (); i++) {
        println("  Triangle: " + dtris.get(i).getId());
      }
    }
    println("");
  }
}

class TriangPoint extends Drawable {

  float x, y;
  String id;
  float rad = 10;

  public TriangPoint(float x, float y) {
    this.x = x;
    this.y = y;
    this.id = x + " " + y;
  }

  public TriangPoint(TriangulationPoint p1) {
    this((float)p1.getX(), (float)p1.getY());
  }

  public TriangPoint(String id) {
    String [] split = id.split(" ");
    this.x = Float.parseFloat(split[0]);
    this.y = Float.parseFloat(split[1]);
    this.id = id;
  }

  public void render() {
    stroke(this.cstroke);
    color cfill = isSelected() ? chighlight: cbackground;
    fill(cfill);
    ellipse(x, y, rad, rad);
    if (isSelected()) {
      fill(color(255, 0, 0));
      text("node: " + id, 20, 20);
    }
  }


  boolean isSelected() {
    if (mouseX >= x - rad && mouseX <= x + rad && mouseY >= y - rad && mouseY <= y + rad) {
      return true;
    }
    return false;
  }
}

class Triang extends Drawable {

  float y23, x32, y31, x13, det, minD, maxD;
  TriangPoint[] points;

  ArrayList<Triang> parents;
  ArrayList<Triang> children;

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
    this.parents = new ArrayList<Triang>();
    this.children = new ArrayList<Triang>();
  }

  public Triang(TriangPoint p1, TriangPoint p2, TriangPoint p3) {
    this(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  }

  public Triang(DelaunayTriangle dt) { 
    this((float)dt.points[0].getX(), (float)dt.points[0].getY(), 
    (float)dt.points[1].getX(), (float)dt.points[1].getY(), 
    (float)dt.points[2].getX(), (float)dt.points[2].getY());
  }

  public void addParent(Triang parent) {
    parents.add(parent);
  }

  public void addChild(Triang child) {
    children.add(child);
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
    stroke(this.cstroke);
    fill(this.cbackground);
    triangle(points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
    points[0].render();
    points[1].render();
    points[2].render();
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

