
TriangPoint maxLeft = null;
TriangPoint maxTop = null;
TriangPoint maxRight = null;

class Triangulation {

  Triang rootTriang;
  HashMap<String, ArrayList<Triang>> triangMap;

  ArrayList<Triang> removedTriangles;
  ArrayList<Triang> newTriangles;
  ArrayList<TriangPoint> removedPoints;

  int level = 0;

  public Triangulation() {
    this.rootTriang = null;
    this.triangMap = new HashMap<String, ArrayList<Triang>>();
    this.removedTriangles = new ArrayList<Triang>();
    this.removedPoints = new ArrayList<TriangPoint>();
    this.newTriangles = new ArrayList<Triang>();
  }

  public void render() {    
    for (String key : triangMap.keySet ()) {
      ArrayList<Triang> triangs = triangMap.get(key);
      for (int i = 0; i < triangs.size (); i++) {
        triangs.get(i).render();
      }
    }
    for (int i = 0; i < removedTriangles.size(); i++) {
      removedTriangles.get(i).render();
    }

    for (int i = 0; i < removedPoints.size(); i++) {
      removedPoints.get(i).mark();
      removedPoints.get(i).render();
    }
  }

  HashMap<String, Tree> treeNodes = new HashMap<String, Tree>();
  public void resetTrees() {
    treeNodes.clear();
  }

  public Tree buildTree() {
    Tree pointLocStructure = null;
    resetTrees();
    if (rootTriang != null) {
      createBaseTrees(rootTriang);
      buildTreeHelper(rootTriang);
      pointLocStructure = treeNodes.get(rootTriang.id);
    }
    return pointLocStructure;
  }

  private void createBaseTrees(Triang triang) {
    if (!treeNodes.containsKey(triang.id)) {
      Tree tree = new Tree(triang.id);
      treeNodes.put(triang.id, tree);
    }
    for (int j = 0; j < triang.children.size(); j++) {
      Triang child = triang.children.get(j);
      createBaseTrees(child);
    }
  }

  private void buildTreeHelper(Triang triang) {
    Tree tree;
    if (treeNodes.containsKey(triang.id)) {
      tree = treeNodes.get(triang.id);
    } else {
      println("TREE NOT FOUND!!!");
      return;
    }

    Tree parentTree;
    for (int i = 0; i < triang.parents.size(); i++) { // for each parent, add this node to its tree
      if (treeNodes.containsKey(triang.parents.get(i).id)) {
        parentTree = treeNodes.get(triang.parents.get(i).id);
        if (!parentTree.contains(tree)) {
          parentTree.addChildNode(tree);
        }
      } else {
        println("SOMETHIGN IS WRONG, missing node " + triang.parents.get(i).id);
      }
    }
    for (int j = 0; j < triang.children.size(); j++) {
      buildTreeHelper(triang.children.get(j));
    }
  }

  void retriangulateHole() {
    // add new triangles to hash map
    addTriangles(newTriangles);
    for (int ittter = 0; ittter < newTriangles.size (); ittter++) {
      Triang newTriangle = newTriangles.get(ittter);
      for (int k = 0; k < removedTriangles.size (); k++) {
        removedTriangles.get(k).addParent(newTriangle);
        newTriangle.addChild(removedTriangles.get(k));
      }
      rootTriang = newTriangle;
    }
    newTriangles.clear();
  }

  void removeMarkedVertices() {
    removedTriangles.clear();
    removedPoints.clear();
  }

  boolean markLowDegreeIndependentSet(Polygon poly) {
    println("MARKING");
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
      removedTriangles = new ArrayList<Triang>(); // kept to assign child/parent relationships
      for (int i = 0; i < pointsToSearch.size (); i++) {
        TriangPoint currPoint = new TriangPoint(pointsToSearch.get(i));
        if (currPoint.id.equals(maxLeft.id) || currPoint.id.equals(maxTop.id) || currPoint.id.equals(maxRight.id)) {
          // don't try to remove outer vertex points
          continue;
        }
        int degree = triangMap.get(currPoint.id).size();
        println("set, degree: " + degree);
        if (degree <= 8 && !neighbors.contains(currPoint.id)) {
          ArrayList<Triang> connectedTris = triangMap.get(currPoint.id);
          println("Found independent set, degree: " + degree);

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
          for (int iter = 0; iter < numberOfTriangles; iter++) {
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
            removeTriangle(currTri);
          }
          // remove old point from hashmap
          removePoint(currPoint);

          // triangulate the hole left behind
          Polygon emptyPoly = new Polygon(emptyPolyPoints);
          Poly2Tri.triangulate(emptyPoly);
          ArrayList<DelaunayTriangle> triPointsToMerge = (ArrayList)emptyPoly.getTriangles();

          // add new triangles to hash map
          println("Hole points added: " + triPointsToMerge.size() + ", removed: " + removedTriangles.size());
          for (int ittter = 0; ittter < triPointsToMerge.size (); ittter++) {
            Triang newTriangle = new Triang(triPointsToMerge.get(ittter));
            newTriangles.add(newTriangle);
            //addTriangle(newTriangle);
            for (int k = 0; k < removedTriangles.size (); k++) {
              removedTriangles.get(k).addParent(newTriangle);
              newTriangle.addChild(removedTriangles.get(k));
            }
            rootTriang = newTriangle;
          }

          setLevel(level++);
        }
      }
      return false;
    } else {
      // set if fully reduced, you are done!
      return true;
    }
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
    ColorPalette cp = cgenerator.getNextColorPalette();
    for (int i = 0; i < dts.size (); i++) {
      try {
        addTriangle((Triang)dts.get(i), cp);
      } 
      catch(Exception e) {
        addTriangle((DelaunayTriangle)dts.get(i), cp);
      }
    }
    //printHashMap();
  }

  public void addTriangle(DelaunayTriangle dt, ColorPalette cp) {
    TriangPoint tp1 = new TriangPoint(dt.points[0]);
    TriangPoint tp2 = new TriangPoint(dt.points[1]);
    TriangPoint tp3 = new TriangPoint(dt.points[2]);
    Triang tri = new Triang(tp1, tp2, tp3);
    addTriangle(tri, cp);
  }

  public void addTriangle(Triang triang, ColorPalette cp) {
    addPointToMap(triang.points[0], triang);
    addPointToMap(triang.points[1], triang);
    addPointToMap(triang.points[2], triang);
    triang.cbackground = cp;
    triang.chighlight = cp;
    println("Adding triangle: " + triang.id);
    //treeView.addToPotentialTrees(triang.id);
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
    removedPoints.add(tp);
  }

  public void removeTriangle(Triang triang) {
    int removeCount = 0;
    for (String key : triangMap.keySet ()) {
      if (triangMap.get(key).contains(triang)) {
        triangMap.get(key).remove(triang);
        removeCount ++;
      }
    }

    removedTriangles.add(triang);
  }

  private void setLevel(int level) {
    for (String key : triangMap.keySet ()) {
      for (int i = 0; i < triangMap.get(key).size (); i++) { // for list of triangles for each point
        triangMap.get(key).get(i).level = level;
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
  boolean toRemove = false;
  color ctoRemove;

  public TriangPoint(float x, float y) {
    this.x = x;
    this.y = y;
    this.id = x + " " + y;
    this.ctoRemove = color(255, 0, 0);
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

  public void mark() {
    toRemove = true;
  }

  public void render() {
    if (!id.equals(maxLeft.id) && !id.equals(maxTop.id) && !id.equals(maxRight.id)) {
      stroke(this.cstroke.getColor());
      color cfill = toRemove ? ctoRemove : cbackground.getColor();
      cfill = isSelected() ? chighlight.getColor() : cfill;
      fill(cfill);
      ellipse(x, y, rad, rad);
      if (isSelected()) {
        //fill(color(255, 0, 0));
        //text("node: " + id, 20, 20);
      }
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

  int level = 0;
  String id;

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
    this.id = x1 + " " + y1 + " " + x2 + " " + y2 + " " + x3 + " " + y3;
  }

  public Triang(TriangPoint p1, TriangPoint p2, TriangPoint p3) {
    this(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  }

  public Triang(DelaunayTriangle dt) { 
    this((float)dt.points[0].getX(), (float)dt.points[0].getY(), 
      (float)dt.points[1].getX(), (float)dt.points[1].getY(), 
      (float)dt.points[2].getX(), (float)dt.points[2].getY());
  }

  public void buildTree(TreeView treeView) {
    for (int i = 0; i < parents.size(); i++) {
      treeView.addChild(parents.get(i).id, this.id);
    }
    if (parents.size() <= 0) {
      treeView.addChild(null, this.id);
    }

    for (int i = 0; i < children.size(); i++) {
      children.get(i).buildTree(treeView);
    }
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
    stroke(this.cstroke.getColor());
    color cfill = isSelected() ? color(39, 58, 200): cbackground.getColor();
    fill(cfill);
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