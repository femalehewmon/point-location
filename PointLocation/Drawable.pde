class Drawable {

  color cbackground, cstroke, chighlight;

  public Drawable(color background, color stroke, color highlight) {
    this.cbackground = background;
    this.cstroke = stroke;
    this.chighlight = highlight;
  }

  public Drawable() {
    this(color(255), color(0), color(0));
  }

  void render(View boundingView) {
  
  }
  
}