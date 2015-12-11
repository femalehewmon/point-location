
class GeometricalView extends View {

  public GeometricalView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
  }

  void render() {
    fill(this.background);
    rect(x1, y1, w, h);
  }
  
}