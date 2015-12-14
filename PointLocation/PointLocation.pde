
PolygonView polyView;
TreeView treeView;

void setup() {
  size(1300, 800);
  polyView = new PolygonView(0, 0, width/2, height);
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