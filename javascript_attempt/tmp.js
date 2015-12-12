// Global and file-global constants
NS ="http://www.w3.org/2000/svg";
POINT_RAD = 10;

var currentView = null;

var Point = function(x, y, rad, background, highlight) {
    this.x = x;
    this.y = y;
    this.rad = rad;
    this.background = background || "rgb(0, 0, 0)";
    this.highlight = highlight || "rgb(0, 0, 0)";
}

var Edge = function(p1, p2, background, highlight) {
    this.x1 = p1.x;
    this.y1 = p1.y;
    this.x2 = p2.x;
    this.y2 = p2.y;
    this.background = background || "rgb(0, 0, 0)";
    this.highlight = highlight || "rgb(0, 0, 0)";
}

var PolygonCreationView = function(x, y, w, h) {
    this.base = SVGView;
    this.base(x, y, w, h);

    this.points = new Array();
    this.edges = new Array();

    this.isComplete = false;
    this.tryPoint = true;

    this.finishPolygon() {
        this.isComplete = true;
        this.tryPoint = false;
        addEdge(points[points.length - 1], points[0]);
    }

    this.addEdge = new function(p1, p2){
        edges.add(new Edge(p1, p2));
    }

    this.addPoint = function(){
        var newPoint = null;
        if(!isComplete){
            if(points.length > 0){
                if(Math.abs(points[0].x - x <= 3) &&
                    Math.abs(poitns[0].y - y <=3)){
                    finishPolygon();
                } else {
                    newPoint = new Point(x, y);
                    addEdge(points[points.length - 2], newPoint);
                }
            } else{
                newPoint = new Point(x, y);
            }
        }
        if(newPoint){
            points.add(newPoint);
            var element = document.createElementNS(NS, "circle");
            element.setAttribute("fill", newPoint.background);
            element.setAttribute("r", POINT_RAD);
            this.svg.appendChild(element);
        }
    }

    this.setCB = function(){
        var clickCB = function() {
            this.polygon.addPoint(event.clientX, event.clientY);
        }
        this.svg.addEventListener("click", clickCB.bind(this));
    }
}

var SVGView = function(x, y, w, h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.svg = document.createElementNS(NS, "svg");
    this.svg.setAttribute("width", w);
    this.svg.setAttribute("height",h);
}

function init() {
    var polyView = new PolygonCreationView(0, 0, 500, 500);
    currentView = polyView;
    window.requestAnimationFrame(draw);
}

function draw(){
    if(currentView){
        window.requestAnimationFrame(draw);
    }
}
