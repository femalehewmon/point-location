class KirkpatrickMesh extends Mesh {

	ArrayList<KirkpatrickLayer> layers;
	HashMap<Integer, Polygon> polygons;

	int numLayers;

	// Organizes faces into layers by id, but underneath the mesh is
	// one cohesive layer.
	public KirkpatrickMesh( ) {
		super();
		this.polygons = new HashMap<Integer, Polygon>();
		this.layers = new ArrayList<KirkpatrickLayer>();
		this.numLayers = 0;
		createNewLayer(); // create initial layer
	}

	private void createNewLayer() {
		if ( this.layers.size() > 0 ) {
			// copy all triangle ids from last layer to new layer
			KirkpatrickLayer newLayer = new KirkpatrickLayer(
					layers.get( layers.size() - 1 ).visiblePolygons );
			this.layers.add( newLayer );
		} else {
			this.layers.add( new KirkpatrickLayer() );
		}
		this.numLayers += 1;
	}

	public void addTrianglesToNextLayer( ArrayList<Polygon> tris ) {
		createNewLayer();
		addTrianglesToLayer( layers.size() - 1, tris );
	}

	public void addTrianglesToLayer( int layer, ArrayList<Polygon> tris ) {
		console.log("**************Adding to layer " + layer);
		// TODO: validate that triangle ID has not already been added?
		if ( layer >= layers.size() ) {
			console.log( "ERROR: layer does not exist, cannot add tris");
			return;
		}
		for ( int i = 0; i < tris.size(); i++ ) {
			if ( !polygons.containsKey( tris.get(i).id )) {
				// add polygon to master list
				polygons.put( tris.get(i).id, tris.get(i) );
			}
			layers.get(layer).addVisiblePolygon( tris.get(i).id );
		}
		addTrianglesToMesh( tris );
	}

	public ArrayList<Polygon> getPolygonsByLayer( int layer ) {
		ArrayList<Polygon> polys = new ArrayList<Polygon>();
		if ( layer >= layers.size() ) {
			console.log("ERROR: layer does not exist, cannot get polygons");
			return;
		}
		KirkpatrickLayer curr_layer = this.layers.get(layer);
		for( int i = 0; i < curr_layer.visiblePolygons.size(); i++ ) {
			polys.add( this.polygons.get(curr_layer.visiblePolygons.get(i)) );
		}
		return polys;
	}

	public void removeLowDegreeVertexFromMesh(
			Vertex vertex, ArrayList<Face> faces ) {
		console.log("Remove low degree vertex !!!!!!!!!!" );
		super.removeFacesFromMesh( faces );
		IndependentLowDegreeVertex ildv =
			new IndependentLowDegreeVertex(vertex);
		for ( int i = 0; i < faces.size(); i++ ) {
			// remove face from current layer
			ildv.addSurroundingPolygon( faces.get(i).id );
		}
		this.layers.get(this.layers.size() - 1).removeIldv( ildv );
	}

}

class KirkpatrickLayer {

	ArrayList<Integer> visiblePolygons;
	ArrayList<IndependentLowDegreeVertex> ildvsToRemove;

	public KirkpatrickLayer( ArrayList<Integer> visiblePolygons ) {
		this.visiblePolygons = new ArrayList<Integer>( visiblePolygons );
		this.ildvsToRemove = new ArrayList<IndependentLowDegreeVertex>();
	}

	public KirkpatrickLayer( ) {
		this.visiblePolygons = new ArrayList<Integer>();
		this.ildvsToRemove = new ArrayList<IndependentLowDegreeVertex>();
	}

	public void removeIldv( IndependentLowDegreeVertex ildv ) {
		ildvsToRemove.add( ildv );
	}

	public void addVisiblePolygon( int polygonId ) {
		visiblePolygons.add( polygonId );
	}

}

class IndependentLowDegreeVertex {

	Vertex vertex;
	ArrayList<Integer> surroundingPolygonIds;

	public IndependentLowDegreeVertex( Vertex vertex ) {
		this.vertexId = vertexId;
		this.surroundingPolygonIds = new ArrayList<Integer>();
	}

	public IndependentLowDegreeVertex(
			Vertex vertex, ArrayList<Integer> polygonIds ) {
		this.vertex = vertex;
		this.surroundingPolygonIds = polygonIds;
	}

	public void addSurroundingPolygon( Integer polygonId ) {
		this.surroundingPolygonIds.add( polygonId );
	}

}
