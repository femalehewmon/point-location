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
                element.setAttribute("isFinished", false);
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
    return [cx, cy];
}

function movePolygon(polygon, newCenter){
    var oldCenter = getCentroid(polygon.points);
    var updatedPoints = "";
    for(var i=0; i < polygon.points.length; i++){
        // move point to center
        updatedPoints += 
                movePoint(
                        polygon.points[i].x, 
                        oldCenter[0], newCenter[0]) 
                + ", " 
                + movePoint(
                        polygon.points[i].y, 
                        oldCenter[1], newCenter[1])
                + " ";
    }
    polygon.setAttribute("points", updatedPoints);
}

function scalePolygon(polygon, scale){
    var center = getCentroid(polygon.points);
    updatedPoints = "";
    for(var i=0; i < polygon.points.length; i++){
        // keep point in center when scaling
        updatedPoints += 
                scalePoint(
                        polygon.points[i].x, 
                        center[0], scaleRatio) 
                + ", " 
                + scalePoint(
                        polygon.points[i].y, 
                        center[1], scaleRatio)
                + " ";
    }
    polygon.setAttribute("points", updatedPoints);
}

function movePoint(oldPos, oldCenter, newCenter){
    var centerOffset = oldCenter - oldPos; 
    return newCenter + centerOffset;
}

function scalePoint(oldPos, centerPos, scaleRatio){
    var newPos = centerPos + 
        (oldPos - centerPos)*scaleRatio; 
    return newPos;
}

function getConvexHull(points){
    var hull = new Array();
    var q = null;
    for(var i=0; i < points.length; i++){
        q = _nextHullPoint(points, points[i]);
        if(q !== hull[0]){
            hull.push(q);
        }
    }
    return hull;
}

function _nextHullPoint(points, p){
    var q = p;
    var t = null;
    var pq_dist = null; 
    var pr_dist = null;
    for(var r in points){
        t = _turn(p, q, points[r]);
        pr_dist = _dist(p, points[r]);
        pq_dist = _dist(p, q);
        if(t === TURN_RIGHT || t === TURN_NONE && pr_dist > pq_dist){
            q = points[r];
        }
    }
    return q;
}

TURN_LEFT = 1;
TURN_RIGHT = -1;
TURN_NONE = 0;
function _turn(p, q, r){
    var t = 0;
    var turn = (q[0] - p[0])*(r[1] - p[1]) - (r[0] - p[0])*(q[1] - p[1]);
    if(turn !== TURN_NONE){
        if(turn > 0){
            t = TURN_LEFT;
        } else if(turn < 0){
            t = TURN_RIGHT;
        }
    }
    return t;
}

function _dist(p, q){
    var dx = q[0] - p[0];
    var dy = q[1] - p[1];
    return dx * dx + dy * dy;
}

