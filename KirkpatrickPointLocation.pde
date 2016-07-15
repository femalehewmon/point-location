final boolean DEMO = true;
final boolean DEBUG = false;

// Global variables
int unique_poly_id = 100;

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
PolygonCreationView pcreateView;
KirkpatrickMeshView kpView;
LayeredGraphView graphView;
PointLocationView plocateView;

// Float.X_INFINITY throwing error, so self define
POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

void setup() {
	//size($(window).width() - 100, $(window).height() - 100); // get browser window size
	size( 1024, 768 ); // get browser window size

	sceneControl = new SceneController();
	compGeoHelper = new CompGeoHelper();

	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);

	// create views
	pcreateView = new PolygonCreationView(0, 0, width, height);
	kpView = new KirkpatrickMeshView(0, 0, width/2.0, height);
	graphView = new LayeredGraphView(width/2.0, 0, width, height);
	plocateView = new PointLocationView(0, 0, width/2.0, height);
	pcreateView.visible = true;
	kpView.visible = false;
	graphView.visible = false;
	plocateView.visible = false;
}

void draw() {
	background(245, 245, 245);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( DEMO ) {
				pcreateView.demo();
			}
			if ( pcreateView.finalized ) {
				// set polygon to calculate movement required to center in view
				kpView.setPolygon( pcreateView.polygon );
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CENTER_AND_RESIZE_POLYGON:
			if ( !sceneControl.sceneReady ) {
				pcreateView.polygon.animateMove(
						kpView.xPosToMovePoly, kpView.yPosToMovePoly,
						sceneControl.SCENE_DURATION );
				pcreateView.polygon.animateScale( kpView.ratioToScalePoly,
						sceneControl.SCENE_DURATION );
			}
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CREATE_MESH:
			if ( !sceneControl.sceneReady ) {
				Mesh mesh = compGeoHelper.createKirkpatrickDataStructure(
						pcreateView.polygon, kpView.outerTri);
				kpView.setMesh( mesh );
				graphView.setMesh( mesh );
				plocateView.setPolygon( pcreateView.polygon );
				plocateView.setMesh( kpView.mesh, graphView.mesh );
			}
			if ( sceneControl.update() ) {
				sceneControl.nextScene();
			}
		case sceneControl.TRIANGULATE_POLY:
			if ( !sceneControl.sceneReady ) {
				pcreateView.visible = false;
				kpView.visible = true;
				graphView.visible = true;
				graphView.nextLevel();

				kpView.drawPoly = false;
				kpView.drawPolyTris = true;
				kpView.drawOuterTri = false;
			}

			if ( sceneControl.update() ) {
				sceneControl.nextScene();
			}
			break;
		case sceneControl.SURROUND_POLY_WITH_OUTER_TRI:
			kpView.drawOuterTri = true;
			if ( sceneControl.update() ) {
				kpView.drawPoly = false;
				kpView.drawPolyTris = false;
				kpView.drawOuterTri = true;
				kpView.outerTri.cFill = color(200, 200, 200);
				graphView.nextLevel();
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCT:
			kpView.drawLayers = true;
			if ( sceneControl.update() ) {
				if ( kpView.nextLevel() ) {
					graphView.nextLevel();
					// reset scene for next level
					sceneControl.reset();
				} else {
					// if no levels remain in either view, go to next scene
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.POINT_LOCATION:
			if ( !sceneControl.sceneReady ) {
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = true;
			}

			if ( plocateView.pointSelected != null ) {
				if ( sceneControl.update() ) {
					if ( plocateView.nextLevel() ) {
						sceneControl.reset();
					} else {
						sceneControl.nextScene();
					}
				}
			}
			break;
		case sceneControl.DONE:
			break;
	}

	if (plocateView.visible) {
		plocateView.render();
	}
	if (pcreateView.visible) {
		pcreateView.render();
	}
	if (kpView.visible) {
		kpView.render();
	}
	if (graphView.visible) {
		graphView.render();
	}

	messages.clear();

	if (graphView.visible) {
		graphView.mouseUpdate();
	}
	if (kpView.visible) {
		kpView.mouseUpdate();
	}
	if (plocateView.visible) {
		plocateView.mouseUpdate();
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
				if ( !DEMO && !pcreateView.finalized ) {
					pcreateView.addPoint( mouseX, mouseY );
				}
				break;
			case sceneControl.POINT_LOCATION:
				plocateView.evaluatePoint( mouseX, mouseY );
				break;
		}
	}
}

