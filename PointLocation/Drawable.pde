abstract class Drawable {

  float x = 0;
  float y = 0;
  color cbackground, cstroke, chighlight;

  public Drawable(color background, color stroke, color highlight) {
    this.cbackground = background;
    this.cstroke = stroke;
    this.chighlight = highlight;
  }

  public Drawable() {
    this(color(255), color(0), color(0));
  }

  abstract void render();
}

class Circ extends Drawable {

  float x, y;
  float rad = 10;

  public Circ(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void render() {
    fill(cbackground);
    ellipse(x, y, rad, rad);
  }
}