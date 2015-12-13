
class GraphView extends View {

  Tree tree;

  public GraphView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
    this.tree = new Tree("root");
  }

  void render() {
    stroke(this.cstroke);
    fill(this.cbackground);
    rect(x1, y1, w, h);
    Tree btree = buchheim(tree);
    btree.render();
  }

  Tree buchheim(Tree tree) {
    Tree dt = firstWalk(tree);
    secondWalk(dt);
    return dt;
  }

  Tree firstWalk(Tree v) {
    return firstWalk(v, 1.0);
  }

  Tree firstWalk(Tree v, float distance) {
    if (v.children.size() == 0) {
      if (v.getLeftBrother() != null) {
        v.x = v.getLeftBrother().x + distance;
      } else {
        v.x = 0;
      }
    } else {
      Tree defaultAncestor = v.children.get(0);
      Tree w = null;
      for (int i = 0; i < v.childCount; i++) {
        w = v.children.get(i);
        firstWalk(w);
        defaultAncestor = apportion(w, defaultAncestor, distance);
      }
      executeShifts(v);

      Tree ell = v.children.get(0);
      Tree arr = v.children.get(v.childCount - 1);
      float midPoint = (ell.x + arr.x) / 2;
      w = v.getLeftBrother();
      if (w != null) {
        v.x = w.x + distance;
        v.mod = v.x - midPoint;
      } else {
        v.x = midPoint;
      }
    }
    return v;
  }

  Tree apportion(Tree v, Tree defaultAncestor, float distance) {
    Tree w = v.getLeftBrother();
    if (w != null) {
      Tree vir = v;
      Tree vor = v;
      Tree vil = w;
      Tree vol = v.getLeftmostSibling();
      float sir = v.mod;
      float sor = v.mod;
      float sil = vil.mod;
      float sol = vol.mod;
      while (vil.right() != null && vir.left() != null) {
        vil = vil.right();
        vir = vir.left();
        vol = vol.left();
        vor = vor.right();
        vor.ancestor = v;
        float shift = (vil.x + sil) - (vir.x + sir) + distance;
        if (shift > 0) {
          Tree a = ancestor(vil, v, defaultAncestor);
          moveSubtree(a, v, shift);
          sir = sir + shift;
          sor = sor + shift;
        }
        sil += vil.mod;
        sir += vir.mod;
        sol += vol.mod;
        sor += vor.mod;
      }
      if (vil.right() != null && vor.right() == null) {
        vor.thread = vil.right();
        vor.mod += sil - sor;
      } else {
        if (vir.left() != null && vol.left() == null) {
          vol.thread = vir.left();
          vol.mod += sir - sol;
        }
        defaultAncestor = v;
      }
    }
    return defaultAncestor;
  }

  void moveSubtree(Tree wleft, Tree wright, float shift) {
    int numSubtrees = wright.number - wleft.number;
    wright.change -= shift / numSubtrees;
    wright.shift += shift;
    wleft.change += shift / numSubtrees;
    wright.x += shift;
    wright.mod += shift;
  }

  void executeShifts(Tree v) {
    float shift = 0;
    float change = 0;
    for (int i = 0; i < v.childCount - 1; i++) {
      Tree w = v.children.get(i);
      w.x += shift;
      w.mod += shift;
      change += w.change;
      shift += w.shift + change;
    }
  }

  Tree ancestor(Tree vil, Tree v, Tree defaultAncestor) {
    if (v.parent != null && v.parent.childIds.contains(vil.ancestor.id)) {
      return vil.ancestor;
    } else {
      return defaultAncestor;
    }
  }

  void secondWalk(Tree v) {
    secondWalk(v, 0, 0);
  }

  void secondWalk(Tree v, float m, float depth) {
    v.x += m;
    v.y = depth;
    for (int i = 0; i < v.childCount; i++) {
      secondWalk(v.children.get(i), m + v.mod, depth + 1);
    }
  }

  void handleMouseClickEvent() {
    if (pointInView(mouseX, mouseY)) {
    }
  }
}

class Tree extends Drawable {
  String id;
  Tree parent;
  ArrayList<Tree> children;
  ArrayList<String> childIds;
  int childCount = 0;
  float x, y;

  Tree leftmostSibling, thread, ancestor;
  float mod, change, shift;
  int number;

  public Tree(String id, Tree parent, float depth, int number) {
    this.id = id;
    this.parent = null;
    this.children = new ArrayList<Tree>();
    this.childIds = new ArrayList<String>();

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

  public Tree(String id) {
    this(id, null, 0, 1);
  }

  void render() {
    for (int i =0; i < childCount; i++) {
      children.get(i).render();
    }
  }

  void addChild(Tree child) {
    child.setParent(this);
    children.add(child);
    childIds.add(child.id);
    childCount++;
  }

  Tree getChild(String name) {
    Tree child = null;
    if (childIds.contains(name)) {
      child = children.get(childIds.indexOf(name));
    } else {
      for (int i = 0; i < children.size(); i++) {
        children.get(i).getChild(name);
      }
    }
    return child;
  }

  void setParent(Tree parent) {
    this.parent = parent;
  }

  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  Tree left() {
    Tree left = thread;
    if (left == null) {
      if (childCount > 0) {
        left = children.get(0);
      }
    }
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
      for (int i = 0; i < parent.children.size(); i++) {
        Tree pchild = parent.children.get(i);
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