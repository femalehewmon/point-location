// Global and file-global constants
NS ="http://www.w3.org/2000/svg";
POINT_RAD = 10;
CANVAS_WIDTH = 1200;
CANVAS_HEIGHT = 800;

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

var PolygonCreationView = function(svg) {
    this.svg = svg;
    this.points = new Array();
    this.edges = new Array();

    this.isComplete = false;
    this.tryPoint = true;

    this.finishPolygon = function(){
        console.log("Finish polygon");
        this.isComplete = true;
        this.tryPoint = false;
        this.addEdge(this.points[this.points.length - 1], this.points[0]);
        return this;
    }

    this.addEdge = function(p1, p2){
        var newEdge = new Edge(p1, p2);
        this.edges.push(newEdge);
        var element = document.createElementNS(NS, "line");
        element.setAttribute("x1", newEdge.x1);
        element.setAttribute("y1", newEdge.y1);
        element.setAttribute("x2", newEdge.x2);
        element.setAttribute("y2", newEdge.y2);
        element.setAttribute("stroke", newEdge.background);
        this.svg.appendChild(element);
        return this;
    }

    this.addPoint = function(x, y){
        if(!this.isComplete){
            var newPoint = null;
            if(this.points.length > 0){
                var xdiff = Math.abs(this.points[0].x - x);
                var ydiff = Math.abs(this.points[0].y - y);
                if(xdiff <= 5 && ydiff <= 5) {
                    this.finishPolygon();
                } else {
                    newPoint = new Point(x, y);
                    this.addEdge(
                        this.points[this.points.length - 1], newPoint);
                }
            } else{
                newPoint = new Point(x, y);
            }
            if(newPoint){
                console.log("New point " + x + " " + y);
                this.points.push(newPoint);
                var element = document.createElementNS(NS, "circle");
                element.setAttribute("cx", newPoint.x);
                element.setAttribute("cy", newPoint.y);
                element.setAttribute("fill", newPoint.background);
                element.setAttribute("r", POINT_RAD);
                this.svg.appendChild(element);
            }
        }
        return this;
    }

    var clickCB = function() {
        this.addPoint(event.clientX, event.clientY);
    }
    this.svg.addEventListener("click", clickCB.bind(this));

}

function init() {
    console.log("INIT");
    svg = document.createElementNS(NS, "svg");
    svg.setAttribute("width", CANVAS_WIDTH);
    svg.setAttribute("height", CANVAS_HEIGHT);
    document.body.appendChild(svg);

    var polyView = new PolygonCreationView(svg);

    window.requestAnimationFrame(draw);
}

function draw(){
    window.requestAnimationFrame(draw);
}
