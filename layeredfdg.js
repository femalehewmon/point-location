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
        var center = getCentroid(this.nodeElement.points);
        var xOffset = cxNew - center[0]; 
        var yOffset = cyNew - center[1];
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
            renderLevel = this.maxLevel;
        }

        for(var key in this.levels){
            if(key < renderLevel){
                for(var nodeId in this.levels[key]){
                    this.nodes[this.levels[key][nodeId]].show();
                    if(this.levels[key][nodeId] in this.adjList){
                        for(var edge in this.adjList[key]){
                            this.adjList[key][edge].show();
                        }
                    }
                }
            } else{
                for(var nodeId in this.levels[key]){
                    this.nodes[this.levels[key][nodeId]].hide();
                }
            } 
        }
        /*
        
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
        */
    }


    this.getBounds = function(level){
        height = CANVAS_HEIGHT - MARGIN*2; 
        height_per_level = height/this.maxLevel;

        leftB = MARGIN;
        rightB = CANVAS_WIDTH - MARGIN;
        bottomB = CANVAS_HEIGHT - MARGIN 
            - height_per_level*level;
        topB = CANVAS_HEIGHT - MARGIN 
            - height_per_level*(level+1);

        bounds = [leftB, topB, rightB, bottomB, 
               rightB-leftB, bottomB-topB];
        if(!(level in levelBounds)){
            levelBounds[level] = bounds;
        }
        if(level > this.maxLevel){
            this.maxLevel = level;
        }
        return bounds;
    }

    this.addPolyTri = false;
    this.addPolyTri = function(tri){
       this.addPolyTri = true; 
       console.log("Adding polygon triangles", tri);
       this.addKPTri(tri, 0);
       this.addPolyTri = false; 
    }

    this.addOuterTri = false;
    this.addOuterTri = function(tri){
       this.addOuterTri = true; 
       console.log("Adding outer triangles", tri);
       this.addKPTri(tri, 0);
       this.addOuterTri = false; 
    }

    this.addKPTri = function(tri, level){
        if(!(tri.id in this.nodes)){
            console.log("Adding KPTri");
            var bounds = this.getBounds(level);
            /* 
            var xOffset = bounds[4]/2 - tri.centroid[0]; 
            var yOffset = bounds[1] + bounds[5]/2 - tri.centroid[1];
            */ 
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
                var points = 
                          (v1x) + "," + (v1y) + " " +
                          (v2x) + "," + (v2y) + " " +
                          (v3x) + "," + (v3y);
            }else{
            var points = 
                 tri.element.points[0].x + "," + 
                 tri.element.points[0].y + " " +
                 tri.element.points[1].x + "," + 
                 tri.element.points[1].y + " " +
                 tri.element.points[2].x + "," + 
                 tri.element.points[2].y + " ";
            }

            var fdgTriEl = document.createElementNS(NS, "polygon");
            fdgTriEl.setAttribute("id", tri.id);
            fdgTriEl.setAttribute("points", points);
            //fdgTriEl.setAttribute("fill-opacity", "0");
            fdgTriEl.setAttribute("fill", "white");
            fdgTriEl.setAttribute("stroke", "rgb(0,0,0)");
            fdgTriEl.setAttribute("class","draggable");
            svgFDG.appendChild(fdgTriEl);

            movePolygon(fdgTriEl, [bounds[0] + bounds[4]/2, 
                    bounds[1] + bounds[5]/2]); 
            var boundsMargin = bounds[5]/4;
            var scaleRatio = (bounds[5] - boundsMargin)/tri.height;
            //scalePolygon(fdgTriEl, scaleRatio);

            this.addNode(fdgTriEl, level);

            var kptTriEl = $("#tri-" + $(fdgTriEl).attr("id"));
            $(fdgTriEl).on("mouseover", function(){
                var friend = "#tri-" + $(this).attr("id");
                $(this).css({
                    "fill": "blue",
                    "fill-opacity": "1"
                });

                $(friend).css({
                    "fill": "blue",
                    "fill-opacity": "1"
                })
            });
            $(fdgTriEl).on("mouseleave", function(){
                var friend = "#tri-" + $(this).attr("id");
                $(this).css({
                    "fill": "white"
                });

                $(friend).css({
                    "fill": "white"
                })
            });

            $(kptTriEl).on("mouseover", function(){
                var friend = "#" + $(this).attr("id").split("-")[1];
                $(this).css({
                    "fill": "blue",
                    "fill-opacity": "1"
                });

                $(friend).css({
                    "fill": "blue",
                    "fill-opacity": "1"
                })
            });
            $(kptTriEl).on("mouseleave", function(){
                var friend = "#" + $(this).attr("id").split("-")[1];
                $(this).css({
                    "fill": "white"
                });

                $(friend).css({
                    "fill": "white"
                })
            });
        }
        return this.nodes[tri.id];
    }

    this.addNode = function(node, level){
        if(!(node.id in this.nodes)){
            if(!(level in this.levels)){
                this.levels[level] = new Array();
            }
            this.nodes[node.id] = new FDGNode(node,level);
            this.levels[level].push(node.id);
            this.adjList[node.id] = new Array();
            this.nodes[node.id].isPolyTri = this.addPolyTri;
            this.nodes[node.id].isOuterTri = this.addOuterTri;
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

    this.init = function() {
        console.log("Create force directed graph");
        svgFDG = document.createElementNS(NS, "svg");
        svgFDG.setAttribute("id", "svgFDG");
        //svgFDG.setAttribute("class","draggable");
        svgFDG.setAttribute("width", CANVAS_WIDTH);
        svgFDG.setAttribute("height", CANVAS_HEIGHT);
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
    console.log("Adding nodes ", kptTris);
    fdg.maxLevel = maxDepth;

    // remove all elements from svg
    while(svgFDG.firstChild){
        svgFDG.removeChild(svgFDG.firstChild);
    }

    // create bounding boxes
    for(var i=0; i < maxDepth; i++){
        bounds = fdg.getBounds(i);
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
                var fdgTriEl = fdg.addKPTri(kptTris[key], currDepth);

            }
        }
        for(var child in childNodes){
            for(var par in parentNodes){
               fdg.addEdge(parentNodes[par], childNodes[child]); 
            }
        }
    }

    // draw spaced out triangles in graph
    for(var i in fdg.levels){
        var numTris = fdg.levels[i].length;
        var bounds = levelBounds[i];
        var widthPerTri = bounds[4]/numTris;
        for(var j=0; j < numTris; j++){
            var currPoly = fdg.nodes[fdg.levels[i][j]];
            fdg.nodes[fdg.levels[i][j]].moveNode( 
                    widthPerTri*(j+1) - widthPerTri/2, currPoly.cy); 
        }
    }  
}
