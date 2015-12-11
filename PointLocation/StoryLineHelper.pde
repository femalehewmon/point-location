class StoryLineHelper {

  String MODE_DRAW_POLYGON = "drawpoly";
  String MODE_DRAW_OUTER_TRIANGLE = "outertri";
  String MODE_TRIANGULATE = "triangulate";
  String MODE_FIND_UNIQUE_SET = "finduniqset";
  String MODE_DELETE_UNIQUE_SET = "deleteuniqset";

  String START = "start";
  String WORKING = "working";
  String END = "end";
  String WAITING = "waiting";

  Point[] defaultPolyPoints = {new Point(10, 10), new Point(20, 20), new Point(30, 30), new Point (60, 80)};

  String getCurrentMode() {
    return MODE_DRAW_POLYGON;
  }
}