class Triangulation {
  
  public Triangulation() {
    
  }
  
  public void addTriangle(){
    
  }
  
  public void removeTriangle(PVector p1, PVector p2, PVector p3){
    
  }
  
}

class DrawableTriangle extends Drawable {

  float x1, x2, x3, y1, y2, y3;
  float y23, x32, y31, x13, det, minD, maxD;

  public DrawableTriangle(float x1, float y1, float x2, float y2, float x3, float y3) {
    this.x1 = x1;
    this.x2 = x2;
    this.x3 = x3;
    this.y1 = y1;
    this.y2 = y2;
    this.y3 = y3;
    this.y23 = y2 - y3;
    this.x32 = x3 - x2;
    this.y31 = y3 - y1;
    this.x13 = x1 - x3;
    this.det = y23 * x13 - x32 * y31;
    this.minD = Math.min(det, 0);
    this.maxD = Math.max(det, 0);
  }

  void render() {
  }

  boolean isSelected() {
    // http://stackoverflow.com/a/25346777
    double dx = mouseX - x3;
    double dy = mouseY - y3;
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

