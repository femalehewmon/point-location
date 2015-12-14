class ControlsView {

  Canvas canvas;
  PlayPauseButton playPauseButton;
  ControlButton leftControl;
  ControlButton rightControl;

  public ControlsView(Canvas canvas) {
    this.canvas = canvas;
    playPauseButton = new PlayPauseButton(canvas.x1 + canvas.w/2, canvas.y1, canvas.x1 + canvas.w/2 + 10, canvas.y2);
    //leftControl = new ControlButton();
    rightControl = new ControlButton(canvas.x1, canvas.y1, canvas.x1 + 10, canvas.y2);
  }

  void render() {
    canvas.render();
    playPauseButton.render();
    //leftControl.render(canvas.x1 + canvas.w/2, canvas.y1, canvas.x1 + canvas.w/2 + 10, canvas.y2);
    rightControl.render();
  }
}

class PlayPauseButton {

  float x1, x2, y1, y2, w, h;
  boolean isPlaying;

  public PlayPauseButton(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
    this.w = x2 - x1;
    this.h = y2 - y1;
    this.isPlaying = false;
  }

  void togglePlay() {
    if (isPlaying) {
      isPlaying = false;
    } else {
      isPlaying = true;
    }
  }

  void render() {
    if (isPlaying) {
      drawPauseButton();
    } else {
      drawPlayButton();
    }
  }

  void drawPlayButton() {
    //draw background button
    stroke(color(0));
    fill(color(255));
    rect(x1, y1, w, h, 7);

    // draw sideways triangle
    fill(color(0));
    rect(x1 + w/4, y1 + h/2 - h/4, w/2, h/4);
  }

  void drawPauseButton() {
    // draw background button
    stroke(color(0));
    fill(color(255));
    rect(x1, y1, w, h, 7);

    // draw equals sign
    fill(color(0));
    rect(x1 + w/4, y1 + h/2 - h/4, w/2, h/4);
  }
}

class ControlButton {

  float x1, x2, y1, y2, w, h;
  boolean isPlaying;

  public ControlButton(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
    this.w = x2 - x1;
    this.h = y2 - y1;
    this.isPlaying = false;
  }

  void togglePlay() {
    if (isPlaying) {
      isPlaying = false;
    } else {
      isPlaying = true;
    }
  }

  void render() {
    if (isPlaying) {
      drawPauseButton();
    } else {
      drawPlayButton();
    }
  }

  void drawPlayButton() {
    //draw background button

    // draw sideways triangle
  }

  void drawPauseButton() {
    // draw background button
    stroke(color(0));
    fill(color(255));
    rect(x1, y1, w, h, 7);

    // draw equals sign
    fill(color(0));
    rect(x1 + w/4, y1 + h/2 - h/4, w/2, h/4);
  }
}