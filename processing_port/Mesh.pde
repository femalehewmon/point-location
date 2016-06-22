class Mesh {

	ArrayList<Vertex> vertices;
	ArrayList<Edge> edges;
	ArrayList<Face> faces;

	public Mesh( ) {
		this.vertices = new ArrayList<Vertex>();
		this.edges = new ArrayList<Edge>();
		this.faces = new ArrayList<Face>();
	}

	public void addTrianglesToMesh( ArrayList<Polygon> tris ) {
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
			e1 = new Edge( v1, v2 );
			e2 = new Edge( v2, v3 );
			e3 = new Edge( v3, v1 );
			int idx_e1 = addEdgeToMesh(e1);
			int idx_e2 = addEdgeToMesh(e2);
			int idx_e3 = addEdgeToMesh(e3);

			// Set vertex edge indices
			this.vertices.get(idx_v1).setEdge(e1);
			this.vertices.get(idx_v2).setEdge(e1);
			this.vertices.get(idx_v3).setEdge(e1);

			// Create new face and add to mesh structure
			// assumes this is definitely a new face, so code carefully
			Face f;
			face = new Face( curr_tri.id, e1 );
			int idx_f = addFaceToMesh(face);

			// Fill in edge details
			if ( this.edges.get(idx_e1).start == e1.start ) {
				console.log("same orientation");
				// same orientation, edge had not yet been added (hopefully)
				this.edges.get(idx_e1).right = f
				this.edges.get(idx_e1).rprev = e3;
				this.edges.get(idx_e1).rnext = e2;

				this.edges.get(idx_e2).right = f;
				this.edges.get(idx_e2).rprev = e1;
				this.edges.get(idx_e2).rnext = e3;

				this.edges.get(idx_e3).right = f;
				this.edges.get(idx_e3).rprev = e2;
				this.edges.get(idx_e3).rnext = e1;
			} else if ( this.edges.get(idx_e1).start == e1.end ) {
				console.log("different orientation");
				// opposite orientation, edge had been added
				this.edges.get(idx_e1).left = f;
				this.edges.get(idx_e1).lprev = e3;
				this.edges.get(idx_e1).lnext = e2;

				this.edges.get(idx_e2).left = f;
				this.edges.get(idx_e2).lprev = e1;
				this.edges.get(idx_e2).lnext = e3;

				this.edges.get(idx_e3).left = f;
				this.edges.get(idx_e3).lprev = e2;
				this.edges.get(idx_e3).lnext = e1;
			} else {
				console.log("WARNING: edge does not match.. weird!");
			}
			console.log(this.edges.get(idx_e1));
			console.log(this.edges.get(idx_e2));
			console.log(this.edges.get(idx_e3));
		}
	}

	void removeFacesFromMesh( ArrayList<Polygon> tris ) {
		Face curr_face;
		for ( int i = 0; i < tris.size(); i++ ) {
			if ( this.faces.contains( tris.get(i)) ) {
				curr_face = this.faces.get( 
						this.faces.indexOf(tris.get(i)) );
				removeFaceFromMesh( curr_face );
			} else {
				console.log(
						"Mesh does not contain face.. doing something wrong?");
			}
		}
	}

	boolean removeFaceFromMesh( Face f ) {
		if ( this.faces.contains(f) ) {
			Edge curr_edge;
			ArrayList<Edge> eof = edgesOfFace( curr_face );
			for ( int i = 0; i < eof.size(); i++ ) {
				curr_edge = eof.get(i);
				// remove face reference from edges
				curr_edge.removeFace( curr_edge );
				if ( curr_edge.left == null && curr_edge.right == null ) {
					this.edges.removeEdgeFromMesh( curr_edge );
				}
			}

			return this.faces.remove( f );
		} 
		return false;
	}

	boolean removeEdgeFromMesh( Edge e ) {
		if ( this.edges.contains( e ) ) {
			// Remove vertex that only belongs to this edge
			// Update edge reference for vertex that should still exist
			if ( e.start.e == e ) {
				ArrayList<Edge> eov = edgesOfVertex( e.start );
				if ( eov.size() > 1 ) {
					// set vertex edge to next reference
					e.start.setEdge( this.edges.indexOf(eov.get(1)) );
				} else {
					this.vertices.remove(
							this.vertices.indexOf( e.start ));	
				}
			} else if ( e.end.e == e ) {
				ArrayList<Edge> eov = edgesOfVertex( e.end );
				if ( eov.size() > 1 ) {
					// set vertex edge to next reference
					e.end.setEdge( this.edges.indexOf(eov.get(1)) );
				} else {
					this.vertices.remove(
							this.vertices.indexOf( e.end ));	
				}
			}
			return this.edges.remove( e );
		}
		return false;
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

		Edge e = this.edges.get( this.edges.indexOf(v.e) );
		do {
			eov.add(e);
			if ( e.end == v ) {
				e = e.lprev;
			} else {
				e = e.rprev;
			}
		} while ( e != this.edges.get( this.edges.indexOf(v.e) ) );

		return eov;
	}

	ArrayList<Vertex> verticesOfFace( Face f ) {
		ArrayList<Vertex> vertices_of_face = new ArrayList<Vertex>();
		ArrayList<Edge> eof = edgesOfFace( f );
		for ( int i = 0; i < eof.size(); i++ ){
			if ( !vertices_of_face.contains(eof.get(i).start) ) {
				vertices_of_face.add( eof.get(i).start );
			}
			if ( !vertices_of_face.contains(eof.get(i).end) ) {
				vertices_of_face.add( eof.get(i).end );
			}
		}
		return vertices_of_face;
	}

	ArrayList<Vertex> verticesOfFaces( ArrayList<Face> faces ) {
		ArrayList<Vertex> vertices_of_faces = new ArrayList<Vertex>();
		ArrayList<Vertex> vof;
		for ( int i = 0; i < faces.size(); i++ ) {
			vof = verticesOfFace( faces.get(i) );
			for ( int j = 0; j < vof.size(); j++ ) {
				if ( !vertices_of_faces.contains( vof.get(j) ) ) {
					vertices_of_faces.add( vof.get(i) );
				}
			}
		}
		return vertices_of_faces;
	}

	ArrayList<Edge> edgesOfFace( Face f ) {
		ArrayList<Edge> eof = new ArrayList<Edge>();

		Edge e = this.edges.get( this.edges.indexOf(f.e) );
		do {
			eof.add(e);
			if ( e.left == f ) {
				e = e.lnext;
			} else {
				e = e.rnext;
			}
		} while ( e != this.edges.get( this.edges.indexOf(f.e) ) );

		return eof;
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

	ArrayList<Face> facesOfVertex( Vertex v ) {
		ArrayList<Face> faces_of_vertex = new ArrayList<Face>();

		// todo: determine if there is an optimization
		// can I just add all left faces directly?
		ArrayList<Edge> eov = edgesOfVertex( v );
		ArrayList<Face> foe;
		for (int i = 0; i < eov.size(); i++ ) {
			foe = facesOfEdge( eov.get(i) );
			for ( int j = 0; j < foe.size(); j++ ) {
				if ( !faces_of_vertex.contains( foe.get(j) ) ) {
					faces_of_vertex.add( foe.get(j) );
				}
			}
		}

		return faces_of_vertex;
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
			// assume face has only 3 edges (TODO: validate)
			for ( int j = 0; j < 3; j++ ) {
				curr_edge = curr_eof.get(j);
				if ( !curr_edge.containsVertex(v) && 
						!esv.contains(curr_edge) ) {
					esv.add( curr_edge );
				}
			}
		}
		return esv;
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

	public boolean containsVertex( Vertex v ) {
		return ( start == v || end == v );
	}

	public boolean containsFace( Face f ) {
		return ( left == f || right == f );
	}

	public boolean removeFace( Face f ) {
		if ( f == left ) {
			// TODO: is this right?
			this.left = null;
			this.lprev = null;
			this.lnext = null;
			return true;
		} else if ( f == right ) {
			// TODO: is this right?
			this.right = null;
			this.rprev = null;
			this.rprev = null;
			return true;
		} else {
			console.log("face not in edge");
			return false;
		}
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
        return ((start == other.start && end == other.end) ||
					(end == other.start && start == other.end));    
    }
}

class Face {
	int id;
	int Edge;					// any adjacent edge index

	public Face( int id, Edge e ) {
		this.id = id;
		this.e = e;
	}

	public boolean equals(Object obj) {
		if ( obj instanceof Face) {
			Face other = (Face) obj;
			return (id == other.id);

		} else if ( obj instanceof Polygon ) {
			Polygon other = (Polygon) obj;
			return (other.points.size() == 3 && id == other.id);
		}
		return false;
	}
}

class Vertex {
	float x, y;
	Edge e;					// any incident edge index

	public Vertex( float x, float y) {
		this.x = x;
		this.y = y;
	}

	public float getLength() { 
		float l = Math.sqrt(x*x + y*y);
		return l;
	}

	public float getDistance( Vertex other ) {
		return Math.sqrt(
				Math.pow((other.x - x), 2) + Math.pow((other.y - y), 2));
	}
	
	void setEdge( Edge e ) {
		this.e = e;
	}

	boolean containsEdge( Edge e ) {
		this.e == e;
	}

    public int hashCode() {
        int hash = 17;
        hash = ((hash + x) << 5) - (hash + x);
        hash = ((hash + y) << 5) - (hash + y);
        return (int)hash;
    }

    public boolean equals(Object obj) {
        Vertex other = (Vertex) obj;
        return (x == other.x && y == other.y);
    }
}
