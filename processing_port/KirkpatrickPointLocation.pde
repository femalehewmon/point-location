
//ArrayList<poly2tri.Point> polygon;
Polygon test;
LayeredGraph lgraph;

void setup() {
	size($(window).width(), $(window).height());
	//polygon = new ArrayList<poly2tri.Point>();
	//polygon.add(new poly2tri.Point(24, 25));

	test = new Polygon("test");
	test.addPoint(10, 10);
	test.addPoint(20, 10);
	test.addPoint(20, 20);
	test.addPoint(10, 20);

	lgraph = new LayeredGraph(1, 0, 0, width/2, height/2);
	lgraph.addShape(0, test);
}

void draw() {
	background(255, 255, 0);
	//test.render();
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
