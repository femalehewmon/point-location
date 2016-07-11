class LayeredMesh extends Mesh {

	ArrayList<MeshLayer> layers;
	HashMap<Integer, Polygon> polygons;

	// Organizes faces into layers by id as they are added and removed,
	// but underneath the mesh is one cohesive layer, so once a face/vertex is
	// removed it must be re-added as new objects
	public LayeredMesh( ) {
		super();
		this.polygons = new HashMap<Integer, Polygon>();
		this.layers = new ArrayList<MeshLayer>();
	}

	public int createNewLayer() {
		this.layers.add( new MeshLayer() );
		return this.layers.size() - 1;
	}

	public void addTrianglesToNextLayer( ArrayList<Polygon> tris ) {
		createNewLayer();
		addTrianglesToLayer( layers.size() - 1, tris );
	}

	public void addTrianglesToLayer( int layer, ArrayList<Polygon> tris ) {
		// TODO: validate that triangle ID has not already been added?
		console.log("*************************");
		console.log("Adding " + tris.size() + " triangles to layer " + layer);
		console.log("*************************");

		if ( layer >= layers.size() ) {
			console.log( "ERROR: layer does not exist, cannot add tris");
			return;
		}
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		for ( int i = 0; i < tris.size(); i++ ) {
			if ( !polygons.containsKey( tris.get(i).id )) {
				// add polygon to master list
				polygons.put( tris.get(i).id, tris.get(i) );
			}
			polyIds.add( tris.get(i).id );
		}
		layers.get(layer).addPolygonsToSubLayer( polyIds );
		addTrianglesToMesh( tris );
	}

	public void removeVertexFromLayer(
			int layer, Vertex vertex, ArrayList<Face> faces ) {
		super.removeFacesFromMesh( faces );
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		for ( int i = 0; i < faces.size(); i++ ) {
			polyIds.add( faces.get(i).id );
		}
		// remove vertex and associated faces from current layer
		this.layers.get(layer).removeVertexFromSubLayer( vertex, polyIds );
	}

	public ArrayList<Integer> getVisiblePolygonIdsByLayer( int layer ) {
		int i, j;
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			ArrayList<Integer> addedPolys;
			ArrayList<Integer> removedPolys;
			for ( i = 0; i <= layer; i++ ) {
				addedPolys = this.layers.get(i).getPolygonsAddedToLayer();
				for ( j = 0; j < addedPolys.size(); j++ ) {
					polyIds.add( addedPolys.get(j) );
				}
				removedPolys = this.layers.get(i).getPolygonsRemovedFromLayer();
				for ( j = 0; j < removedPolys.size(); j++ ) {
					polyIds.remove( polyIds.getIndexOf(removedPolys.get(j)) );
				}
			}
		}
		return polyIds;
	}

	public ArrayList<Integer> getVisiblePolygonsByLayer( int layer ) {
		return getPolygonsById( getVisiblePolygonIdsByLayer( layer ) );
	}

	public ArrayList<ArrayList<Integer>> getPolygonIdsAddedBySubLayer(int layer){
		int i;
		ArrayList<ArrayList<Integer>> polyIds =
			new ArrayList<ArrayList<Integer>>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			// add sub layer polygons
			for ( i = 0; i < this.layers.get(layer).subLayers.size(); i++ ) {
				polyIds.add(
						layers.get(layer).subLayers.get(i).getPolygonsAddedToLayer());
			}
		}
		return polyIds;
	}

	public ArrayList<Integer> getPolygonsAddedBySubLayer( int layer ) {
		return getPolygonsById( getPolygonIdsAddedBySubLayer( layer ) );
	}

	public ArrayList<ArrayList<Integer>> getPolygonIdsRemovedBySubLayer(int layer){
		int i;
		ArrayList<ArrayList<Integer>> polyIds =
			new ArrayList<ArrayList<Integer>>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			// add sub layer polygons
			for ( i = 0; i < this.layers.get(layer).subLayers.size(); i++ ) {
				polyIds.add(
						layers.get(layer).subLayers.get(i).getPolygonsRemovedFromLayer());
			}
		}
		return polyIds;
	}

	public ArrayList<Integer> getPolygonsRemovedBySubLayer( int layer ) {
		return getPolygonsById( getPolygonIdsRemovedBySubLayer( layer ) );
	}

	public ArrayList<Polygon> getPolygonsById( ArrayList<Integer> polyIds ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		for ( int i = 0; i < polyIds.size(); i++ ){
			polys.add( getPolygonById( polyIds.get(i) ));
		}
		return polys;
	}

	public Polygon getPolygonById( int polyId ) {
		return this.polygons.get( polyId );
	}

}

class MeshLayer {

	// Mutually indexed, when a vertex is removed the same index in
	// polygonsRemoved contains a list of associated polygons removed
	// with it. Additionally, polygonsAdded contains the indexed polygons
	// added as a direct result of filling in for the removed polygons
	// --- written for KP data structure, could be made more general?
	ArrayList<Vertex> verticesRemoved;
	ArrayList<Integer> polygonsRemoved;
	ArrayList<Integer> polygonsAdded;

	ArrayList<MeshLayer> subLayers;

	public MeshLayer() {
		this.verticesRemoved = new ArrayList<Vertex>();
		this.polygonsRemoved = new ArrayList<Integer>();
		this.polygonsAdded = new ArrayList<Integer>();
		this.subLayers = new ArrayList<MeshLayer>();
	}

	public ArrayList<Integer> getPolygonsAddedToLayer() {
		int i, j;
		ArrayList<Integer> polyIds = new ArrayList<Integer>( polygonsAdded );
		ArrayList<Integer> addedPolys;
		for ( i = 0; i < subLayers.size(); i++ ) {
			addedPolys = subLayers.get(i).getPolygonsAddedToLayer();
			for ( j = 0; j < addedPolys.size(); j++ ) {
				polyIds.add( addedPolys.get(j) );
			}
			// processing.js issue that this doesn't work?
			// polyIds.addAll( this.subLayers.get(i).getPolygsonAddedToLayer());
		}
		return polyIds;
	}

	public ArrayList<Integer> getPolygonsRemovedFromLayer() {
		int i, j;
		ArrayList<Integer> polyIds = new ArrayList<Integer>( polygonsRemoved );
		ArrayList<Integer> removedPolys;
		for ( i = 0; i < subLayers.size(); i++ ) {
			removedPolys = subLayers.get(i).getPolygonsRemovedFromLayer();
			for ( j = 0; j < removedPolys.size(); j++ ) {
				polyIds.add( removedPolys.get(j) );
			}
		}
		return polyIds;
	}

	public ArrayList<Vertex> getVerticesRemovedFromLayer() {
		int i, j;
		ArrayList<Vertex> verts = new ArrayList<Vertex>( verticesRemoved );
		ArrayList<Vertex> removedVerts;
		for ( i = 0; i < subLayers.size(); i++ ) {
			removedVerts = subLayers.get(i).getVerticesRemovedFromLayer();
			for ( j = 0; j < removedVerts.size(); j++ ) {
				verts.add( removedVerts.get(j) );
			}
		}
		return verts;
	}

	public void addPolygonsToLayer( ArrayList<Integer> polyIds ) {
		for( int i = 0; i < polyIds.size(); i++ ) {
			polygonsAdded.add( polyIds.get(i) );
		}
	}

	public void removeVertexFromLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		verticesRemoved.add( vertex );
		for( int i = 0; i < polyIds.size(); i++ ) {
			polygonsRemoved.add( polyIds.get(i) );
		}
	}

	public void addPolygonsToSubLayer( ArrayList<Integer> polyIds ) {
		MeshLayer subLayer = new MeshLayer();
		subLayer.addPolygonsToLayer( polyIds );
		this.subLayers.add( subLayer );
	}

	public void removeVertexFromSubLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		MeshLayer subLayer = new MeshLayer();
		subLayer.removeVertexFromLayer( vertex, polyIds );
		this.subLayers.add( subLayer );
	}

	public void removeVertexFromLastSubLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		this.subLayers.get( this.subLayers.size() - 1 ).
			removeVertexFromLayer( vertex, polyIds );
	}


}
