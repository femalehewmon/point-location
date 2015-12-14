
class PolygonView extends View {

  Polygon polygon;

  public PolygonView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
    this.polygon = new Polygon();
  }

  void render() {
    stroke(this.cstroke);
    fill(this.cbackground);
    rect(x1, y1, w, h);
    polygon.render();
  }

  void handleMouseClickEvent() {
    if (pointInView(mouseX, mouseY)) {
      polygon.addPoint(mouseX, mouseY);
    }
  }

  void handleMousePressEvent() {
    if (pointInView(mouseX, mouseY)) {
      polygon.tryPointInPolygon();
    }
  }
}