class ViewFactory {

  int idCounter;

  public ViewFactory() {
    this.idCounter = 0;
  }

  TriangleView getTriangleView(float x1, float y1, float x2, float y2, float x3, float y3) {
    return new TriangleView(Integer.toString(idCounter), x1, y1, x2, y2, x3, y3);
  }
}