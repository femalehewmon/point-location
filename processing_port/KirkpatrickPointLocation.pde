
Polygon poly = null;
boolean DEMO = false;

// Global variables
int mode = -1;
int MODE_CREATE_POLYGON = 0;
int MODE_CREATE_DATA_STRUCTURE_ANIMATION = 1;
int unique_poly_id = 0;

// Helper global classes
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
	size($(window).width(), $(window).height()); // get browser window size

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

	// set mode
	mode = MODE_CREATE_POLYGON;
}

void draw() {
	background(255, 255, 0);
	pickbuffer.background(255);

	switch( mode ) {
		case MODE_CREATE_POLYGON:
			if ( DEMO && !pcreate.finalized ) {
				pcreate.demo();
				//mode = MODE_CREATE_DATA_STRUCTURE_ANIMATION;
			}
			break;
		case MODE_CENTER_AND_RESIZE_POLYGON:
			break;
		case MODE_CREATE_DATA_STRUCTURE:
			// create outer triangle

			LayeredMesh kpDataStruct =
				createKirkpatrickDataStructure( poly, outerTri);
			lmesh.setLayeredMesh( kpDataStruct );

			mode = MODE_ANIMATE_DATA_STRUCTURE_CREATION;
			break;
		case MODE_ANIMATION_DATA_STRUCTURE_CREATION:

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
	console.log(mouseButton);
	if (mouseButton == LEFT) {
		switch( mode ) {
			case MODE_CREATE_POLYGON:
			if ( !DEMO && !pcreate.finalized ) {
				pcreate.addPoint( mouseX, mouseY );
			}
			break;
		}
	}
}

