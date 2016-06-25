class LayeredMesh extends Mesh {

	ArrayList<ArrayList<Integer>> layers;
	int numLayers;

	// Organizes faces into layers by id, but underneath the mesh is
	// one cohesive layer.
	public LayeredMesh( ) {
		super();
		this.layers = new ArrayList<ArrayList<Integer>>();
		this.numLayers = 0;
		createNewLayer(); // create initial layer
	}

	private void createNewLayer() {
		if ( this.layers.size() > 0 ) {
			// copy all triangle ids from last layer to new layer
			this.layers.add(
					new ArrayList<Integer>(layers.get(layers.size() - 1)));
		} else {
			this.layers.add( new ArrayList<Integer>() );
		}
		this.numLayers += 1;
	}

	public void addTrianglesToNextLayer( ArrayList<Polygon> tris ) {
		createNewLayer();
		addTrianglesToLayer( layers.size() - 1, tris );
	}

	public void addTrianglesToLayer( int layer, ArrayList<Polygon> tris ) {
		// TODO: validate that triangle ID has not already been added?
		if ( layer >= layers.size() ) {
			console.log( "ERROR: layer does not exist, cannot add tris");
			return;
		}

		for ( int i = 0; i < tris.size(); i++ ) {
			layers.get(layer).add( tris.get(i).id );
		}
		addTrianglesToMesh( tris );
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
