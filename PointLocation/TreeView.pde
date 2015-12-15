
class TreeView extends SquareView {

  // can add tree nodes to this view, used to visualize time complexity

  TreeOld root = null;
  TreeDrawHelper treeDrawHelper;

  HashMap<String, TreeOld> nodes;

  public TreeView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
    nodes = new HashMap<String, TreeOld>();
    treeDrawHelper = new TreeDrawHelper();
  }

  void render() {
    super.render();
    if (root != null ) {
      // layout relative positions
      //treeDrawHelper.buchheim(root);
      // adjust on screen positions
      //treeDrawHelper.layoutIcons();


      // get max/min bounds of graph layout
      //BoundingBox boundBox = new BoundingBox();
      //root.updateBounds(boundBox);
      // calculate scaling ratio based on bounds
      //boundBox.setScreenBounds(this.x1 + 10 + root.RAD, this.y1 + 10 + root.RAD, this.x2 - 10 - root.RAD, this.y2 - 10 - root.RAD);
      //root.render(boundBox);
    }
  }

  void addToPotentialTrees(String id) {
    if (!nodes.containsKey(id)) {
      nodes.put(id, new TreeOld(id));
    }
  }

  void addChild(String parentId, String childId) {
    println("adding child " + childId + " to parentId " + parentId);
    if (parentId == null) {
      if (root == null) {
        root = new TreeOld(childId);
        nodes.put(childId, root);
      }
      println("root size " + root.children.size());
    } else {
      if (nodes.containsKey(childId)) {
        addToPotentialTrees(childId);
      }
      TreeOld childTree = nodes.get(childId);
      //nodes.get(parentId).addChild(childTree);
      root.addChild(childTree);
      nodes.put(childId, childTree);
    }
  }
}

class TreeDrawHelper {

  void layoutIcons(Tree tree, BoundingBox bounds) {
    tree.setIconPosition(bounds);
  }

  // based on: http://billmill.org/pymag-trees/, license is open
  void buchheim(Tree tree) {
    Tree dt = firstWalk(tree);
    secondWalk(dt);
  }

  Tree firstWalk(Tree v) {
    return firstWalk(v, 1.0);
  }

  Tree firstWalk(Tree v, float distance) {
    if (v.children.size() == 0) {
      if (v.getLeftmostSibling() != null) {
        if (v.getLeftBrother() != null) {
          v.setX(v.getLeftBrother().x + distance);
        } else {
          v.setX(distance);
        }
      } else {
        v.setX(0);
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
        println("setting x to " + (w.x + distance));
        v.setX(w.x + distance);
        v.mod = v.x - midPoint;
      } else {
        v.setX(midPoint);
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
    wright.setX(wright.x + shift);
    wright.mod += shift;
  }

  void executeShifts(Tree v) {
    float shift = 0;
    float change = 0;
    for (int i = 0; i < v.childCount - 1; i++) {
      Tree w = v.children.get(i);
      w.setX(w.x + shift);
      w.mod += shift;
      change += w.change;
      shift += w.shift + change;
    }
  }

  Tree ancestor(Tree vil, Tree v, Tree defaultAncestor) {
    if (v.parent != null && v.parent.contains(vil.ancestor)) {
      return vil.ancestor;
    } else {
      return defaultAncestor;
    }
  }

  void secondWalk(Tree v) {
    secondWalk(v, 0, 0);
  }

  void secondWalk(Tree v, float m, float depth) {
    v.setX(v.x + m);
    v.setY(depth);
    for (int i = 0; i < v.childCount; i++) {
      secondWalk(v.children.get(i), m + v.mod, depth + 1);
    }
  }
}