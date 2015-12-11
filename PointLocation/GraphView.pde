
class GraphView extends View {

  public GraphView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
  }

  void render() {
    stroke(this.cstroke);
    fill(this.cbackground);
    rect(x1, y1, w, h);
  }

  void handleMouseClickEvent() {
    if (pointInView(mouseX, mouseY)) {
    }
  }
}