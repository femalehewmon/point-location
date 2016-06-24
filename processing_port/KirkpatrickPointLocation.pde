
Polygon poly = null;
final boolean DEMO = false;

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
LayeredMeshView lmesh;
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
	lgraph = new LayeredGraphView(0, 0, width/2, height);
	lmesh = new LayeredMeshView(width/2, 0, width, height/2);
	pcreate.visible = true;
	lgraph.visible = false;
	lmesh.visible = false;
}

void draw() {
	background(255, 255, 0);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( DEMO && !pcreate.finalized ) {
				pcreate.demo();
				sceneControl.nextScene();
			}
			break;
		case sceneControl.CENTER_AND_RESIZE_POLYGON:
			sceneControl.update();
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCT:
			// create outer triangle

			LayeredMesh kpDataStruct =
				createKirkpatrickDataStructure( poly, outerTri);
			lmesh.setLayeredMesh( kpDataStruct );

			sceneControl.update();
			break;
		case sceneControl.ANIMATE_DATA_STRUCT_CREATION:

			break;
	}

	if (pcreate.visible) {
		pcreate.render();
	}
	if (lgraph.visible) {
		lgraph.render();
	}
	if (lmesh.visible) {
		lmesh.render();
	}

	messages.clear();

	if (lgraph.visible) {
		lgraph.mouseUpdate();
	}
	if (lmesh.visible) {
		lmesh.mouseUpdate();
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

