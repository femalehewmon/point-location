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
		console.log("Adding triangles to layer " + layer);
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
		layers.get(layer).addPolygonsToLayer( polyIds );
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

	public ArrayList<Polygon> getPolygonsByLayer( int layer ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			MeshLayer currLayer;
			for ( int i = 0; i <= layer; i++ ) {
				currLayer = this.layers.get(i);
			}
			for( int i = 0; i < currLayer.visiblePolygons.size(); i++ ) {
				polys.add(
						this.polygons.get(currLayer.visiblePolygons.get(i)));
			}
		}
		return polys;
	}

	public ArrayList<Polygon> getVisiblePolygonsByLayer( int layer ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		if ( 0 > layer || layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
		} else {
			ArrayList<Integer> polyIds = new ArrayList<Integer>();
			for ( int i = 0; i <= layer; i++ ) {
				polyIds.addAll( this.layers.get(i).getPolyg
				currLayer = this.layers.get(i);
				for ( int j = 0;
			}
			for( int i = 0; i < currLayer.visiblePolygons.size(); i++ ) {
				polys.add(
						this.polygons.get(currLayer.visiblePolygons.get(i)));
			}
		}
		return polys;
	}

	public ArrayList<Polygon> getPolygonsById( ArrayList<Integer> polyIds ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		for ( int i = 0; i < polyIds.size(); i++ ){
			polys.add( this.polygons.get( polyIds.get(i) ) );
		}
	}

}

class MeshLayer {

	// Mutually indexed, when a vertex is removed the same index in
	// polygonsRemoved contains a list of associated polygons removed
	// with it. Additionally, polygonsAdded contains the indexed polygons
	// added as a direct result of filling in for the removed polygons
	// --- written for KP data structure, could be made more general?
	ArrayList<Vertex> verticesRemoved;
	ArrayList<ArrayList<Integer>> polygonsRemoved;
	ArrayList<ArrayList<Integer>> polygonsAdded;

	ArrayList<MeshLayer> subLayers;

	public MeshLayer() {
		this.verticesRemoved = new ArrayList<Vertex>();
		this.polygonsRemoved = new ArrayList<ArrayList<Integer>>();
		this.polygonsAdded = new ArrayList<Integer>();
		this.subLayers = new ArrayList<MeshLayer>();
	}

	public ArrayList<Integer> getPolygonsAddedToLayer() {
		ArrayList<Integer> polyIds;
		for ( int i = 0; i < this.subLayers.size(); i++ ) {
			polyIds.addAll( this.subLayers.get(i).getPolygsonAddedToLayer() );
		}
		return polyIds;
	}

	public void addPolygonsToLayer( ArrayList<Integer> polyIds ) {
		polygonsAdded.add( polyIds );
	}

	public void addPolygonsToLastSubLayer( ArrayList<Integer> polyIds ) {
		this.subLayers.get( this.subLayers.size() - 1 ).addPolygonsToLayer(
				polyIds);
	}

	public void removeVertexFromLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		verticesRemoved.add( vertex );
		polygonsRemoved.add( polyIds );
	}

	public void removeVertexFromLastSubLayer(
			Vertex vertex, ArrayList<Integer> polyIds ) {
		this.subLayers.get( this.subLayers.size() - 1 ).
			removeVertexFromLastSubLayer( vertex, polyIds );
	}


}
