//ArrayList<poly2tri.Point> polygon;
//polygon = new ArrayList<poly2tri.Point>();
//polygon.add(new poly2tri.Point(24, 25));

int mode = 0;
int MODE_CREATE_POLYGON = 0;
int MODE_CREATE_DATA_STRUCTURE = 1;

int unique_poly_id = 0;

// Helper global classes
CompGeoHelper compGeoHelper;

// variables for interaction with polygons (hover effect)
ArrayList<Message> messages;
PGraphics pickbuffer;

// views
LayeredMeshView lmesh;
LayeredGraphView lgraph;

// modes for which view to enable

// Float.X_INFINITY throwing error, so self define
POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

MSG_TRIANGLE = "MSG_TRIANGLE";
class Message {
	String k;
	String v;
}

void setup() {
	size($(window).width(), $(window).height()); // get browser window size

	compGeoHelper = new CompGeoHelper();

	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);

	// create views
	lgraph = new LayeredGraphView(2, 0, 0, width/2, height);
	lmesh = new LayeredMeshView(width/2, 0, width, height/2);

	// triangulation test
	Polygon test = createPoly();
	console.log(test);
	test.addPoint(width/4+10, height/4+10);
	test.addPoint(width/2-10, height/4+10);
	test.addPoint(width/2-10, height/2-10);
	test.addPoint(width/4+10, height/2-10);
	Polygon test2 = createPoly();
	test2.addPoint(width/4+10, height/4+10);
	test2.addPoint(width/2-10, height/4+10);
	test2.addPoint(width/2-10, height/2-10);
	test2.addPoint(width/4+10, height/2-10);
	ArrayList<Polygon> tris = test2.triangulate();
	Mesh m = new Mesh();
	m.addTrianglesToMesh(tris);

	// graham scan test
	ArrayList<Vertex> vertices = new ArrayList<Vertex>();
	vertices.add(new Vertex(1, 1));
	vertices.add(new Vertex(1, 5));
	vertices.add(new Vertex(5, 5));
	vertices.add(new Vertex(0, 3));
	vertices.add(new Vertex(2, 2));
	vertices.add(new Vertex(3, 3));
	vertices.add(new Vertex(4, 4));
	Polygon chull = compGeoHelper.getConvexHull( vertices );

	// add shapes to views as test
	lgraph.addShape(0, test);
	lgraph.addShape(1, test2);
	lgraph.addShape(1, tris.get(0));
	lgraph.addShape(1, tris.get(1));
	lgraph.addShape(0, chull);
}

void setupKirkpatrickDataStructure() {


}

void draw() {
	background(255, 255, 0);
	pickbuffer.background(255);

	lgraph.render();
	lmesh.render();

	messages.clear();

	if (lgraph.visible) {
		lgraph.mouseUpdate();
	}

}

Polygon createPoly() {
	console.log("creating poly");
	unique_poly_id++;
	return new Polygon(unique_poly_id);
}

