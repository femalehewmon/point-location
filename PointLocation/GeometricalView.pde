
class GeometricalView extends View {

  Polygon polygon;

  public GeometricalView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
    this.polygon = new Polygon();
  }

  void render() {
    fill(this.background);
    rect(x1, y1, w, h);
    polygon.render();
  }

  void handleMouseClickEvent(MouseEvent e) {
    if (pointInView(e.getX(), e.getY())) {
      polygon.addPoint(e.getX(), e.getY());
    }
  }

  void handleMousePressEvent(MouseEvent e) {
    if (pointInView(e.getX(), e.getY())) {
      polygon.tryPoint();
    }
  }
}