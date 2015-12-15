class ColorPalette {

  String name;
  int baseR;
  int baseG;
  int baseB;

  float maxRange = 0.75;
  float minRange = 0.10;

  public ColorPalette(String name, int r, int g, int b) {
    this.name = name;
    this.baseR = r;
    this.baseG = g;
    this.baseB = b;
  } 

  color getColor() {
    return getColor(1);
  }

  color getColor(float ratio) {
    float scaledRatio = ((maxRange - minRange)*ratio) + minRange;
    scaledRatio = 1 - scaledRatio;
    return color(muteColor(this.baseR, scaledRatio), muteColor(this.baseG, scaledRatio), muteColor(this.baseB, scaledRatio));
  }

  color getMutedColor() {
    return getMutedColor(1);
  }

  float muteColor = 0.50;
  color getMutedColor(float ratio) {
    color fullColor = getColor(ratio);
    return color(muteColor(red(fullColor), muteColor), muteColor(green(fullColor), muteColor), muteColor(blue(fullColor), muteColor));
  }

  float muteColor(float c, float scale) {
    return ((255 - c) * scale) + c;
  }
}