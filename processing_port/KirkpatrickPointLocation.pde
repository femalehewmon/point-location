
//ArrayList<poly2tri.Point> polygon;
//polygon = new ArrayList<poly2tri.Point>();
//polygon.add(new poly2tri.Point(24, 25));

LayeredGraph lgraph;

POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

void setup() {
	size($(window).width(), $(window).height());

	Polygon test = new Polygon("test");
	test.addPoint(width/4+10, height/4+10);
	test.addPoint(width/2-10, height/4+10);
	test.addPoint(width/2-10, height/2-10);
	test.addPoint(width/4+10, height/2-10);
	Polygon test2 = new Polygon("test2");
	test2.addPoint(width/4+10, height/4+10);
	test2.addPoint(width/2-10, height/4+10);
	test2.addPoint(width/2-10, height/2-10);
	test2.addPoint(width/4+10, height/2-10);

	lgraph = new LayeredGraph(2, 0, 0, width/2, height/2);
	lgraph.addShape(0, test);
	lgraph.addShape(0, test2);
}

void draw() {
	background(255, 255, 0);
	lgraph.render();
}

/*
void onResetClick() {
	mode = Mode.POLYGON_CREATION;
	polygon = null;
}

void loadDemo(){
	polygon.clear();

}

*/
