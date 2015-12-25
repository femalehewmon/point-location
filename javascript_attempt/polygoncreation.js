// Global and file-global constants
POINT_RAD = 10;

var PolyPoint = function(x, y, rad, background, highlight) {
    this.x = x;
    this.y = y;
    this.rad = rad;
    this.background = background || "rgb(0, 0, 0)";
    this.highlight = highlight || "rgb(0, 0, 0)";
}

var PolyEdge = function(p1, p2, background, highlight) {
    this.x1 = p1.x;
    this.y1 = p1.y;
    this.x2 = p2.x;
    this.y2 = p2.y;
    this.background = background || "rgb(0, 0, 0)";
    this.highlight = highlight || "rgb(0, 0, 0)";
}

Poly = function(svg, callbackOnComplete) {
    this.svg = svg;
    this.points = new Array();
    this.edges = new Array();
    this.vertices = new Array();

    this.isComplete = false;
    this.tryPoint = true;

    this.callbackOnComplete = callbackOnComplete;

    this.finishPolygon = function(){
        console.log("Finish polygon");
        this.isComplete = true;
        this.tryPoint = false;
        this.addEdge(this.points[this.points.length - 1], this.points[0]);
        return this.callbackOnComplete(this.points);
    }

    this.addEdge = function(p1, p2){
        var newEdge = new PolyEdge(p1, p2);
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
                    newPoint = new PolyPoint(x, y);
                    this.addEdge(
                        this.points[this.points.length - 1], newPoint);
                }
            } else{
                newPoint = new PolyPoint(x, y);
            }
            if(newPoint){
                console.log("New point " + x + " " + y);
                this.points.push(newPoint);
                this.vertices.push([newPoint.x, newPoint.y]);
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

var getMaxPoints = function(vertices){
    var minX = Infinity;
    var minY = Infinity;
    var maxX = -Infinity;
    var maxY = -Infinity;
    for(var i = 0; i < vertices.length; i++){
        if(vertices[i].x < minX){
            minX = vertices[i].x;
        }
        if(vertices[i].y < minY){
            minY = vertices[i].y;
        }
        if(vertices[i].x > maxX){
            maxX = vertices[i].x;
        }
        if(vertices[i].y > maxY){
            maxY = vertices[i].y;
        }
    }
    returnVals = [minX, minY, maxX, maxY, maxX - minX, maxY - minY];
    console.log("Max points " + returnVals[4] + " " + returnVals[5]);
    return returnVals; 
}


var getCentroid = function(vertices){
    cx = 0;
    cy = 0;
    var sArea = 0;
    var x0 = 0;
    var y0 = 0;
    var x1 = 0;
    var y1 = 0;
    var a = 0;
    for(var i = 0; i < vertices.length - 1; i++){
       x0 = vertices[i].x; 
       y0 = vertices[i].y; 
       x1 = vertices[i+1].x; 
       y1 = vertices[i+1].y; 
       a = x0*y1 - x1*y0;
       sArea += a;
       cx += (x0 + x1)*a;
       cy += (y0 + y1)*a;
    }
    // final operation
    x0 = vertices[vertices.length - 1].x;
    y0 = vertices[vertices.length - 1].y;
    x1 = vertices[0].x;
    y1 = vertices[0].y;
    a = x0*y1 - x1*y0;
    sArea += a;
    cx += (x0 + x1)*a;
    cy += (y0 + y1)*a;

    sArea *= 0.5;
    cx /= (6*sArea);
    cy /= (6*sArea);
    console.log("Centroid: " + cx + " " + cy);
    return [cx, cy];
}

