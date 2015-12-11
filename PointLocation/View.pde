class View {

  float x1, x2, y1, y2, w, h; // local view dimensions
  color background;

  public View(float _x1, float _y1, float _x2, float _y2) {
    this.updateSize(_x1, _y1, _x2, _y2);
    this.background = color(255);
  }

  void updateSize(float _x1, float _y1, float _x2, float _y2) {
    this.x1 = _x1;
    this.y1 = _y1;
    this.x2 = _x2;
    this.y2 = _y2;
    this.w = x2 - x1;
    this.h = y2 - y1;
  }

  boolean pointInView(float x, float y) {
    if (x >= x1 && x <= x2 && y >= y1 && y <= y2) {
      return true;
    }
    return false;
  }
}