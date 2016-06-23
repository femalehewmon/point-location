class LayeredMesh extends Mesh {

	ArrayList<ArrayList<Integer>> layers;

	// Organizes faces into layers by id, but underneath the mesh is 
	// one cohesive layer.
	public LayeredMesh( ) {
		super();
	}

	public void addBaseTriangles( ArrayList<Polygon> baseTris ) {
		layers.add( new ArrayList<Integer>() );
		addTrianglesToLayer( 0 , baseTris );
	}

	public void addTrianglesToNextLayer( ArrayList<Polygon> tris ) {
		// copy all triangle ids from last layer to new layer
		layers.add( new ArrayList<Integer>( layers.get(layers.size() - 1)) );
		addTrianglesToLayer( layers.size(), tris );
	}

	public void addTrianglesTolayer( int layer, ArrayList<Polygon> tris ) {
		// TODO: validate that triangle ID has not already been added?
		if ( layer >= layers.size() ) {
			console.log( "ERROR: layer does not exist, cannot add tris");
			return;
		}

		for ( int i = 0; i < tris.size(); i++ ) {
			layers[i].add( tris.id );
		}
		addTrianglesToMesh( baseTris );
	}

	public void removeFacesFromMesh( ArrayList<Face> faces ) {
		super.removeFacesFromMesH( faces );
		int curr_layer;
		for ( int i = 0; i < faces.size(); i++ ) {
			// remove face from current layer
			curr_layer = this.layers.size() - 1;
			this.layers.get( curr_layer ).remove(
					layers.get( curr_layer ).indexOf( faces.get(i).id ));
		}
	}

}
