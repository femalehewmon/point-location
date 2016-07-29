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

void draw() {
	background(245, 245, 245);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( !sceneControl.sceneReady ) {
				setText(
						"Click anywhere to create an non-overlapping polygon");
			}
			if ( DEMO ) {
				pcreateView.demo();
				pcreateView.polygon.move(
						pcreateView.xCenter, pcreateView.yCenter);
				pcreateView.polygon.scale( Math.min(
						pcreateView.w / pcreateView.polygon.getWidth(),
						pcreateView.h / pcreateView.polygon.getHeight()));
			}
			if ( pcreateView.finalized ) {
				// set polygon to calculate movement required to center in view
				kpView.setPolygon( pcreateView.polygon );
				sceneControl.nextScene();
				setText( "Nice polygon!" );
			}
			break;
		case sceneControl.CENTER_AND_RESIZE_POLYGON:
			if ( !sceneControl.sceneReady ) {
				setText(
						"Let's center and resize it.");
			}
			if ( sceneControl.update() ) {
				pcreateView.polygon.move(
						kpView.xPosToMovePoly, kpView.yPosToMovePoly);
				pcreateView.polygon.scale( kpView.ratioToScalePoly );
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CREATE_MESH:
			if ( !sceneControl.sceneReady ) {
				setText(
						"That's better. We are now ready to start creating " +
						"our data structure");
			}
			if ( !sceneControl.sceneReady ) {
				Mesh mesh = compGeoHelper.createKirkpatrickDataStructure(
						pcreateView.polygon, kpView.outerTri);
				kpView.setMesh( mesh );
				graphView.setMesh( mesh );
			}

			sceneControl.update(true);
			break;
		case sceneControl.TRIANGULATE_POLY:
			if ( !sceneControl.sceneReady ) {
				setText( "Let's start by triangulating our polygon" );
				kpView.visible = true;
				graphView.visible = true;
				pcreateView.visible = false;

				kpView.update();
				kpView.update();
				graphView.update();
				graphView.update();
				setText( "That's a good start, but what about the " +
					   "area surrounding the polygon?"	);
				setText( "That's a good start, but what if a point " +
						"is placed outside of the bounds " +
					    "of the polygon itself? ");
				setText(
					   "What if we place a large outer triangle to completely " +
					   "surround our polygon? The triangle can be arbitrarily " +
					   "large to encompass the entire outer area that we are " +
					   " working in");
			}

			sceneControl.update(true);
			break;
		case sceneControl.SURROUND_POLY_WITH_OUTER_TRI:
			if ( !sceneControl.sceneReady ) {
				kpView.displayOuterTriangle();
			}

			sceneControl.update(true);
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCT:
			kpView.drawLayers = true;
			if ( sceneControl.update() ) {
				boolean finalLayer = !kpView.update();
				finalLayer = !graphView.update() || finalLayer;
				if ( !finalLayer ) {
					// reset scene for next level
					sceneControl.reset();
				} else {
					// if no levels remain in either view, go to next scene
					plocateView.setPolygon( kpView.polygon );
					plocateView.setMesh( kpView.mesh, graphView.mesh );
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.POINT_LOCATION:
			if ( !sceneControl.sceneReady ) {
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = true;
				setText(
						"Place a point anywhere inside the colored triangle");
			}

			if ( plocateView.pointSelected != null ) {
				setText(
						"We can now traverse our graph to determine " +
						"if the point is located inside our original polygon");
				if ( sceneControl.update() ) {
					if ( plocateView.nextLevel() ) {
						sceneControl.reset();
					} else {
						sceneControl.nextScene();
						sceneControl.sceneReady = false;
					}
				}
			}
			break;
		case sceneControl.DONE:
			break;
	}

	if (pcreateView.visible) {
		pcreateView.render();
	}
	if (plocateView.visible) {
		plocateView.render();
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

