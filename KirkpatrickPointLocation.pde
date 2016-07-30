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

	// set size of visualization area with a fixed aspect ratio
	float border = $("#visualization").height() * 0.05;
	float aspectRatio = 16.0 / 9.0;
	float wtmp = $("#visualization").width() - border;
	float htmp = wtmp / aspectRatio;
	wtmp = htmp * aspectRatio;
	size(wtmp, htmp);

	// initialize global helper classes
	sceneControl = new SceneController();
	compGeoHelper = new CompGeoHelper();

	// initialize mouse interaction helpers
	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);

	// create views
	float padding = border/2.0;
	float xPad = width-padding;
	float yPad = height-padding;
	pcreateView = new PolygonCreationView(padding, padding, xPad, yPad);
	kpView = new KirkpatrickMeshView(padding, padding, width/2.0, yPad);
	graphView = new LayeredGraphView(width/2.0, padding, width-padding, yPad);
	plocateView = new PointLocationView(padding, padding, width-padding, yPad);

	pcreateView.visible = true;
	kpView.visible = false;
	graphView.visible = false;
	plocateView.visible = false;
}

void setText(String text) {
	// set directly to html
	$("#explanation-text").text(text);
}

void updateAnimationSpeed(String rate) {
	sceneControl.updateSceneDuration(float(rate));
}

void resetAnimation() {
	sceneControl.restart();
}

void startDemo() {
	pcreateView.demo();
}

void draw() {
	background(245, 245, 245);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( !sceneControl.sceneReady ) {
				// reset poly creation view if first time entering scene
				pcreateView.visible = true;
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = false;

				pcreateView.reset();

				if ( DEMO ) {
					pcreateView.demo();
				}
				sceneControl.update();
			}
			// do not update scene until polygon is finalized
			if ( pcreateView.polygon.finalized ) {
				// view will now show polygon centering and scaling as setup
				if(!pcreateView.update() && sceneControl.update()) {
					LayeredMesh kpDataStruct =
						compGeoHelper.createKirkpatrickDataStructure(
								pcreateView.polygon, pcreateView.outerTri);
					kpView.setMesh(kpDataStruct,
							pcreateView.polygon,
							pcreateView.outerTri);
					graphView.setMesh(kpDataStruct);
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.SETUP_KIRKPATRICK_DATA_STRUCTURE:
			if ( !sceneControl.sceneReady ) {
				pcreateView.visible = false;
				kpView.visible = true;
				graphView.visible = false;
				plocateView.visible = false;

				kpView.reset();
				sceneControl.updateOnKeyPress();
				kpView.update();
			}
			if ( sceneControl.update() ) {
				kpView.update();
				if ( kpView.initialized ) {
					sceneControl.nextScene();
				} else {
					sceneControl.updateOnKeyPress();
				}
			}
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCTURE:
			if ( !sceneControl.sceneReady ) {
				pcreateView.visible = false;
				kpView.visible = true;
				graphView.visible = true;
				plocateView.visible = false;
				graphView.reset();
			}

			if ( sceneControl.update() ) {
				boolean finalized = kpView.update();
				finalized = graphView.update() || finalized;
				if ( finalized) {
					sceneControl.reset();
				} else {
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.POINT_LOCATION:
			if ( !sceneControl.sceneReady ) {
				pcreateView.visible = false;
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = true;

				plocateView.reset();
				plocateView.setMesh( kpView.mesh, graphView.mesh,
						pcreateView.polygon );
				sceneControl.update();
			}

			if( plocateView.pointSelected != null ) {
				if ( sceneControl.update() ) {
					if ( plocateView.finalized ) {
						plocateView.reset();
					}
					plocateView.update();
					sceneControl.reset();
				}
			}
			break;
	}

	pcreateView.render();
	plocateView.render();
	kpView.render();
	graphView.render();

	messages.clear();

	graphView.mouseUpdate();
	kpView.mouseUpdate();
	plocateView.mouseUpdate();
}

void mousePressed( ) {
	if (mouseButton == LEFT) {
		pcreateView.onMousePress();
		plocateView.onMousePress();
	}
}

void browserKeyPressed() {
	sceneControl.onKeyPress();
}

