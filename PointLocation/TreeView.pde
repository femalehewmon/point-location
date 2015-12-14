
class TreeView extends SquareView {

  // can add tree nodes to this view, used to visualize time complexity

  Tree root = null;
  TreeDrawHelper treeDrawHelper;

  public TreeView(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
    treeDrawHelper = new TreeDrawHelper();
    root = new Tree("root");
  }

  void render() {
    super.render();
    if (root != null && root.childCount > 1) {
      treeDrawHelper.buchheim(root);

      // get max/min bounds of graph layout
      BoundingBox boundBox = new BoundingBox();
      root.updateBounds(boundBox);
      println("Bounds " + boundBox.x1 + " " + boundBox.y1 + " " + boundBox.x2 + " " + boundBox.y2);
      // calculate scaling ratio based on bounds
      boundBox.setScreenBounds(this.x1 + 10 + root.RAD, this.y1 + 10 + root.RAD, this.x2 - 10 - root.RAD, this.y2 - 10 - root.RAD);

      root.render(boundBox);
    }
  }
}

class TreeDrawHelper {
  // based on: http://billmill.org/pymag-trees/, license is open

  void buchheim(Tree tree) {
    if (!tree.isDrawn) {
      Tree dt = firstWalk(tree);
      secondWalk(dt);
      tree.isDrawn = true;
    }
  }

  Tree firstWalk(Tree v) {
    return firstWalk(v, 1.0);
  }

  Tree firstWalk(Tree v, float distance) {
    if (v.children.size() == 0) {
      if (v.getLeftmostSibling() != null) {
        if (v.getLeftBrother() != null) {
          v.x = v.getLeftBrother().x + distance;
        } else {
          v.x = distance;
        }
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
}