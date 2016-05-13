
class KpDataStructure {

	Polygon polygon;
	Polygon outerTri;

	ArrayList<Polygon> triangles;
	ArrayList<Vertex> vertices;

	HashMap<Vertex, ArrayList<Polygon>> tris_by_vertex; //vertex with polys
	int level;

	int LOW_DEGREE = 7;

	// data structure to hold the triangulation of a poly or list of polys
	public KpDataStructure() {
		this.tris_by_vertex = new HashMap<Vertex, ArrayList<Polygon>>();
		this.vertices = new ArrayList<Vertex>();
		this.triangles = new ArrayList<Polygon>();
	}

	public void buildGraph(Polygon poly, Polygon outerTri) {
		this.polygon = poly;
		this.outerTri = outerTri;

		int i, j;
		level = 0;

		// triangulate initial polygon, mark with custom start level
		ArrayList<Polygon> tris;
	    tris = polygon.triangulate();
		for( j = 0; j < tris.size(); j++ ) {
			addTriangle(-2, tris.get(j));
		}
		// triangulate outer triangle, mark with custom start level
		outerTri.addHole(polygon);
		tris = outerTri.triangulate();
		for( j = 0; j < tris.size(); j++ ) {
			addTriangle(-1, tris.get(j));
		}

		Polygon hole;
		ArrayList<Polygon> holeTris;
		// iteratively find set of independent low degree vertices (IDV)
		// once found, remove connected triangles and re-triangulate hole
		while ( tris_by_vertex.size() > outerTri.vertices.size() ) {
			level++;
			println("increased level");
			ArrayList<Vertex> ildv = getIndependentLowDegreeVertices();
			for ( i = 0; i < ildv.size(); i++ ) {
				// mark endDepth of ildv and connected triangles
				vertices.get(vertices.indexOf(ildv.get(i))).endLevel = level;
				for( j = 0; j < tris_by_vertex.get(ildv.get(i)).size(); j++ ) {
					Polygon tri = tris_by_vertex.get(ildv.get(i)).get(j);
					triangles.get(triangles.indexOf(tri)).endLevel = level;
				}
				// get outer hull of tris connected to ildv vertex
				hole = getTriHull(ildv.get(i));
				// re-triangulate hole left from removed vertex
				holeTris = hole.triangulate();
				for( int j = 0; j < holeTris.size(); j++ ) {
					addTriangle(level, holeTris.get(j));
				}
				// remove from vertex list
				tris_by_vertex.remove(ildv.get(i));
				console.log("removed ildv " + ildv.get(i).x + ", " + ildv.get(i).y);
			}
		}
		this.levels = level + 1;
	}

	private Polygon getTriHull(Vertex v) {
		int i, j, k;
		Polygon chull = createPoly();
		console.log("FINDING HULL FOR " + v.x + ", " + v.y);

		// get list of ordered outer vertex points
		ArrayList<Polygon> polys = new ArrayList<Polygon>(
				tris_by_vertex.get(v));
		for(i = 0; i < polys.size(); i++){
			console.log("  poly is " + polys.get(i).id);
			for(j = 0; j < polys.get(i).vertices.size(); j++){
				console.log("    vertex is " + polys.get(i).vertices.get(j).x + ", " + polys.get(i).vertices.get(j).y);
			}
		}
		if ( polys.size() > 0 ){
			Polygon currTri = polys.get(0);
			// get starting outer vertex from first triangle
			Vertex outer;
			for (i = 0; i < currTri.vertices.size(); i++){
				if (!currTri.vertices.get(i).equals(v)){
					outer = currTri.vertices.get(i);
				}
			}
			// add starting point to hull list
			// remove starting triangle from potential list
			chull.addVertex(outer);
			polys.remove(currTri);
			for ( i = 0; i < polys.size(); i++ ) {
				currTri = null;
				// find adjacent polygon with shared outer vertex 
				for( j = 0; j < polys.size(); j++ ){
					if( polys.get(j).containsVertex(outer) ) {
					   	currTri = polys.get(j);
					}
				}

				// ensure that the hull is connected
				if (currTri == null) {
					console.log("ADJ TRI NOT FOUND, SOMETHINGS WRONG");
					return null;
				}

				// find next outer vertex from adjacent polygon
				for ( k = 0; k < currTri.vertices.size(); k++ ) {
					if (!currTri.vertices.get(k).equals(outer) &&
							!currTri.vertices.get(k).equals(v)) {
						outer = currTri.vertices.get(k);
						chull.addVertex(outer);
						break;
					}
				}

				// remove adjacent triangle so that it is not re-found
				polys.remove(currTri);
			}
		}
		return chull;
	}


	private ArrayList<Vertex> getIndependentLowDegreeVertices() {
		int i, j;
		ArrayList<Vertex> ildvs = new ArrayList<Vertex>();

		// create list of potential low degree vertices
		ArrayList<Vertex> available = new ArrayList<Vertex>();
		Iterator it = tris_by_vertex.keySet().iterator();
		while(it.hasNext()) {
			Vertex v = it.next();
			// select vertex if it has a low degree and is not a vertex
			// of the outer triangle
			if (tris_by_vertex.get(v).size() <= LOW_DEGREE &&
					!outerTri.vertices.contains(v)) {
				available.add(v);
			}
		}

		// find set of non-neighbored vertices
		Vertex ildv;
		while (available.size() > 0) {
			ildv = available.get((int)random(0, available.size())); 
			// remove chosen vertex from available list 
			available.remove(ildv);
			// remove neighbors of chosen vertex from available list
			for (i = available.size(); i >= 0; i--) {
				for (j = 0; j < tris_by_vertex.get(ildv).size(); j++) {
					// if ildv triangle contains another vertex in
					// the available list, remove it
					if (tris_by_vertex.get(ildv).get(j).containsVertex(
								available.get(i))) {
						available.remove(i);
					}
				}
			}
			ildvs.add(ildv);
		}

		return ildvs;
	}


	private void addTriangle(int lvl, Polygon tri) {
		tri.startLevel = lvl;
		tri.endLevel = Number.MAX_VALUE;
		triangles.add(tri);
		Vertex v;
		for( int i = 0; i < tri.vertices.size(); i++ ){
			v = tri.vertices.get(i);
			if (!vertices.contains(v)) {
				v.startLevel = lvl;
				v.endLevel = Number.MAX_VALUE;
				vertices.add(v);
				console.log("added vertex " + v.x + ", " + v.y);
				tris_by_vertex.put(v, new ArrayList<Polygon>());
			} else {
				if(!tris_by_vertex.keySet().contains(v)){
				console.log("v contains but does tbyv? " + tris_by_vertex.keySet().contains(v) + " v is " + v.x + ", " + v.y + " size " + tris_by_vertex.size());
				Iterator it = tris_by_vertex.keySet().iterator();
				while(it.hasNext()) {
					Vertex vv = it.next();
					console.log("    has " + vv.x + ", " + vv.y);
				}
				}
			}
			println("aa");
			tris_by_vertex.get(v).add(tri);
		}
	}

}
