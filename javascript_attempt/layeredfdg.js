// Global and file-global constants

SPRING_CONST = 1;
COULOMBS_CONST = 50;
TIME_STEP = 0.0002;

levelBounds = {};
function applyCoulombs(node1, node2cx, node2cy){
    var dx = node1.cx - node2cx;
    var dy = node1.cy - node2cy;

    var dist = Math.sqrt(dx*dx + dy*dy) + 0.0001;
    if(dist > 0){
        var fx = COULOMBS_CONST * dx / (dist*dist); 
        var fy = COULOMBS_CONST * dy / (dist*dist);

        node1.addForces(fx, fy);
    }
}

function applyHookes(node1, node2, edge){
    var dx = node1.cx - node2.cx;
    var dy = node1.cy - node2.cy;

    var dist = Math.sqrt(dx*dx + dy*dy);
    var slx = edge.length * dx / dist;
    var sly = edge.length * dy / dist;
    var fx = SPRING_CONST * (dx - slx);
    var fy = SPRING_CONST * (dy - sly);
    if(node1.x < node2.x){
        fx = fx*-1;
        fy = fy*-1;
    }
    node1.addForces(fx, fy);
    node2.addForces(-1*fx, -1*fy);
}

function applyBounds(node1){
    bounds = levelBounds[node1.level];
    //left
    //applyCoulombs(node1, bounds[0], node1.cy); 
    //right
    //applyCoulombs(node1, bounds[2], node1.cy); 
    //top
    //applyCoulombs(node1, node1.cx, bounds[1]); 
    //bottom
    //applyCoulombs(node1, node1.cx, bounds[3]); 
}

var FDGNode = function(nodeElement, level) {
    this.nodeElement = nodeElement;

    this.id = nodeElement.id;
    this.level = level;

    this.points = nodeElement.points;
    this.centroid = getCentroid(nodeElement.points);
    this.cx = this.centroid[0];
    this.cy = this.centroid[1];

    //------- force properties -------
    this.xForce = 0;
    this.yForce = 0;
    this.xVel = 0;
    this.yVel = 0;
    this.mass = 10;
    //------- search properties -------
    this.scolor = WHITE;
    this.depth = Infinity;
    this.pparent = null;

    this.addForces = function(xForce, yForce){
        this.xForce += xForce;
        this.yForce += yForce;
    }
    
    this.updatePosition = function(){
        var bounds = levelBounds[this.level];
        var ax = this.xForce / this.mass;
        var ay = this.yForce / this.mass;

        this.xVel += ax * TIME_STEP;
        this.yVel += ay * TIME_STEP;
        this.xVel *= 0.9; //damping
        this.yVel *= 0.9; //damping

        var cxpos = this.cx + this.xVel*TIME_STEP +
            (0.5 * ax * TIME_STEP * TIME_STEP);
        var cxpos = this.cy + this.yVel*TIME_STEP +
            (0.5 * ay * TIME_STEP * TIME_STEP);

        if(this.cxpos < bounds[0] || this.cxpos > bounds[2]){
            this.xVel *= -1;
        }
        if(this.cypos < bounds[1] || this.cypos > bounds[3]){
            this.yVel *= -1;
        }

        this.cx += this.xVel*TIME_STEP +
            (0.5 * ax * TIME_STEP * TIME_STEP);
        this.cy += this.yVel*TIME_STEP +
            (0.5 * ay * TIME_STEP * TIME_STEP);

        this.moveNode(this.cx, this.cy);
    }

    this.moveNode = function(cxNew, cyNew){
        var xOffset = cxNew - this.centroid[0]; 
        var yOffset = cyNew - this.centroid[1];
        var newPoints = 
             (this.points[0].x + xOffset) 
             + "," + (this.points[0].y + yOffset) 
             + " " +
             (this.points[1].x + xOffset) 
             + "," + (this.points[1].y + yOffset) 
             + " " +
             (this.points[2].x + xOffset) 
             + "," + (this.points[2].y + yOffset);

        this.nodeElement.setAttribute("points", newPoints);
        this.points = this.nodeElement.points;
        this.centroid = getCentroid(this.points);
        this.cx = this.centroid[0];
        this.cy = this.centroid[1];
    }

    this.hide = function(){
        this.nodeElement.setAttribute("visibility", "hidden");
    }

    this.show = function(){
        this.nodeElement.setAttribute("visibility", "visible");
    }

    this.hide();
}

var FDGEdge = function(edgeElement, startNodeId, endNodeId, length) {
    this.startNode = startNodeId;
    this.endNode = endNodeId;

    this.length = length;

    this.edgeElement = edgeElement;

    this.updatePosition = function(sNode, eNode){
        var edgePoints =
            sNode.cx + "," + sNode.cy + " " +
            eNode.cx + "," + eNode.cy;

        this.edgeElement.setAttribute("points", edgePoints);
    }

    this.hide = function(){
        this.edgeElement.setAttribute("visibility", "hidden");
    }

    this.show = function(){
        this.edgeElement.setAttribute("visibility", "visible");
    }

    this.hide();
}

var LayeredFDG = function() {
    DEFAULT_LENGTH = 10;
    WHITE = "white";
    GREY = "grey";
    BLACK = "black";

    this.maxLevel = 0;

    this.adjList = {};   // point_id:[point_id]
    this.levels = {};    // level:point_id
    this.nodes = {};    // point_id:drawable

    this.render = function(renderLevel){
        if(renderLevel === undefined || renderLevel === null){
            console.log("!!!!!!!NO RENDER LEVEL!!!!!!!!");
            renderLevel = this.maxLevel;
        }
        for(var key in this.levels){
            if(key < renderLevel){
                for(var nodeId in this.levels[key]){
                    this.nodes[this.levels[key][nodeId]].show();
                }
            } else{
                for(var nodeId in this.levels[key]){
                    this.nodes[this.levels[key][nodeId]].hide();
                }
            } 
        }
        
        for(var node1 in this.adjList){
            for(var node2 in this.adjList[node1]){
                var currEdge = this.adjList[node1][node2];
                applyHookes(
                        this.nodes[node1], 
                        this.nodes[currEdge.endNode],
                        currEdge);
            }
        }
        
        for(var l in this.levels){
            for(var id in this.levels[l]){
                for(var id2 in this.levels[l]){
                    if(id != id2){
                        applyCoulombs(
                                this.nodes[this.levels[l][id]],
                               this.nodes[this.levels[l][id2]].cx,
                               this.nodes[this.levels[l][id2]].cy
                                );
                    }
                }
            } 
        }
        


        for(var i in this.nodes){
            applyBounds(this.nodes[i]);
            this.nodes[i].updatePosition();
        }

        for(var key in this.adjList){
            for(var edge in this.adjList[key]){
                var currEdge = this.adjList[key][edge];
                currEdge.updatePosition(this.nodes[currEdge.startNode],
                        this.nodes[currEdge.endNode]);
            }
        }
    }


    this.getBounds = function(level){
        height = FDG_CANVAS_HEIGHT - MARGIN*2; 
        height_per_level = height/this.maxLevel;

        leftB = MARGIN;
        rightB = CANVAS_WIDTH/2 - MARGIN;
        bottomB = FDG_CANVAS_HEIGHT - MARGIN 
            - height_per_level*level;
        topB = FDG_CANVAS_HEIGHT - MARGIN 
            - height_per_level*(level+1);

        bounds = [leftB, topB, rightB, bottomB, 
               rightB-leftB, bottomB-topB];
        return bounds;
    }

    this.addKPTri = function(tri, level){
        bounds = this.getBounds(level);

        var xOffset = bounds[4]/2 - tri.centroid[0]; 
        var yOffset = bounds[1] + bounds[5]/2 - tri.centroid[1];

        var v1x = tri.v1.x;
        var v1y = tri.v1.y;
        var v2x = tri.v2.x;
        var v2y = tri.v2.y;
        var v3x = tri.v3.x;
        var v3y = tri.v3.y;
        var boundsMargin = bounds[5]/4;

        if(tri.height > bounds[5]){
            scaleRatio = (bounds[5] - boundsMargin)/tri.height;
            v1x = tri.centroid[0] + 
                (v1x-tri.centroid[0])*scaleRatio; 
            v2x = tri.centroid[0] + 
                (v2x-tri.centroid[0])*scaleRatio; 
            v3x = tri.centroid[0] + 
                (v3x-tri.centroid[0])*scaleRatio; 
            v1y = tri.centroid[1] + 
                (v1y-tri.centroid[1])*scaleRatio; 
            v2y = tri.centroid[1] + 
                (v2y-tri.centroid[1])*scaleRatio; 
            v3y = tri.centroid[1] + 
                (v3y-tri.centroid[1])*scaleRatio; 
        }

        var points = 
             (v1x + xOffset) + "," + (v1y + yOffset) + " " +
             (v2x + xOffset) + "," + (v2y + yOffset) + " " +
             (v3x + xOffset) + "," + (v3y + yOffset);

        var triFDG = document.createElementNS(NS, "polygon");
        triFDG.setAttribute("id", tri.id);
        triFDG.setAttribute("points", points);
        triFDG.setAttribute("fill-opacity", "0");
        triFDG.setAttribute("stroke", "rgb(0,0,0)");
        triFDG.setAttribute("class","draggable");
        svgFDG.appendChild(triFDG);

        this.addNode(triFDG, level);
    }

    this.addNode = function(node, level){
        if(!(node.id in this.nodes)){
            if(!(level in this.levels)){
                this.levels[level] = new Array();
            }
            this.nodes[node.id] = new FDGNode(node,level);
            this.levels[level].push(node.id);
            this.adjList[node.id] = new Array();
        }
        return this.nodes[node.id];
    }

    // n1 == parent
    // n2 == child
    this.addEdge = function(p1, p2, undirected){
        var n1 = this.addNode(p1);
        var n2 = this.addNode(p2);

        var edgePoints =
            n1.cx + "," + n1.cy + " " +
            n2.cx + "," + n2.cy;

        var edgeSvg = document.createElementNS(NS, "polyline");
        edgeSvg.setAttribute("id", "edge: " + n1.id + "," + n2.id);
        edgeSvg.setAttribute("points", edgePoints);
        edgeSvg.setAttribute("stroke", "rgb(0,0,0)");
        svgFDG.appendChild(edgeSvg);

        this.adjList[n1.id].push(
                new FDGEdge(edgeSvg, n1.id, n2.id, DEFAULT_LENGTH));

        if(undirected){
            this.adjList[n2.id].push(
                    new FDGEdge(edgeSvg, n2.id, n1.id, DEFAULT_LENGTH));
        }
    }

    FDG_CANVAS_HEIGHT = CANVAS_HEIGHT;//*2;
    this.init = function() {
        console.log("Create force directed graph");
        svgFDG = document.createElementNS(NS, "svg");
        svgFDG.setAttribute("id", "svgFDG");
        //svgFDG.setAttribute("class","draggable");
        svgFDG.setAttribute("width", CANVAS_WIDTH);
        svgFDG.setAttribute("height", FDG_CANVAS_HEIGHT);
        document.body.appendChild(svgFDG);
    }

}

function randomColor(){
    var r = Math.floor(Math.random() * 255);
    var g = Math.floor(Math.random() * 255);
    var b = Math.floor(Math.random() * 255);
    return "rgb("+r+", "+g+", "+b+")";
}


function loadNodes(kptTris, maxDepth){
    fdg.maxLevel = maxDepth;

    // remove all elements from svg
    while(svgFDG.firstChild){
        svgFDG.removeChild(svgFDG.firstChild);
    }

    // create bounding boxes
    for(var i=0; i < maxDepth; i++){
        bounds = fdg.getBounds(i);
        if(!(i in levelBounds)){
            levelBounds[i] = bounds;
        }
        var elem = document.createElementNS(NS, "rect");
        elem.setAttribute("id", "level:"+i);
        elem.setAttribute("x", bounds[0]);
        elem.setAttribute("y", bounds[1]);
        elem.setAttribute("width", bounds[4]);
        elem.setAttribute("height", bounds[5]);
        elem.setAttribute("fill-opacity", "0.5");
        elem.setAttribute("fill", randomColor());
        svgFDG.appendChild(elem);
    }

    for(var currDepth=0; currDepth < maxDepth; currDepth++){
        childNodes = new Array();
        parentNodes = new Array();
        for(var key in kptTris){
            if(kptTris[key].endDepth === currDepth){
                childNodes.push(kptTris[key]);
            }
            if(kptTris[key].startDepth === currDepth){
                parentNodes.push(kptTris[key]);
                fdg.addKPTri(kptTris[key], currDepth);
            }
        }
        for(var child in childNodes){
            for(var par in parentNodes){
               fdg.addEdge(parentNodes[par], childNodes[child]); 
            }
        }
    }
}

function draw(){
    window.requestAnimationFrame(draw);
}


function tester(){


}

