class KpTriangulationView extends View {

	Polygon outerTri;
	Polygon polygon;

	ArrayList<Polygon> polys;
	ArrayList<Vertex> vertices;

	// data structure to hold the triangulation of a poly or list of polys
	public KpTriangulationView(float x1, float y1, float x2, float y2) {
		super(x1, y1, x2, y2);
		this.polys = new ArrayList<Polygon>();
		this.vertices = new ArrayList<Vertex>();
	}

	public void loadGraph(KpDataStructure kpGraph) {
		polys.clear();
		this.outerTri = kpGraph.outerTri;
		this.polygon = kpGraph.polygon;
		for (int i = 0; i < kpGraph.triangles.size(); i++) {
			println("tri parent id " + kpGraph.triangles.get(i).parent);
			this.polys.add(kpGraph.triangles.get(i).copy());
		}
		for (int i = 0; i < kpGraph.vertices.size(); i++) {
			this.vertices.add(kpGraph.vertices.get(i).copy());
		}
	}


	public void render(KpAnimationScene scene) {
		int i;
		if (scene.stage == scene.STAGE_INITIAL) {
			switch(scene.subStage) {
				case scene.DRAW_POLY:
					drawPolygon();
					break;
				case scene.TRIANGULATE_POLY:
					drawPolygonTriangulation();
					break;
				case scene.DRAW_OUTER_TRI:
					drawOuterTri(true);
					drawPolygonTriangulation();
					break;
				case scene.TRIANGULATE_OUTER_TRI:
					drawOuterTri(true);
					drawPolygonTriangulation();
					drawOuterTriangulation();
					break;
			}
		} else{
			// draw triangles
			drawOuterTri();
			if (scene.markILDV) {
				println("mark ildv " + scene.currDepth);
				for (i = 0; i < polys.size(); i++) {
					if(polys.get(i).startLevel <= scene.currDepth &&
							polys.get(i).endLevel > scene.currDepth) {
						polys.get(i).render();
					}
				}
				for (i = 0; i < vertices.size(); i++) {
				   if(vertices.get(i).endLevel == scene.currDepth + 1) {
						vertices.get(i).selected = true;
						vertices.get(i).render();
				   }
				}
			} else if (scene.showHoles) {
				println("show holes " + scene.currDepth);
				for (i = 0; i < polys.size(); i++) {
					if(polys.get(i).startLevel < scene.currDepth &&
							polys.get(i).endLevel > scene.currDepth + 1) {
						polys.get(i).render();
					}
				}
				for (i = 0; i < vertices.size(); i++) {
				   if(vertices.get(i).endLevel > scene.currDepth + 1) {
						vertices.get(i).selected = false;
						vertices.get(i).render();
				   }
				}
			} else {
				println("draw normally " + scene.currDepth);
				for (i = 0; i < polys.size(); i++) {
					if(polys.get(i).startLevel <= scene.currDepth &&
							polys.get(i).endLevel > scene.currDepth ) {
						polys.get(i).render();
					}
				}
				for (i = 0; i < vertices.size(); i++) {
				   if(vertices.get(i).startLevel < scene.currDepth && 
						   vertices.get(i).endLevel > scene.currDepth) {
						vertices.get(i).selected = false;
						vertices.get(i).render();
				   }
				}
			}
			/*
			for (i = 0; i < polys.size(); i++) {
				if(scene.showHoles) {
					if(polys.get(i).startLevel < scene.currDepth &&
							polys.get(i).endLevel > scene.currDepth) {
						polys.get(i).render();
					}
				} else {
					if(polys.get(i).startLevel <= scene.currDepth &&
							polys.get(i).endLevel >= scene.currDepth) {
						polys.get(i).render();
					}
				}
			}
			// draw vertices
			for (i = 0; i < vertices.size(); i++) {
				if (scene.markILDV){
				   if(vertices.get(i).endLevel == scene.currDepth) {
						vertices.get(i).selected = true;
						vertices.get(i).render();
				   }
				} else if (vertices.get(i).endLevel > scene.currDepth) {
					vertices.get(i).selected = false;
					vertices.get(i).render();
				}
			}
			*/
		}
	}

	private void drawPolygon() {
		polygon.render();
	}
	private void drawOuterTri() {
		drawOuterTri(false);
	}
	private void drawOuterTri(boolean selected) {
		outerTri.selected = selected;
		outerTri.render();
	}
	private void drawOuterTriangulation() {
		for (i = 0; i < polys.size(); i++) {
			if(polys.get(i).parent.equals(outerTri.id)) {
				polys.get(i).render();
				for(j = 0; j < polys.get(i).vertices.size(); j++){
					polys.get(i).vertices.get(j).selected = false;
					polys.get(i).vertices.get(j).render();
				}
			}
		}
	}
	private void drawPolygonTriangulation() {
		for (i = 0; i < polys.size(); i++) {
			if(polys.get(i).parent.equals(polygon.id)) {
				polys.get(i).render();
				for(j = 0; j < polys.get(i).vertices.size(); j++){
					polys.get(i).vertices.get(j).render();
				}
			}
		}
	}

	public Polygon createOuterTri() {
		double minSide = min(this.w, this.h);
		double left = (this.w - minSide) / 2;
		double top = (this.h - minSide) / 2;

		Polygon outerTri = createPoly();
		outerTri.addVertex(left, this.h - top);
		outerTri.addVertex(left + minSide / 2, top);
		outerTri.addVertex(this.w - left, this.h - top);
		outerTri.cFill = color(150, 150, 150);
		outerTri.cHighlight = color(255, 255, 255);
		this.outerTri = outerTri;
		return outerTri;
	}

	public Polygon centerPolyInOuterTri(Polygon poly) {
		// center polygon in outer triangle
		Vertex triCenter = outerTri.getCenter();
		poly.move(triCenter);
		return poly;
	}

	/*
	public void mouseUpdate() {
		color c = pickbuffer.get(mouseX, mouseY);
		int i, j;
		for (i = 0; i < numLayers; i++) {
			for (j = 0; j < shapes.get(i).size(); j++) {
				if (color(shapes.get(i).get(j).id) == c) {
					Message msg = new Message();
					msg.k = MSG_TRIANGLE;
					msg.v = shapes.get(i).get(j).id;
					messages.add(msg);
				}
			}
		}
		if (keyPressed) {
			image(pickbuffer, 0, 0);
		}
	}
	*/


}
