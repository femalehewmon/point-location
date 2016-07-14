class LayeredMesh extends Mesh {

	ArrayList<MeshLayer> layers;
	ArrayList<color> layerColors;
	HashMap<Integer, Polygon> polygons;

	// Organizes faces into layers by id as they are added and removed,
	// but underneath the mesh is one cohesive layer, so once a face/vertex is
	// removed it must be re-added as new objects
	public LayeredMesh( ) {
		super();
		this.polygons = new HashMap<Integer, Polygon>();
		this.layers = new ArrayList<MeshLayer>();
		this.layerColors = new ArrayList<color>();
	}

	public LayeredMesh copy() {
		LayeredMesh copy = new LayeredMesh();
		Iterator<Integer> iterator = polygons.keySet().iterator();
		while( iterator.hasNext() ) {
			Integer polyId = iterator.next();
			copy.polygons.put( polyId, this.polygons.get(polyId).copy() );
		}
		for( int i = 0; i < layers.size(); i++ ) {
			copy.layers.add( layers.get(i).copy() );
		}
		copy.layerColors = new ArrayList<color>(this.layerColors);
		return copy;
	}

	public int createNewLayer() {
		this.layers.add( new MeshLayer() );
		return this.layers.size() - 1;
	}

	public void setLayerColors( ArrayList<color> layerColors ) {
		this.layerColors = layerColors;
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

	public void removeVertexFromLayer( int layer, Vertex vertex ) {
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		// remove vertex and associated faces from current layer
		this.layers.get(layer).removeVertexFromSubLayer( vertex );
	}

	public void removeFacesFromLayer( int layer, ArrayList<Face> faces ) {
		super.removeFacesFromMesh( faces );
		ArrayList<Integer> polyIds = new ArrayList<Integer>();
		for ( int i = 0; i < faces.size(); i++ ) {
			polyIds.add( faces.get(i).id );
		}
		// remove vertex and associated faces from current layer
		this.layers.get(layer).removePolygonsFromSubLayer( polyIds );
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
					polyIds.remove( polyIds.indexOf(removedPolys.get(j)) );
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

	public MeshLayer copy() {
		MeshLayer copy = new MeshLayer();
		copy.verticesRemoved = new ArrayList<Vertex>( verticesRemoved );
		copy.polygonsRemoved = new ArrayList<Integer>( polygonsRemoved );
		copy.polygonsAdded = new ArrayList<Integer>( polygonsAdded );
		for( int i = 0; i < subLayers.size(); i++ ) {
			copy.subLayers.add( subLayers.get(i).copy() );
		}
		return copy;
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

	public void addPolygonsToSubLayer( ArrayList<Integer> polyIds ) {
		MeshLayer subLayer = new MeshLayer();
		subLayer.addPolygonsToLayer( polyIds );
		this.subLayers.add( subLayer );
	}

	public void removePolygonsFromLayer( ArrayList<Integer> polyIds ) {
		for( int i = 0; i < polyIds.size(); i++ ) {
			polygonsRemoved.add( polyIds.get(i) );
		}
	}

	public void removePolygonsFromSubLayer( ArrayList<Integer> polyIds ) {
		MeshLayer subLayer = new MeshLayer();
		subLayer.removePolygonsFromLayer( polyIds );
		this.subLayers.add( subLayer );
	}

	public void removeVertexFromLayer( Vertex vertex ) {
		verticesRemoved.add( vertex );
	}

	public void removeVertexFromSubLayer( Vertex vertex ) {
		MeshLayer subLayer = new MeshLayer();
		subLayer.removeVertexFromLayer( vertex );
		this.subLayers.add( subLayer );
	}

	public void removeVertexFromLastSubLayer( Vertex vertex ) {
		this.subLayers.get( this.subLayers.size() - 1 ).
			removeVertexFromLayer( vertex );
	}

}
