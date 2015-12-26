// Global and file-global constants

SPRING_CONST = 1;
COULOMBS_CONST = 50000;

function applyHookes(node1, node2, edge){
}

var FDGNode = function(element) {
    this.element = element;
    this.id = element.id;

    this.centroid = getCentroid(element.points);
    this.cx = this.centroid[0];
    this.cy = this.centroid[1];

    //------- force properties -------
    this.xforce = 0;
    this.yforce = 0;
    //------- search properties -------
    this.scolor = WHITE;
    this.depth = Infinity;
    this.pparent = null;

    this.hide = function(){
        this.element.setAttribute("visibility", "hidden");
    }

    this.show = function(){
        this.element.setAttribute("visibility", "visible");
    }

    this.show();
}

var FDGEdge = function(endNodeId, length) {
    this.endNode = endNodeId;
    this.length = length;
}

var walkGraph = function(fdg, todo){
    // bfs
    var queue = [];
    if(fdg.nodes.length > 0){
       // reset graph
       for(point in fdg.nodes){
           point.scolor = WHITE;
           point.depth = Infinity;
           point.pparent = null;
           point.xforce = 0;
           point.yforce = 0;
       } 

        fdg.nodes[0].scolor = GREY;
        fdg.nodes[0].depth = 0;
        queue.push(this.nodes[0].id);
        while(queue.length > 0){
            uid = queue.shift();
            u = fdg.nodes[uid];
            for(vid in adjList[u]){
                v = fdg.nodes[vid];
                if(v.scolor == WHITE){
                    v.scolor = GREY;
                    v.depth = u.depth + 1;
                    v.pparent = vid;
                    queue.push(vid);
                }
            } 
            u.scolor = BLACK;
        }
    }
}

var LayeredFDG = function() {
    DEFAULT_LENGTH = 10;
    WHITE = "white";
    GREY = "grey";
    BLACK = "black";

    this.maxLevel = 0;

    this.adjList = {};   // point_id:[edges]
    this.levels = {};    // level:point_id
    this.nodes = {};    // point_id:drawable

    this.render = function(renderLevel){
        if(!renderLevel){
            renderLevel = this.maxLevel;
        }
        for(var key in this.levels){
            if(key < renderLevel){
                for(var nodeId in this.levels[key]){
                    this.nodes[nodeId].show();
                }
            } else{
                for(var nodeId in this.levels[key]){
                    this.nodes[nodeId].hide();
                }
            } 
        }
    }


    this.getBounds = function(level){
        height = FDG_CANVAS_HEIGHT - MARGIN*2; 
        height_per_level = height/this.maxLevel;

        leftB = MARGIN;
        rightB = CANVAS_WIDTH/2 - MARGIN;
        bottomB = FDG_CANVAS_HEIGHT - MARGIN - height_per_level*level;
        topB = FDG_CANVAS_HEIGHT - MARGIN - height_per_level*(level+1);

        bounds = [leftB, topB, rightB, bottomB, rightB-leftB, bottomB-topB];
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
            v1x = tri.centroid[0] + (v1x-tri.centroid[0])*scaleRatio; 
            v2x = tri.centroid[0] + (v2x-tri.centroid[0])*scaleRatio; 
            v3x = tri.centroid[0] + (v3x-tri.centroid[0])*scaleRatio; 
            v1y = tri.centroid[1] + (v1y-tri.centroid[1])*scaleRatio; 
            v2y = tri.centroid[1] + (v2y-tri.centroid[1])*scaleRatio; 
            v3y = tri.centroid[1] + (v3y-tri.centroid[1])*scaleRatio; 
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
        svgFDG.appendChild(triFDG);

        this.addNode(triFDG, level);
    }

    this.addNode = function(node, level){
        if(!(node.id in this.nodes)){
            if(!(level in this.levels)){
                this.levels[level] = new Array();
            }
            this.levels[level].push(node.id);
            this.adjList[node.id] = new Array();
            this.nodes[node.id] = new FDGNode(node);
        }
    }

    // p1 == parent
    // p2 == child
    this.addEdge = function(p1, p2, undirected){
        this.addNode(p1);
        this.addNode(p2);
        this.adjList[p1.id].push(new FDGEdge(p2.id, DEFAULT_LENGTH));
        if(undirected){
            this.adjList[p2.id].push(new FDGEdge(p1.id, DEFAULT_LENGTH));
        }
    }

    FDG_CANVAS_HEIGHT = CANVAS_HEIGHT*2;
    this.init = function() {
        console.log("Create force directed graph");
        svgFDG = document.createElementNS(NS, "svg");
        svgFDG.setAttribute("id", "svgFDG");
        //svgFDG.setAttribute("x", MIN_RIGHT_X);
        //svgFDG.setAttribute("y", MIN_RIGHT_Y);
        svgFDG.setAttribute("width", CANVAS_WIDTH);//MAX_RIGHT_X - MIN_RIGHT_X);
        svgFDG.setAttribute("height", FDG_CANVAS_HEIGHT);//MAX_RIGHT_Y - MIN_RIGHT_Y);
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
