
class GraphView extends View {

  public GraphView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
  }

  void render() {
    fill(this.background);
    rect(x1, y1, w, h);
  }

  void handleMouseClickEvent(MouseEvent e) {
    if (pointInView(e.getX(), e.getY())) {
    }
  }
}