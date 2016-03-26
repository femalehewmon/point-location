
//ArrayList<poly2tri.Point> polygon;
//polygon = new ArrayList<poly2tri.Point>();
//polygon.add(new poly2tri.Point(24, 25));

int unique_poly_id;
ArrayList<Message> messages;
PGraphics pickbuffer;
LayeredGraphView lgraph;

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

	unique_poly_id = 0;
	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);

	Polygon test = createPoly();
	test.addPoint(width/4+10, height/4+10);
	test.addPoint(width/2-10, height/4+10);
	test.addPoint(width/2-10, height/2-10);
	test.addPoint(width/4+10, height/2-10);
	Polygon test2 = createPoly();
	test2.addPoint(width/4+10, height/4+10);
	test2.addPoint(width/2-10, height/4+10);
	test2.addPoint(width/2-10, height/2-10);
	test2.addPoint(width/4+10, height/2-10);

	lgraph = new LayeredGraphView(2, 0, 0, width/2, height/2);
	lgraph.addShape(0, test);
	lgraph.addShape(1, test2);
}

void draw() {
	background(255, 255, 0);
	pickbuffer.background(255);

	lgraph.render();

	messages.clear();

	if (lgraph.visible) {
		lgraph.mouseUpdate();
	}

}

Polygon createPoly() {
	unique_poly_id++;
	return new Polygon(unique_poly_id);
}

