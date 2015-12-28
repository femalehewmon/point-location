import org.poly2tri.*;

ViewFactory viewFactory;
ColorPaletteGenerator cgenerator;

CreatePolygon polyView;
ComplexityTree treeView;
ControlsView controlsView;
Canvas welcomeCanvas;

int CONTROLS_HEIGHT = 100;

boolean demo;

boolean welcome = true;

void setup() {
  size(700, 700);

  viewFactory = new ViewFactory();
  cgenerator = new ColorPaletteGenerator();

  welcomeCanvas = new Canvas(0, 0, width, height);

  Canvas leftCanvas = new Canvas(0, 0, width/2, height - CONTROLS_HEIGHT, 20, 20);
  Canvas rightCanvas = new Canvas(width/2, 0, width, height);
  Canvas controlCanvas = new Canvas(0, height - CONTROLS_HEIGHT, width, height);

  Canvas fullCanvas = new Canvas(0, 0, width, height - CONTROLS_HEIGHT);

  controlsView = new ControlsView(controlCanvas);
  polyView = new CreatePolygon(fullCanvas);
  //polyView.loadDemo("demo7x7.poly");
  //treeView = new ComplexityTree(rightCanvas);
}

void draw() {
  if (welcome) {
    welcomeCanvas.render();
    fill(color(0));
    textAlign(CENTER);
    text("A Short Look at Kirkpatrick's Point Location Data Structure.", width/2 - 100, height/2 - 100, 200, 200);
  } else {

    //background(0);
    polyView.render();
    //treeView.render();
    controlsView.render();
  }
}

void mouseClicked(MouseEvent e) {
  welcome = false;
  polyView.handleMouseClickEvent();
}

void mousePressed(MouseEvent e) {
  polyView.handleMousePressEvent();
}
