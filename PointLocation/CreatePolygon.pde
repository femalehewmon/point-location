
class CreatePolygon {

  int STEPS = 12;

  int loopCount = 0;
  int loopMax = 0;

  Canvas canvas;
  TriangleView triView;
  PolygonPL polygon;

  Polygon innerPoly = null;
  Polygon outerPoly = null;

  Triangulation triangulation;

  int stage = 0;
  int substage = 0;

  int counter = 0;
  int counter2 = 0;

  public CreatePolygon(Canvas canvas) {
    this.canvas = canvas;
    this.triView = viewFactory.getTriangleView(canvas.x1, canvas.y2, canvas.x1 + canvas.w/2, canvas.y1, canvas.x2, canvas.y2);
    this.polygon = new PolygonPL();
    this.triangulation = new Triangulation();
    controlsView.setText("Click in above triangle to create non-overlapping polygon");
  }

  void render() {
    canvas.render();
    triView.render();
    if (polygon.isComplete) {
      if (stage == 0) {
        if (counter >= STEPS) {
          println("Triangulated inner");
          triangulateInnerPolygon();
          stage = 1;
          counter = 0;
          controlsView.setText("Triangulated Polygon");
        } else {
          polygon.render(triView);
          controlsView.setText("Well done, your polygon is now complete!");
        }
        counter++;
      } else if (stage == 1) {
        if (counter >= STEPS) {
          println("Triangulated outer");
          triangulateOuterPolygon();
          stage = 11;
          counter = 0;
          triView.cbackground = color(240, 240, 240);
          controlsView.setText("Triangulated the surrounding area outside your polygon");
        }
        counter++;
      } else if (stage == 11) {
        if (counter >= STEPS/2) {
          stage = 2;
          counter = 0;
          triView.cbackground = color(240, 240, 240);
          controlsView.setText("Triangulated the surrounding area outside your polygon");
        }
        counter++;
      } else if (stage == 2) {
        if (substage == 0) {
          String text = "Searching for non-adjacent vertices with a degree <= 8";
          if (loopCount == 1) {
            text += "...    Keep going!";
          } else if (loopCount == 2) {
            text += "...    Seems a bit Sysiphean, doesn't it?";
          } else if (loopCount == 3) {
            text += "...    Almost there..";
          } else if (loopCount == 4) {
            text += "...    Just kidding, there's still more to go!";
          }
          controlsView.setText(text);
        }
        if (counter >= STEPS) {
          if (substage == 0) {
            loopCount++;
            println("Remove independent low vertex set");
            if (triangulation.markLowDegreeIndependentSet(innerPoly)) {
              stage = 3;
              triangulation.removeMarkedVertices();
              triangulation.retriangulateHole();
            }
            controlsView.setText("Found some!");
            substage = 1;
          } else if (substage == 1) {
            triangulation.removeMarkedVertices();
            controlsView.setText("Now let's remove them...");
            substage = 2;
          } else if (substage == 2) {
            triangulation.retriangulateHole();
            controlsView.setText("...and fill them in with new triangles.");
            substage = 3;
          } else if (substage == 3) {
            substage = 0;
          }

          counter = 0;
        }
        counter++;
      } else if (stage == 3) {
        controlsView.setText("Whew! Finally our data structure is done.\nIf I were a faster programmer we would now take a look at that data structure, but that will have to come later.\nThanks for looking!");
        println("here");
        stage = 4;
        //triangulation.rootTriang.buildTree(treeView);
        if (treeView != null) {
          treeView.loadTree(triangulation);
        }
      }
      triangulation.render();
      //polygon.render(triView);
    } else {
      polygon.render(triView);
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

