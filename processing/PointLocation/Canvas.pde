class Canvas {

  float x1, y1, x2, y2, w, h;
  float x1full, y1full, x2full, y2full, wfull, hfull;
  color cbackground;

  HashMap<String, View> views;

  public Canvas(float x1, float y1, float x2, float y2, float xMargin, float yMargin) {
    this.x1full = x1;
    this.x2full = x2;
    this.y1full = y1;
    this.y2full = y2;
    this.wfull = x2full - x1full;
    this.hfull = y2full - y1full;
    this.x1 = x1 + xMargin;
    this.y1 = y1 + yMargin;
    this.x2 = x2 - xMargin;
    this.y2 = y2 - yMargin;
    this.w = this.x2 - this.x1;
    this.h = this.y2 - this.y1;
    this.cbackground = color(255);
    this.views = new HashMap<String, View>();
  }

  public Canvas(float x1, float y1, float x2, float y2) {
    this(x1, y1, x2, y2, 10, 10);
  }

  void addChildView(View child) {
    views.put(child.id, child);
  }

  void removeChildView(String id) {
    if (views.containsKey(id)) {
      views.remove(id);
    }
  }

  void render() {
    // draw background canvas
    fill(cbackground);
    rect(x1full, y1full, wfull, hfull);

    for (int i = 0; i < views.size(); i++) {
      views.get(i).render();
    }
  }
  /*
  void handleMouseClickEvent() {
   for (int i = 0; i < views.size(); i++) {
   views.get(i).handleMouseClick();
   }
   }
   */
}