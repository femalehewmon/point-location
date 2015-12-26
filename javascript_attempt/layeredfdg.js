// Global and file-global constants

var walkGraph = function(fdg, todo){
    // bfs
    var queue = [];
    if(fdg.nodes.length > 0){
        fdg.resetGraph();
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

    var resetGraph = function(){
       for(point in this.nodes){
           point.scolor = WHITE;
           point.depth = Infinity;
           point.pparent = null;
           point.xforce = 0;
           point.yforce = 0;
       } 
    }

    this.render = function(renderLevel){
        if(!renderLevel){
            renderLevel = this.maxLevel;
        }
        for(var key in this.levels){
            if(key < renderLevel){
                for(var nodeId in this.levels[key]){
                    this.nodes[nodeId].setAttribute("visibility", "visible");
                }
            } else{
                for(var nodeId in this.levels[key]){
                    this.nodes[nodeId].setAttribute("visibility", "hidden");
                }
            } 
        }
    }

    this.loadNodes = function(kptTris, maxDepth){
        this.maxLevel = maxDepth;

        // remove all elements from svg
        while(svgFDG.firstChild){
            svgFDG.removeChild(svgFDG.firstChild);
        }

        // create bounding boxes
        for(var i=0; i < maxDepth; i++){
            bounds = this.getBounds(i);
            console.log("Bounds for level " + i + " " + bounds);
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
                    this.addKPTri(kptTris[key], currDepth);
                }
            }
            for(var child in childNodes){
                for(var par in parentNodes){
                   this.addEdge(parentNodes[par], childNodes[child]); 
                }
            }
        }
    }

    this.getBounds = function(level){
        height = CANVAS_HEIGHT - MARGIN*2; 
        height_per_level = height/this.maxLevel;

        leftB = MIN_LEFT_X;//MIN_RIGHT_X;
        rightB = MAX_LEFT_X;//MAX_RIGHT_X;
        bottomB = CANVAS_HEIGHT - MARGIN - height_per_level*level;//MAX_RIGHT_Y - height_per_level*level;
        topB = CANVAS_HEIGHT - MARGIN - height_per_level*(level+1);//MAX_RIGHT_Y - height_per_level*(level+1);

        bounds = [leftB, topB, rightB, bottomB, 
               rightB - leftB, bottomB - topB];
        return bounds;
    }

    this.addKPTri = function(tri, level){
        bounds = this.getBounds(level);

        var xOffset = bounds[4]/2 - tri.centroid[0]; 
        var yOffset = bounds[1] + bounds[5]/2 - tri.centroid[1];
        var points = 
             (tri.v1.x + xOffset) + "," + (tri.v1.y + yOffset) + " " +
             (tri.v2.x + xOffset) + "," + (tri.v2.y + yOffset) + " " +
             (tri.v3.x + xOffset) + "," + (tri.v3.y + yOffset);
        console.log("POINTS: " + points);

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
            console.log("FDG ADDING NODE " + node.id + " to level " + level);
            if(!(level in this.levels)){
                this.levels[level] = new Array();
            }
            this.levels[level].push(node.id);
            this.adjList[node.id] = new Array();
            this.nodes[node.id] = node;
        }
    }

    // p1 == parent
    // p2 == child
    this.addEdge = function(p1, p2, undirected){
        this.addNode(p1);
        this.addNode(p2);
        this.adjList[p1.id].push(new Edge(p2.id, DEFAULT_LENGTH));
        if(undirected){
            this.adjList[p2.id].push(new Edge(p1.id, DEFAULT_LENGTH));
        }
    }

    this.Point = function(id, x, y, level) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.level = level;
        //------- force properties -------
        this.xforce = 0;
        this.yforce = 0;
        //------- search properties -------
        this.scolor = WHITE;
        this.depth = Infinity;
        this.pparent = null;
    }

    var Edge = function(endNodeId, length) {
        this.endNode = endNodeId;
        this.length = length;
    }

    this.init = function() {
        console.log("Create force directed graph");
        svgFDG = document.createElementNS(NS, "svg");
        svgFDG.setAttribute("id", "svgFDG");
        //svgFDG.setAttribute("x", MIN_RIGHT_X);
        //svgFDG.setAttribute("y", MIN_RIGHT_Y);
        svgFDG.setAttribute("width", CANVAS_WIDTH);//MAX_RIGHT_X - MIN_RIGHT_X);
        svgFDG.setAttribute("height", CANVAS_HEIGHT);//MAX_RIGHT_Y - MIN_RIGHT_Y);
        document.body.appendChild(svgFDG);
    }

}

function randomColor(){
    var r = Math.floor(Math.random() * 255);
    var g = Math.floor(Math.random() * 255);
    var b = Math.floor(Math.random() * 255);
    return "rgb("+r+", "+g+", "+b+")";
}


function draw(){
    window.requestAnimationFrame(draw);
}
