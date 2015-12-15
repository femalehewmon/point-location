
class ColorPaletteGenerator {

  int currentColorIndex;
  HashMap<String, ColorPalette> savedColors;

  ArrayList<ColorPalette> baseColors;

  public ColorPaletteGenerator() {
    this.currentColorIndex = 0;
    this.savedColors = new HashMap<String, ColorPalette>();
    populateBaseColors();
  }

  public ColorPalette getDefault(int isWhite) {
    if (isWhite == 1) {

      return new ColorPalette("White", 255, 255, 255);
    } else {
      return new ColorPalette("Black", 0, 0, 0);
    }
  }

  private void populateBaseColors() {
    // Color palettes based on https://eleanormaclure.files.wordpress.com/2011/03/colour-coding.pdf
    // Alphabet colors based on study of the influence of color choice and simultaneous contrast
    this.baseColors = new ArrayList<ColorPalette>();
    baseColors.add(new ColorPalette("Amethyst", 240, 163, 255));
    baseColors.add(new ColorPalette("Blue", 0, 117, 220));
    //baseColors.add(new ColorPalette("Caramel", 153, 63, 0));
    baseColors.add(new ColorPalette("Damson", 76, 0, 92));
    //baseColors.add(new ColorPalette("Ebony", 25, 25, 25));
    baseColors.add(new ColorPalette("Forest", 0, 92, 49));
    baseColors.add(new ColorPalette("Green", 43, 206, 72));
    baseColors.add(new ColorPalette("Honeydew", 255, 204, 153));
    //baseColors.add(new ColorPalette("Iron", 128, 128, 128));
    //baseColors.add(new ColorPalette("Jade", 148, 255, 181));
    baseColors.add(new ColorPalette("Khaki", 143, 124, 0));
    baseColors.add(new ColorPalette("Lime", 157, 204, 0));
    baseColors.add(new ColorPalette("Mallow", 194, 0, 136));
    baseColors.add(new ColorPalette("Navy", 0, 51, 128));
    baseColors.add(new ColorPalette("Orpiment", 255, 164, 5));
    baseColors.add(new ColorPalette("Pink", 255, 168, 187));
    baseColors.add(new ColorPalette("Quagmire", 66, 102, 0));
    baseColors.add(new ColorPalette("Red", 255, 0, 16));
    baseColors.add(new ColorPalette("Sky", 94, 241, 242));
    baseColors.add(new ColorPalette("Turquoise", 0, 153, 143));
    baseColors.add(new ColorPalette("Uranium", 244, 255, 102));
    baseColors.add(new ColorPalette("Violet", 116, 10, 255));
    baseColors.add(new ColorPalette("Wine", 153, 0, 0));
    baseColors.add(new ColorPalette("Xanthin", 255, 255, 128));
    baseColors.add(new ColorPalette("Yellow", 255, 255, 0));
    baseColors.add(new ColorPalette("Zinnia", 255, 80, 5));
  }

  public ColorPalette getColorPalette(String id) {
    ColorPalette cp = null;
    if (savedColors.containsKey(id)) {
      cp = savedColors.get(id);
    } else {
      cp = getNextColorPalette();
      savedColors.put(id, cp);
    }
    return cp;
  }

  ColorPalette getNextColorPalette() {
    ColorPalette nextColor = baseColors.get(currentColorIndex); 
    currentColorIndex++;
    if (currentColorIndex >= baseColors.size()) {
      currentColorIndex = 0;
    }
    return nextColor;
  }
}