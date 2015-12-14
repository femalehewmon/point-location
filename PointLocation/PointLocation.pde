
GeometricView geomView;
TreeView treeView;

void setup() {
  size(1300, 800);
  geomView = new GeometricView(0, 0, width/2, height);
  treeView = new TreeView(width/2, 0, width, height);
}

void draw() {
  //background(0);
  geomView.render();
  treeView.render();
}

void mouseClicked(MouseEvent e) {
  geomView.handleMouseClickEvent();
}

void mousePressed(MouseEvent e) {
  geomView.handleMousePressEvent();
}