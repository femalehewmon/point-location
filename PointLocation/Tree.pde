
class TreeOld {
  float RAD = 40;

  String id;
  TreeOld parent;
  ArrayList<TreeOld> children;
  ArrayList<String> childIds;
  int childCount = 0;
  float x, y;
  color cbackground, chighlight;

  TreeOld leftmostSibling, thread, ancestor;
  float mod, change, shift;
  int number;

  boolean isDrawn = false;

  public TreeOld(String id, Tree parent, float depth, int number) {
    this.id = id;
    this.parent = null;
    this.children = new ArrayList<TreeOld>();
    this.childIds = new ArrayList<String>();
    this.cbackground = color(0, 0, 0);
    this.chighlight = color(255, 0, 0);

    //buccheim specific variables
    this.x = -1;
    this.y = depth;
    this.thread = null;
    this.mod = 0;
    this.ancestor = this;
    this.change = 0;
    this.shift = 0;
    this.leftmostSibling = null;
    this.number = number;
  }

  public TreeOld(String id) {
    this(id, null, 0, 1);
  }

  void render(BoundingBox bounds) {
    color cfill = mouseInPoint(bounds) ? chighlight: cbackground;
    fill(cfill);
    ellipse(bounds.scaleX(this.x), bounds.scaleY(this.y), RAD, RAD);
    boolean isOdd = true;
    for (int i =0; i < childCount; i++) {
      if (childCount > 10) {
        if (isOdd) {
          bounds.y2 -= 10;
          isOdd = false;
        } else {
          bounds.y2 += 10;
          isOdd = true;
        }
      }
      children.get(i).render(bounds);
      line(bounds.scaleX(this.x), bounds.scaleY(this.y) + RAD/2, 
        bounds.scaleX(children.get(i).x), bounds.scaleY(children.get(i).y) - RAD/2);
    }
  }

  boolean mouseInPoint(BoundingBox bounds) {
    boolean mouseInPoint = false;
    if (mouseX >= (bounds.scaleX(this.x) - RAD) && mouseX <= (bounds.scaleX(this.x) + RAD)
      && mouseY >= (bounds.scaleY(this.y) - RAD) && mouseY <= (bounds.scaleY(this.y) + RAD)) {
      mouseInPoint = true;
    }
    return mouseInPoint;
  }

  void updateBounds(BoundingBox boundBox) {
    if (boundBox.x1 == Float.MIN_VALUE || this.x < boundBox.x1) {
      boundBox.x1 = this.x;
    }
    if (this.x > boundBox.x2) {
      boundBox.x2 = this.x;
    }
    if (boundBox.y1 == Float.MIN_VALUE || this.y < boundBox.y1) {
      boundBox.y1 = this.y;
    }
    if (this.y > boundBox.y2) {
      boundBox.y2 = this.y;
    }
    for (int i =0; i < childCount; i++) {
      children.get(i).updateBounds(boundBox);
    }
  }

  void addChild(TreeOld child) {
    child.setParent(this);
    if (childIds.contains(child.id)) {
      children.set(childIds.indexOf(child.id), child);
    } else {
      childCount++;
      children.add(child);
      childIds.add(child.id);
    }
    isDrawn = false;
  }

  TreeOld getChild(String name) {
    TreeOld child = null;
    if (childIds.contains(name)) {
      child = children.get(childIds.indexOf(name));
    } else {
      for (int i = 0; i < children.size(); i++) {
        child = children.get(i).getChild(name);
        if (child != null) {
          break;
        }
      }
    }
    return child;
  }

  void setParent(TreeOld parent) {
    this.parent = parent;
  }

  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  TreeOld left() {
    TreeOld left = thread;
    if (left == null) {
      if (childCount > 0) {
        left = children.get(0);
      }
    }
    return left;
  }

  TreeOld right() {
    TreeOld right = thread;
    if (right == null) {
      if (childCount > 0) {
        right = children.get(childCount - 1);
      }
    }
    return right;
  }

  TreeOld getLeftBrother() {
    TreeOld lbro = null;
    if (parent != null) {
      for (int i = 0; i < parent.children.size(); i++) {
        TreeOld pchild = parent.children.get(i);
        if (pchild.id == this.id) {
          return lbro;
        } else {
          lbro = pchild;
        }
      }
    }
    return lbro;
  }

  TreeOld getLeftmostSibling() {
    if (leftmostSibling == null) {
      if (parent != null && parent.children.size() > 0) {
        leftmostSibling = parent.children.get(0);
      }
    }
    return leftmostSibling;
  }
}