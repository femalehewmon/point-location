
StoryLineHelper slHelper;

GeometricalView geomView;
GraphView graphView;

void setup() {
  size(1300, 800, P3D);
  slHelper = new StoryLineHelper();
  geomView = new GeometricalView(0, 0, width/2, height);
  graphView = new GraphView(width/2, 0, width, height);
}

void draw() {
  background(0);
  geomView.render();
  graphView.render();
}

void mouseClicked(MouseEvent e) {
  println("Mouse clicked");
}