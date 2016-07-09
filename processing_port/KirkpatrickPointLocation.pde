final boolean DEMO = true;

// Global variables
int unique_poly_id = 0;

// Helper global classes
SceneController sceneControl;
CompGeoHelper compGeoHelper;

// Variables for interaction with polygons (hover effect)
PGraphics pickbuffer;
ArrayList<Message> messages;
MSG_TRIANGLE = "MSG_TRIANGLE";
class Message {
	String k;
	String v;
}

// Views
PolygonCreationView pcreate;
KirkpatrickMeshView kpView;
LayeredGraphView lgraph;

// Float.X_INFINITY throwing error, so self define
POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

void setup() {
	//size($(window).width(), $(window).height()); // get browser window size
	size( 1024, 768 ); // get browser window size

	sceneControl = new SceneController();
	compGeoHelper = new CompGeoHelper();

	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);

	// create views
	pcreate = new PolygonCreationView(0, 0, width, height);
	//kpView = new KirkpatrickMeshView(0, 0, width/2.0, height);
	//lgraph = new LayeredGraphView(width/2.0, 0, width, height);
	kpView = new KirkpatrickMeshView(width/2.0, 0, width, height);
	lgraph = new LayeredGraphView(0, 0, width/2.0, height);
	pcreate.visible = true;
	lgraph.visible = false;
	kpView.visible = false;
}

void draw() {
	background(245, 245, 245);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( DEMO ) {
				pcreate.demoRect();
			}
			if ( pcreate.finalized ) {
				// set polygon to calculate movement required to center in view
				kpView.setPolygon( pcreate.polygon );
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CENTER_AND_RESIZE_POLYGON:
			pcreate.polygon.move(
					kpView.xPosToMovePoly, kpView.yPosToMovePoly,
					sceneControl.sceneRelativePercentComplete);
			pcreate.polygon.scale( kpView.ratioToScalePoly,
					sceneControl.scenePercentageStep );
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
				Mesh kpMesh = compGeoHelper.createKirkpatrickDataStructure(
						pcreate.polygon, kpView.outerTri);
				lgraph.setMesh( kpMesh );
				kpView.setMesh( kpMesh );
			}
			break;
		case sceneControl.TRIANGULATE_POLY:
			if ( !kpView.finalized ) {
				// create kp data structure based on newly positioned polygon
				kpView.finalizeView();
				lgraph.setLayerCount(kpView.mesh.layers.size());
				pcreate.visible = false;
				kpView.visible = true;
				lgraph.visible = true;
				lgraph.addShapes(0, kpView.getPolygonTris());
			}
			kpView.drawPoly = true;
			kpView.drawPolyTris = true;
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
				lgraph.addShapes(0, kpView.getOuterTris());
			}
			break;
		case sceneControl.SURROUND_POLY_WITH_OUTER_TRI:
			kpView.drawOuterTri = true;
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
				kpView.drawOuterTri = false;
			}
			break;
		case sceneControl.TRIANGULATE_OUTER_TRI:
			kpView.drawOuterTris = true;
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
				kpView.drawOuterTris = false;
				kpView.drawPoly = false;
				kpView.drawPolyTris = false;
			}
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCT:
			kpView.drawLayers = true;
			if ( sceneControl.update() ) {
				if ( kpView.nextLevel() ) {
					// reset scene for next level
					sceneControl.reset();
					lgraph.addShapes(kpView.layerToDraw, kpView.getLayerTris());
				} else {
					// if no levels remain, go to next scene
					kpView.drawLayers = false;
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.DONE:
			kpView.drawOuterTri = true;
			break;
	}

	if (pcreate.visible) {
		pcreate.render();
	}
	if (lgraph.visible) {
		lgraph.render();
	}
	if (kpView.visible) {
		kpView.render();
	}

	messages.clear();

	if (lgraph.visible) {
		lgraph.mouseUpdate();
	}
	if (kpView.visible) {
		kpView.mouseUpdate();
	}

}

Polygon createPoly() {
	console.log("creating poly");
	unique_poly_id++;
	return new Polygon(unique_poly_id);
}

void mousePressed( ) {
	if (mouseButton == LEFT) {
		switch( sceneControl.currScene ) {
			case sceneControl.CREATE_POLYGON:
			if ( !DEMO && !pcreate.finalized ) {
				pcreate.addPoint( mouseX, mouseY );
			}
			break;
		}
	}
}

