class View {

  float x1, x2, y1, y2, w, h; // local view dimensions
  color cbackground, cstroke, chighlight;

  public View(float _x1, float _y1, float _x2, float _y2) {
    this.updateSize(_x1, _y1, _x2, _y2);
    this.cbackground = color(255);
    this.cstroke = color(0);
    this.chighlight = color(255);
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

class BoundingBox {

  float x1, x2, y1, y2;
  float x1Screen, x2Screen, y1Screen, y2Screen;
  float scale = 1;

  public BoundingBox(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }

  public BoundingBox() {
    this(Float.MIN_VALUE, Float.MIN_VALUE, 0, 0);
  }

  void setScreenBounds(float x1s, float y1s, float x2s, float y2s) {
    this.x1Screen = x1s;
    this.x2Screen = x2s;
    this.y1Screen = y1s;
    this.y2Screen = y2s;
  }

  float scaleX(float x) {
    return scaleVal(x, x1, x2, x1Screen, x2Screen);
  }

  float scaleY(float y) {
    return scaleVal(y, y1, y2, y1Screen, y2Screen);
  }

  private float scaleVal(float val, float minRel, float maxRel, float min, float max) {
    return (((max - min)*(val - minRel))/ (maxRel - minRel)) + min;
  }
}