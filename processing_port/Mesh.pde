class Mesh {

	ArrayList<Vertex> vertices;
	ArrayList<Edge> edges;
	ArrayList<Face> faces;

	public Mesh(ArrayList<Polygon> tris ) {
		this.vertices = new ArrayList<Vertex>();
		this.edges = new ArrayList<Edge>();
		this.faces = new ArrayList<Face>();
		addTrianglesToMesh(tris);
	}

	void addTrianglesToMesh(ArrayList<Polygon> tris ) {
		Polygon curr_tri;
		for ( int i = 0; i < tris.size(); i++ ) {
			curr_tri = tris.get(i);
			// Create and add vertices to mesh
			Vertex v1, v2, v3;
			v1 = new Vertex(curr_tri.points.get(0).x, curr_tri.points.get(0).y);
			v2 = new Vertex(curr_tri.points.get(1).x, curr_tri.points.get(1).y);
			v3 = new Vertex(curr_tri.points.get(2).x, curr_tri.points.get(2).y);
			int idx_v1 = addVertexToMesh(v1);
			int idx_v2 = addVertexToMesh(v2);
			int idx_v3 = addVertexToMesh(v3);

			// Create and add edges to mesh
			Edge e1, e2, e3;
			e1 = new Edge( idx_v1, idx_v2 );
			e2 = new Edge( idx_v2, idx_v3 );
			e3 = new Edge( idx_v3, idx_v1 );
			int idx_e1 = addEdgeToMesh(e1);
			int idx_e2 = addEdgeToMesh(e2);
			int idx_e3 = addEdgeToMesh(e3);

			// Create new face and add to mesh structure
			// assumes this is definitely a new face, so code carefully
			Face f;
			face = new Face( curr_tri.id, idx_e1 );
			int idx_f = addFaceToMesh(face);

			// Fill in edge details
			if ( this.edges.get(idx_e1).start == e1.start ) {
				console.log("same orientation");
				// same orientation, edge had not yet been added (hopefully)
				this.edges.get(idx_e1).right = idx_f
				this.edges.get(idx_e1).rprev = idx_e3;
				this.edges.get(idx_e1).rnext = idx_e2;

				this.edges.get(idx_e2).right = idx_f;
				this.edges.get(idx_e2).rprev = idx_e1;
				this.edges.get(idx_e2).rnext = idx_e3;

				this.edges.get(idx_e3).right = idx_f;
				this.edges.get(idx_e3).rprev = idx_e2;
				this.edges.get(idx_e3).rnext = idx_e1;
			} else if ( this.edges.get(idx_e1).start == e1.end ) {
				console.log("different orientation");
				// opposite orientation, edge had been added
				this.edges.get(idx_e1).left = idx_f;
				this.edges.get(idx_e1).lprev = idx_e3;
				this.edges.get(idx_e1).lnext = idx_e2;

				this.edges.get(idx_e2).left = idx_f;
				this.edges.get(idx_e2).lprev = idx_e1;
				this.edges.get(idx_e2).lnext = idx_e3;

				this.edges.get(idx_e3).left = idx_f;
				this.edges.get(idx_e3).lprev = idx_e2;
				this.edges.get(idx_e3).lnext = idx_e1;
			} else {
				console.log("WARNING: edge does not match.. weird!");
			}
			console.log(this.edges.get(idx_e1));
			console.log(this.edges.get(idx_e2));
			console.log(this.edges.get(idx_e3));
		}
	}

	int addFaceToMesh( Face f ) {
		if ( !this.faces.contains(f) ) {
			this.faces.add(f);
		}
		return this.faces.indexOf( f );
	}

	int addVertexToMesh( Vertex v ) {
		if ( !this.vertices.contains(v) ) {
			this.vertices.add(v);
		}
		return this.vertices.indexOf( v );
	}


	int addEdgeToMesh( Edge e ) {
		if ( !this.edges.contains(e) ) {
			this.edges.add(e);
		}
		return this.edges.indexOf( e );
	}

	ArrayList<Edge> edgesOfVertex( Vertex v ) {
		ArrayList<Edge> eov = new ArrayList<Edge>();

		Edge e = v.e;
		do {
			eov.add(e);
			if ( e.end == v ) {
				e = e.lprev;
			} else {
				e = e.rprev;
			}
		} while ( e != v.e );

		return eov;
	}

	ArrayList<Edge> edgesOfFace( Face f ) {
		ArrayList<Edge> eof = new ArrayList<Edge>();

		Edge e = f.e;
		do {
			eof.add(e);
			if ( e.left == f ) {
				e = e.lnext;
			} else {
				e = e.rnext;
			}
		} while ( e != f.e );

		return eof;
	}

	ArrayList<Face> facesOfVertex( Vertex v ) {
		ArrayList<Face> fov = new ArrayList<Face>();

		// todo: determine if there is an optimization
		// can I just add all left faces directly?
		ArrayList<Edge> eov = edgesOfVertex( v );
		Edge curr_left;
		Edge curr_right;
		for (int i = 0; i < eov.size(); i++ ) {
			curr_left = eov.get(i).left;
			curr_right = eov.get(i).right;
			if ( curr_left != null && !fov.contains(curr_left) ) {
				fov.add( left );
			}
			if ( curr_right != null && !fov.contains(curr_right) ) {
				fov.add( right );
			}
		}

		return fov;
	}

	ArrayList<Face> facesOfEdge( Edge e ) {
		ArrayList<Face> foe = new ArrayList<Face>();

		if ( e.left != null ) {
			foe.add( e.left );
		}
		if ( e.right != null ) {
			foe.add( e.right );
		}

		return foe;
	}
}	

class Edge {
	Edge lprev, lnext;			// left traverse
    Edge rprev, rnext;			// right traverse
	Vertex start, end;
	Face left, right;

	public Edge( Vertex start, Vertex end ) {
		this.start = start;
		this.end = end;
		this.lprev = null;
		this.lnext = null;
		this.rprev = null;
		this.rnext = null;
		this.left = null;
		this.right = null;
	}

    public int hashCode() {
        int hash = 17;
        hash = ((hash + start.x) << 5) - (hash + start.x);
        hash = ((hash + start.y) << 5) - (hash + start.y);
        hash = ((hash + end.x) << 5) - (hash + end.x);
        hash = ((hash + end.y) << 5) - (hash + end.y);
        return (int)hash;
    }

    public boolean equals(Object obj) {    
        Edge other = (Edge) obj;    
        return ((start == obj.start && end == obj.end) ||
					(end == obj.start && start == obj.end));    
    }
}

class Face {
	int id;
	Edge e;				// any adjacent edge

	public Face( int id, Edge e ) {
		this.id = id;
		this.e = e;
	}

	public boolean equals(Object obj) {
        Face other = (Face) obj;
        return (id == obj.id);
	}
}

class Vertex {
	float x, y;
	Edge e;				// any incident edge

	public Vertex( float x, float y) {
		this.x = x;
		this.y = y;
	}
	
	void setEdge( Edge e ) {
		this.e = e;
	}

    public int hashCode() {
        int hash = 17;
        hash = ((hash + x) << 5) - (hash + x);
        hash = ((hash + y) << 5) - (hash + y);
        return (int)hash;
    }

    public boolean equals(Object obj) {
        Vertex other = (Vertex) obj;
        return (x == obj.x && y == obj.y);
    }
}
