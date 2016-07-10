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
		createNewLayer(); // create initial layer
	}

	private void createNewLayer() {
		this.layers.add( new MeshLayer() );
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

	public void removeVertexFromMesh( Vertex vertex, ArrayList<Face> faces ) {
		super.removeFacesFromMesh( faces );
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		for ( int i = 0; i < faces.size(); i++ ) {
			polyIds.add( faces.get(i).id );
		}
		// remove vertex and associated faces from current layer
		int currLayer = this.layers.size() - 1;
		this.layers.get( currLayer ).removeVertexFromLayer( vertex, polyIds );
	}

	public ArrayList<Polygon> getVisiblePolygonsByLayer( int layer ) {
		int i, j;
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			ArrayList<Integer> polyIds = new ArrayList<Integer>();
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
			// an array of polygons visible at the completion of the layer
			polys = getPolygonsById( polyIds );
		}
		return polys;
	}

	public ArrayList<ArrayList<Polygon>> getPolygonsAddedBySubLayer(int layer){
		int i, j;
		ArrayList<ArrayList<Polygon>> polys = new ArrayList<ArrayList<Polygon>>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			ArrayList<Integer> polyIds = new ArrayList<Integer>();
			ArrayList<Integer> addedPolys;
			for ( i = 0; i < this.layers.get(i).subLayers.size(); i++ ) {
				addedPolys =
					layers.get(i).subLayers.get(j).getPolygonsAddedToLayer();

				for ( j = 0; j < addedPolys.size(); j++ ) {
					polyIds.add( addedPolys.get(j) );
				}	

				// add polygons remove in this sublayer
				polys.add(getPolygonsById( polyIds ));
				polyIds.clear();
			}

			// add polygons visible at base of this layer 
			polys.add(getPolygonsById( polyIds ));
		}
		return polys;
	}

	public ArrayList<ArrayList<Polygon>> getPolygonsRemovedBySubLayer(int layer){
		int i, j;
		ArrayList<ArrayList<Polygon>> polys =
			new ArrayList<ArrayList<Polygon>>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			ArrayList<Integer> polyIds = new ArrayList<Integer>();
			ArrayList<Integer> removedPolys;
			for ( i = 0; i < this.layers.get(i).subLayers.size(); i++ ) {
				removedPolys =
					layers.get(i).subLayers.get(j).getPolygonsRemovedFromLayer();

				for ( j = 0; j < removedPolys.size(); j++ ) {
					polyIds.add( removedPolys.get(j) );
				}	

				// add polygons remove in this sublayer
				polys.add(getPolygonsById( polyIds ));
				polyIds.clear();
			}
		}
		return polys;
	}

	public ArrayList<Polygon> getPolygonsById( ArrayList<Integer> polyIds ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		for ( int i = 0; i < polyIds.size(); i++ ){
			polys.add( this.polygons.get( polyIds.get(i) ) );
		}
		return polys;
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
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		ArrayList<Integer> removedPolys;
		for ( i = 0; i < subLayers.size(); i++ ) {
			removedPolys = subLayers.get(i).getPolygonsRemovedFromLayer();
			for ( j = 0; j < removedPolys.size(); j++ ) {
				polyIds.add( removedPolys.get(j) );
			}
		}
		return polyIds;
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

	public void removeVertexFromLastSubLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		this.subLayers.get( this.subLayers.size() - 1 ).
			removeVertexFromLastSubLayer( vertex, polyIds );
	}


}
