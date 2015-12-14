import megamu.mesh.*;
import org.orourke.*;
import org.orourke.cVertexList;

ViewFactory viewFactory;

CreatePolygon polyView;
TreeView treeView;
ControlsView controlsView;

int CONTROLS_HEIGHT = 100;

void setup() {
  size(1300, 800);

  viewFactory = new ViewFactory();

  Canvas leftCanvas = new Canvas(0, 0, width/2, height - CONTROLS_HEIGHT, 20, 20);
  Canvas rightCanvas = new Canvas(width/2, 0, width, height);
  Canvas controlCanvas = new Canvas(0, height - CONTROLS_HEIGHT, width/2, height);

  polyView = new CreatePolygon(leftCanvas);
  treeView = new TreeView(width/2, 0, width, height);
  controlsView = new ControlsView(controlCanvas);
}

void draw() {
  //background(0);
  polyView.render();
  treeView.render();
  controlsView.render();
}

void mouseClicked(MouseEvent e) {
  polyView.handleMouseClickEvent();
}

void mousePressed(MouseEvent e) {
  polyView.handleMousePressEvent();
}