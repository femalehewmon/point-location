abstract class Drawable {

  float x = 0;
  float y = 0;
  ColorPalette cbackground, cstroke, chighlight;

  public Drawable(ColorPalette background, ColorPalette stroke, ColorPalette highlight) {
    this.cbackground = background;
    this.cstroke = stroke;
    this.chighlight = highlight;
  }

  public Drawable() {
    this(cgenerator.getDefault(1), cgenerator.getDefault(0), cgenerator.getDefault(0));
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
    fill(cbackground.getColor());
    ellipse(x, y, rad, rad);
  }
}