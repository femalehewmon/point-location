
//ArrayList<poly2tri.Point> polygon;
//polygon = new ArrayList<poly2tri.Point>();
//polygon.add(new poly2tri.Point(24, 25));

LayeredGraph lgraph;

POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

void setup() {
	size($(window).width(), $(window).height());

	Polygon test = new Polygon("test");
	test.addPoint(width/4, height/4);
	test.addPoint(width/2, height/4);
	test.addPoint(width/2, height/2);
	test.addPoint(width/4, height/2);

	lgraph = new LayeredGraph(2, 0, 0, width/2, height/2);
	lgraph.addShape(0, test);
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
