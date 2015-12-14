import megamu.mesh.*;

ViewFactory viewFactory;

CreatePolygon polyView;
TreeView treeView;

void setup() {
  size(1300, 800);

  viewFactory = new ViewFactory();

  Canvas leftCanvas = new Canvas(0, 0, width/2, height, 20, 20);
  Canvas rightCanvas = new Canvas(width/2, 0, width, height);

  polyView = new CreatePolygon(leftCanvas);
  treeView = new TreeView(width/2, 0, width, height);
}

void draw() {
  //background(0);
  polyView.render();
  treeView.render();
}

void mouseClicked(MouseEvent e) {
  polyView.handleMouseClickEvent();
}

void mousePressed(MouseEvent e) {
  polyView.handleMousePressEvent();
}