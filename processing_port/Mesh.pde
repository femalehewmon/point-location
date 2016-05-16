class Mesh {

	ArrayList<Vertex> vertices;
	ArrayList<Edge> edges;
	ArrayList<Face> faces;

	public Mesh() {
		this.vertices = new ArrayList<Vertex>();
		this.edges = new ArrayList<Edge>();
		this.faces = new ArrayList<Face>();
	}

	void addTriangle(int[][] verts) {
		Vertex v1 = new Vertex(vertex[0][0], vertex[0][1]);
		Vertex v2 = new Vertex(vertex[1][0], vertex[1][1]);
		Vertex v3 = new Vertex(vertex[2][0], vertex[2][1]);
		Edge e12 = new Edge( v1, v2 );
		Edge e23 = new Edge( v2, v3 );
		Edge e31 = new Edge (v3, v1 );
	}

	ArrayList<Vertex> independentLowDegreeVertices() {
		ArrayList<Vertex> ildv = new ArrayList<Vertex>();
		for ( int i = 0; i < vertices.size; i++ ) {
			if ( edgesOfVertex( vertices.get(i) ).size() < 7 ) {
				ildv.add( vertices.get(i) ); // add ildv to list
			}
		}
		return ildv;
	}

	ArrayList<Edge> edgesSurroundingVertex( Vertex v ) {
		ArrayList<Edge> esv = new ArrayList<Edge>();

		ArrayList<Face> fov = facesOfVertex( v );
		Face curr_face;
		Edge curr_edge;
		ArrayList<Edge> curr_eof;
		for ( int i = 0; i < fov.size(); i++ ) {
			curr_face = fov.get(i);
			curr_eof = edgesOfFace( curr_face );
			for ( int j = 0; j < curr_eof.size(); j++ ) {
				curr_edge = curr_eof.get(j);
				if ( curr_edge.start != v && curr_edge.end != v ) {
					esv.add( edge );
				}
			}
		}
		return esv;
	}

	ArrayList<Face> facesOfVertex( Vertex v ) {
		ArrayList<Face> fov = new ArrayList<Face>();

		// todo: determine if there is an optimization
		// can I just add all left faces directly?
		ArrayList<Edge> eov = edgesOfVertex( v );
		for (int i = 0; i < eov.size(); i++ ) {
			if ( !fov.contains(eov.get(i).start) ) {
				fov.add(eov.get(i).start);
			}
			if ( !fov.contains(eov.get(i).end) ) {
				fov.add(eov.get(i).end);
			}
		}

		return fov;
	}

	ArrayList<Edge> edgesOfVertex( Vertex v ) {
		ArrayList<Edge> eov = new ArrayList<Edge>();

		Edge e = v.e;
		do {
			eov.add(e);
			if ( e.tail == v ) {
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

}	

class Edge {
	public Edge lprev, lnext, rprev, rnext;
	public Vertex head, tail;
	public Face left, right;

	public Edge( Vertex head, Vertex tail ) {
		this.head = head;
		this.tail = tail;
	}

	void setEdges( Edge lprev, Edge lnext, Edge rprev, Edge rnext ) {
		this.lprev = lprev;
		this.lnext = lnext;
		this.rprev = rprev;
		this.rnext = rnext;
	}

	void setFaces( Face left, Face right ) {
		this.left = left;
		this.right = right;
	}

    public int hashCode() {
        int hash = 17;
        hash = ((hash + head.x) << 5) - (hash + head.x);
        hash = ((hash + head.y) << 5) - (hash + head.y);
        hash = ((hash + tail.x) << 5) - (hash + tail.x);
        hash = ((hash + tail.y) << 5) - (hash + tail.y);
        return (int)hash;
    }

    public boolean equals(Object obj) {    
        Edge other = (Edge) obj;    
        return ((head == obj.head && tail == obj.tail) ||
					(tail == obj.head && head == obj.tail));    
    }
}

class Face {
	Edge e;				// any adjacent edge

	public Face( Edge e ) {
		this.e = e;
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
