
class ComplexityTree {

  Canvas canvas;
  SquareView boundedView;

  int xMargin = 20;
  int yMargin = 20;

  int animationStep = 0;
  Tree root;
  TreeDrawHelper treeHelper;

  public ComplexityTree(Canvas canvas) {
    this.canvas = canvas;
    this.boundedView = new SquareView(
      canvas.x1 + xMargin, canvas.y1 + yMargin, 
      canvas.x2 - xMargin, canvas.y2 - yMargin);
    treeHelper = new TreeDrawHelper();
  }

  private void loadTree(Triangulation triangulation) {
    println("building tree");
    root = triangulation.buildTree();
    println("laying out tree");
    layoutTree();
    resetAnimation(true);
  }

  private void layoutTree() {
    if (root != null) {
      // set relative positions of tree nodes
      treeHelper.buchheim(root);
      // scale relative positions to draw icons correctly on canvas
      BoundingBox boundingBox = new BoundingBox(root.minX, root.minY, root.maxX, root.maxY);
      boundingBox.setScreenBounds(boundedView.x1, boundedView.y1, boundedView.x2, boundedView.y2);
      treeHelper.layoutIcons(root, boundingBox);
    } else {
      println("Tree is null...");
    }
  }

  public void resetAnimation(boolean bottomUp) {
    if (bottomUp) {
      animationStep = root.maxLevel;
    } else {
      animationStep = 0;
    }
  }

  public void render(boolean animate) {
    canvas.render();
    //boundedView.render();
    if (root != null) {
      if (animate) {
        root.render(animationStep);
        animationStep++;
      } else {
        root.render(0, true); // force full render by bottomUp, minLevel 0
      }
    }
  }

  public void render() {
    render(false);
  }

  public void renderBottomUp() {
    root.render(animationStep);
    animationStep--;
  }
}

class Tree {

  String id;
  float x, y;
  float minX, maxX, minY, maxY; // relative positions of subtrees

  int level = 0;
  int maxLevel = 0;

  Tree parent;
  ArrayList<Tree> children;
  int childCount = 0;

  Drawable icon;
  color cedge;

  boolean drawIcon;

  // buccheim specific values
  Tree leftmostSibling, thread, ancestor;
  float mod, change, shift;
  int number;

  public Tree(String id) {
    this(id, null, null);
  }

  public Tree(String id, Tree parent) {
    this(id, parent, null);
  }

  public Tree(String id, Tree parent, Drawable icon) {
    this.id = id;
    if (parent == null) {
      this.parent = null;
      this.level = 0;
    } else {
      this.parent = parent;
      this.level = parent.level + 1;
      this.parent.updateMaxLevel(this.level);
    }
    if (icon == null) {
      this.icon = new Circ(0, 0);
    } else {
      this.icon = icon;
    }
    this.children = new ArrayList<Tree>();
    this.cedge = color(0);
    //buccheim defaults
    this.x = -1;
    this.y = 9;
    this.thread = null;
    this.mod = 0;
    this.ancestor = this;
    this.change = 0;
    this.shift = 0;
    this.leftmostSibling = null;
    this.number = 1;
  }

  public void addChildNode(Tree child) {
    child.parent = this;
    children.add(child);
    childCount++;
  }

  boolean contains(Tree child) {
    if (children.contains(child)) {
      return true;
    } else {
      for (int i =0; i < children.size(); i++) {
        if (children.get(i).contains(child)) {
          println("found child");
          return true;
        }
      }
    }
    return false;
  }

  private void updateMaxLevel(int maxLevel) {
    if (maxLevel > this.maxLevel) {
      this.maxLevel = maxLevel;
      if (parent != null) {
        parent.updateMaxLevel(maxLevel); // push max up the tree
      }
    }
  }

  public void setIconPosition(BoundingBox bounds) {
    this.icon.x = bounds.scaleX(this.x);
    this.icon.y = bounds.scaleY(this.y);
    for (int i = 0; i < children.size(); i++) {
      children.get(i).setIconPosition(bounds);
    }
  }

  public void setX(float x) {
    this.x = x;
    updateMinMaxX(x);
  }

  public void setY(float y) {
    this.y = y;
    updateMinMaxY(y);
  }

  private void updateMinMaxX(float x) {
    if (x < this.minX) {
      this.minX = x;
      if (parent != null) {
        parent.updateMinMaxX(x); // push min x further up tree
      }
    }
    if (x > this.maxX) {
      this.maxX = x;
      if (parent != null) {
        parent.updateMinMaxX(x); // push max x further up tree
      }
    } // else, current subtree has greater max x position
  }

  private void updateMinMaxY(float y) {
    if (y < this.minY) {
      this.minY = y;
      if (parent != null) {
        parent.updateMinMaxY(y); // push min y further up tree
      }
    }
    if (y > this.maxY) {
      this.maxY = y;
      if (parent != null) {
        parent.updateMinMaxY(y); // push max y further up tree
      }
    } // else, current subtree has greater max y position, no need to push further
  }


  public void render(int levelToRender, boolean bottomUp) {
    if (bottomUp) {
      if (level >= levelToRender) {
        drawIcon = true;
      } else {
        drawIcon = false;
      }
    } else {
      if (level <= levelToRender) {
        drawIcon = true;
      } else {
        drawIcon = false;
      }
    }
    if (drawIcon) {
      render();
    }
    for (int i = 0; i < children.size(); i++) {
      children.get(i).render(levelToRender, bottomUp);
    }
  }

  public void render(int levelToRender) {
    render(levelToRender, false);
  }

  public void render() {
    icon.render();
  }

  Tree left() {
    Tree left = thread;
    if (left == null) {
      if (childCount > 0) {
        left = children.get(0);
      }
    }
    println("found left borther " + left);
    return left;
  }

  Tree right() {
    Tree right = thread;
    if (right == null) {
      if (childCount > 0) {
        right = children.get(childCount - 1);
      }
    }
    return right;
  }

  Tree getLeftBrother() {
    Tree lbro = null;
    if (parent != null) {
      println("parent is not null");
      for (int i = 0; i < parent.children.size(); i++) {
        Tree pchild = parent.children.get(i);

        println("looking at parent child, is " + pchild.id + " equal to " + id);
        if (pchild.id == this.id) {
          return lbro;
        } else {
          lbro = pchild;
        }
      }
    }
    return lbro;
  }

  Tree getLeftmostSibling() {
    if (leftmostSibling == null) {
      if (parent != null && parent.children.size() > 0) {
        leftmostSibling = parent.children.get(0);
      }
    }
    return leftmostSibling;
  }
}