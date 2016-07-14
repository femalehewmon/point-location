class Mesh {
	// Winged-edge mesh structure
	// See the following for reference:
	//		Fundamentals of computer graphics. CRC Press, 2015.
	//		Shirley, Peter, Michael Ashikhmin, and Steve Marschner.

	ArrayList<Vertex> vertices;
	ArrayList<Edge> edges;
	ArrayList<Face> faces;
	ArrayList<Edge> outerEdges;

	public Mesh( ) {
		this.vertices = new ArrayList<Vertex>();
		this.edges = new ArrayList<Edge>();
		this.faces = new ArrayList<Face>();
		this.outerEdges = new ArrayList<Edge>();
	}

	public void clear() {
		this.vertices.clear();
		this.edges.clear();
		this.faces.clar();
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
			this.vertices.get(idx_v1).setEdge(this.edges.get(idx_e1));
			this.vertices.get(idx_v2).setEdge(this.edges.get(idx_e2));
			this.vertices.get(idx_v3).setEdge(this.edges.get(idx_e3));

			// Create new face and add to mesh structure
			// assumes this is definitely a new face, so code carefully
			Face f = new Face( curr_tri.id, e1 );
			int idx_f = addFaceToMesh(f);

			// Fill in edge details
			// First edge
			if ( this.edges.get(idx_e1).start.equals(e1.start) ) {
				// same orientation, edge had not yet been added
				this.edges.get(idx_e1).right = this.faces.get(idx_f);
				this.edges.get(idx_e1).rprev = this.edges.get(idx_e3);
				this.edges.get(idx_e1).rnext = this.edges.get(idx_e2);
			} else if ( this.edges.get(idx_e1).start.equals(e1.end) ) {
				// opposite orientation, edge had been added
				this.edges.get(idx_e1).left = this.faces.get(idx_f);
				this.edges.get(idx_e1).lprev = this.edges.get(idx_e3);
				this.edges.get(idx_e1).lnext = this.edges.get(idx_e2);
			} else {
				console.log("WARNING: edge does not match.. weird!");
			}

			// Second edge
			if ( this.edges.get(idx_e2).start.equals(e2.start) ) {
				// same orientation, edge had not yet been added (hopefully)
				this.edges.get(idx_e2).right = this.faces.get(idx_f);
				this.edges.get(idx_e2).rprev = this.edges.get(idx_e1);
				this.edges.get(idx_e2).rnext = this.edges.get(idx_e3);
			} else if ( this.edges.get(idx_e2).start.equals(e2.end) ) {
				// opposite orientation, edge had been added
				this.edges.get(idx_e2).left = this.faces.get(idx_f);
				this.edges.get(idx_e2).lprev = this.edges.get(idx_e1);
				this.edges.get(idx_e2).lnext = this.edges.get(idx_e3);
			} else {
				console.log("WARNING: edge does not match.. weird!");
			}

			// Third edge
			if ( this.edges.get(idx_e3).start.equals(e3.start) ) {
				// same orientation, edge had not yet been added (hopefully)
				this.edges.get(idx_e3).right = this.faces.get(idx_f);
				this.edges.get(idx_e3).rprev = this.edges.get(idx_e2);
				this.edges.get(idx_e3).rnext = this.edges.get(idx_e1);
			} else if ( this.edges.get(idx_e3).start.equals(e3.end) ) {
				// opposite orientation, edge had been added
				this.edges.get(idx_e3).left = this.faces.get(idx_f);
				this.edges.get(idx_e3).lprev = this.edges.get(idx_e2);
				this.edges.get(idx_e3).lnext = this.edges.get(idx_e1);
			} else {
				console.log("WARNING: edge does not match.. weird!");
			}

			//console.log("Edges created for tri: " + tris.get(i).id);
			//console.log(e1);
			//console.log(e2);
			//console.log(e3);
			//console.log(f);
		}

		// cleanup outer edges
		for ( int i = this.outerEdges.size()-1; i >= 0; i-- ) {
			if ( this.outerEdges.get(i).isFull() ) {
				this.outerEdges.remove( i );
			}
		}
	}

	int addFaceToMesh( Face f ) {
		if ( !this.faces.contains(f) ) {
			//console.log("New face " + f.id);
			this.faces.add(f);
		}
		return this.faces.indexOf( f );
	}

	int addVertexToMesh( Vertex v ) {
		if ( !this.vertices.contains(v) ) {
			//console.log("New vertex " + v.x + ", " + v.y);
			this.vertices.add(v);
		}
		return this.vertices.indexOf( v );
	}

	int addEdgeToMesh( Edge e ) {
		if ( !this.edges.contains(e) ) {
			//console.log("New edge "
		//			+ e.start.x + ", " + e.start.y + "  to  "
		//			+ e.end.x + ", " + e.end.y);
			this.edges.add(e);
			this.outerEdges.add(e);
		}
		return this.edges.indexOf( e );
	}


	void removeFacesFromMesh( ArrayList<Polygon> tris ) {
		Face curr_face;
		for ( int i = 0; i < tris.size(); i++ ) {
			if ( this.faces.contains( tris.get(i)) ) {
				removeFaceFromMesh(
						this.faces.get(this.faces.indexOf(tris.get(i))));
			} else {
				//console.log(
				//		"Mesh does not contain face.. doing something wrong?");
			}
		}
	}

	boolean removeFaceFromMesh( Face f ) {
		if ( this.faces.contains(f) ) {
			//console.log("attempt to remove face " + f.id + " from mesh");

			// Get all edges connected to the face
			ArrayList<Edge> eof = edgesOfFace( f );

			// Find list of edges that will be removed completely from the mesh
			ArrayList<Edge> edges_to_remove = new ArrayList<Edge>();
			ArrayList<Edge> edges_to_update = new ArrayList<Edge>();
			Edge curr_edge;
			for ( int i = 0; i < eof.size(); i++ ) {
				curr_edge = eof.get(i);
				if (( f.equals(curr_edge.left) && curr_edge.right == null) ||
					( f.equals(curr_edge.right) && curr_edge.left == null) ){
					// edge will be detached from all faces, so remove from mesh
					edges_to_remove.add( this.edges.get(
							   this.edges.indexOf(curr_edge)) );
				} else {
					// edge will still be attached to a face, so just remove face
					edges_to_update.add( this.edges.get(
							   this.edges.indexOf(curr_edge)) );
				}
			}

			//console.log(" =============== " );
			//console.log(" EDGES TO REMOVE " );
			for ( int i = 0; i < edges_to_remove.size(); i++ ){
				//console.log(edges_to_remove.get(i));
			}
			//console.log(" EDGES TO UPDATE " );
			for ( int i = 0; i < edges_to_update.size(); i++ ){
				//console.log(edges_to_update.get(i));
			}
			//console.log(" =============== " );

			// Go through list of connected vertices and update any references
			// within the vertices to the edges that will be removed
			// This must be done before starting to remove edges to prevent
			// edge references getting messed up before correcting for them
			ArrayList<Vertex> vertices_to_remove = new ArrayList<Vertex>();
			ArrayList<Vertex> vof = verticesOfFace( f );
			for ( int i = 0; i < vof.size(); i++ ) {
				// current edge referenced is going to be removed
				if ( edges_to_remove.contains( vof.get(i).e ) ) {
					// attempt to update vertex edge with an edge that is
					// not going to be removed
					ArrayList<Edge> eov = edgesOfVertex( vof.get(i) );
					vof.get(i).setEdge(null);
					for ( int j = 0; j < eov.size(); j++ ) {
						if ( !edges_to_remove.contains(eov.get(j)) ) {
							vof.get(i).setEdge( eov.get(j) );
							//console.log("updated edge of vertex "
							//		+ vof.get(i).description);
							break;
						}
					}
					// if vertex edge was not updated, then remove vertex
					// this means that the vertex is not connected to any
					// edges that will remain in the mesh
					// NOTE: not deleted directly here to avoid potential
					// changing of mesh while still iterating
					if ( vof.get(i).e == null ) {
						vertices_to_remove.add(vof.get(i));
					}
				}
			}

			// Now, safely remove edges from mesh
			for( int i = 0; i < edges_to_update.size(); i++ ) {
				edges_to_update.get(i).removeFace( f );
				this.outerEdges.add( edges_to_update.get(i) );
			}
			for( int i = 0; i < edges_to_remove.size(); i++ ) {
				if ( this.edges.remove( edges_to_remove.get(i) ) ) {
					//console.log("----------> remove edge from mesh, " +
					//		+ edges_to_remove.get(i).start.description + ", "
					//		+ edges_to_remove.get(i).end.description);
					if ( this.outerEdges.contains( edges_to_remove.get(i))){
						this.outerEdges.remove( edges_to_remove.get(i) );
					}
				} else {
					console.log("ERROR: failed to remove edge from mesh");
				}
			}

			// Next, safely remove vertices from mesh
			for( int i = 0; i < vertices_to_remove.size(); i++) {
				if ( this.vertices.remove( vertices_to_remove.get(i) ) ) {
					//console.log("----------> remove vertex from mesh, " +
					//		vof.get(i).description);
				} else {
					console.log("ERROR: failed to remove vertex from mesh");
				}
			}

			// Finally, remove face itself from mesh
			if ( this.faces.remove( f ) ) {
				//console.log("----------> remove face from mesh, " + f.id);
			} else {
				console.log("ERROR: failed to remove face from mesh");
			}
			return true;
		}
		console.log("WARNING: attempted to remove face not in mesh " + f.id);
		return false;
	}

	ArrayList<Edge> edgesOfVertex( Vertex v ) {
		ArrayList<Edge> eov = new ArrayList<Edge>();
		ArrayList<Edge> localOuterEdges = new ArrayList<Edge>(outerEdges);

		Edge e = this.edges.get( this.edges.indexOf(v.e) );
		do {
			if ( !eov.contains( e ) ) {
				eov.add( this.edges.get(this.edges.indexOf(e)) );
				if ( v.equals(e.end) ) {
					e = e.lprev;
				} else if ( v.equals(e.start) ) {
					e = e.rprev;
				}
			} else {
				// this is done to correctly handle traversal of mesh with
				// inner holes/inner edges in the outerEdge list caused by
				// face removal
				//console.log("switching direction to find different outer edge");
				if ( v.equals(e.end) ) {
					e = e.rnext;
				} else if ( v.equals(e.start) ) {
					e = e.lnext;
				}
			}
			// if edge is null, it means that an outer edge has been hit
			// in this case, look for another outer edge that connects to
			// the current vertex, and search backwards
			if ( e == null ) {
				for ( int i = 0; i < localOuterEdges.size(); i++ ) {
					if ( localOuterEdges.get(i) != eov.get(eov.size() - 1) &&
							localOuterEdges.get(i).containsVertex( v ) ) {
						e = localOuterEdges.get(i);
						localOuterEdges.remove(e);
					}
				}
			}
			e = this.edges.get( this.edges.indexOf( e ) );
		} while ( !e.equals( v.e ) );

		return eov;
	}

	ArrayList<Vertex> verticesOfFace( Face f ) {
		ArrayList<Vertex> vertices_of_face = new ArrayList<Vertex>();
		ArrayList<Edge> eof = edgesOfFace( f );
		for ( int i = 0; i < eof.size(); i++ ){
			if ( !vertices_of_face.contains(eof.get(i).start) ) {
				vertices_of_face.add(
						this.vertices.get(
							this.vertices.indexOf(eof.get(i).start) ));
			}
			if ( !vertices_of_face.contains(eof.get(i).end) ) {
				vertices_of_face.add(
						this.vertices.get(
							this.vertices.indexOf(eof.get(i).end) ));
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
					vertices_of_faces.add( vof.get(j) );
				}
			}
		}
		return vertices_of_faces;
	}

	ArrayList<Edge> edgesOfFace( Face f ) {
		ArrayList<Edge> eof = new ArrayList<Edge>();

		int count_to_exit = 0;
		Edge e = this.edges.get( this.edges.indexOf(f.e) );
		do {
			eof.add( this.edges.get( this.edges.indexOf(e)) );
			if ( e.left == f ) {
				e = e.lnext;
			} else {
				e = e.rnext;
			}
			e = this.edges.get( this.edges.indexOf( e ) );
		} while ( !e.equals( f.e ) );

		return eof;
	}

	ArrayList<Face> facesOfEdge( Edge e ) {
		ArrayList<Face> foe = new ArrayList<Face>();

		if ( e.left != null ) {
			foe.add( this.faces.get( this.faces.indexOf(e.left) ));
		}
		if ( e.right != null ) {
			foe.add( this.faces.get( this.faces.indexOf(e.right) ));
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

	ArrayList<Vertex> verticesSurroundingVertex( Vertex v ) {
		ArrayList<Vertex> vov = new ArrayList<Vertex>();

		ArrayList<Edge> eov = edgesOfVertex( v );
		for ( int i = 0; i < eov.size(); i++ ) {
			if ( eov.get(i).start.equals(v) ) {
				vov.add( eov.get(i).end );
			} else if( eov.get(i).end.equals(v) ) {
				vov.add( eov.get(i).start );
			} else {
				console.log("WARNING: vertex not part of edge... not right!");
			}
		}

		return vov;
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
					esv.add( this.edges.get(this.edges.indexOf(curr_edge)) );
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
	String description;

	public Edge( Vertex start, Vertex end ) {
		this.start = start;
		this.end = end;
		this.description = this.start.description + " TO " + this.end.description;
		this.lprev = null;
		this.lnext = null;
		this.rprev = null;
		this.rnext = null;
		this.left = null;
		this.right = null;
	}

	public boolean containsVertex( Vertex v ) {
		return ( v.equals(start) || v.equals(end) );
	}

	public boolean containsFace( Face f ) {
		return ( f.equals(left) || f.equals(right) );
	}

	public boolean isFull() {
		return this.right != null & this.left != null;
	}

	public boolean isEmpty() {
		return this.right == null & this.left == null;
	}

	public boolean removeFace( Face f ) {
		if ( f.equals( this.left ) ) {
			this.left = null;
			this.lprev = null;
			this.lnext = null;
		} else if ( f.equals( this.right ) ) {
			this.right = null;
			this.rprev = null;
			this.rprev = null;
		} else {
			console.log("WARNING: face not in edge");
		}

		if ( isEmpty() ) {
			// edge no longer has an attached face
			return true;
		}
		// edge still has an attached face
		return false;
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
        return ((start.equals(other.start) && end.equals(other.end)) ||
					(end.equals(other.start) && start.equals(other.end)));
    }
}

class Face {
	int id;
	Edge e;					// any adjacent edge index
	String description;

	public Face( int id, Edge e ) {
		this.id = id;
		this.e = e;
		this.description = "id " + this.id;
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
	String description;

	public Vertex( float x, float y) {
		this.x = x;
		this.y = y;
		this.description = x + ", " + y;
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
