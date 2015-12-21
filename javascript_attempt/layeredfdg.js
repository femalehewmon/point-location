// Global and file-global constants

var walkGraph = function(fdg, todo){
    // bfs
    var queue = [];
    if(fdg.points.length > 0){
        fdg.resetGraph();
        fdg.points[0].scolor = GREY;
        fdg.points[0].depth = 0;
        queue.push(this.points[0].id);
        while(queue.length > 0){
            uid = queue.shift();
            u = fdg.points[uid];
            for(vid in adjList[u]){
                v = fdg.points[vid];
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

var LayeredForceDirectedGraph = function(svg) {
    DEFAULT_LENGTH = 10;
    WHITE = "white";
    GREY = "grey";
    BLACK = "black";

    var adjList = {};   // point_id:[edges]
    var points = {};    // point_id:drawable

    var resetGraph = function(){
       for(point in points){
           point.scolor = WHITE;
           point.depth = Infinity;
           point.pparent = null;
           point.xforce = 0;
           point.yforce = 0;
       } 
    }

    var addNode = function(p1){
        if(!p1.id in adjList){
            adjList[p1.id] = new Array();
        }
    }

    var addEdge = function(p1, p2, undirected){
        addNode(p1);
        addNode(p2);
        adjList[p1.id].push(new Edge(p2.id, DEFAULT_LENGTH));
        if(undirected){
            adjList[p2.id].push(new Edge(p1.id, DEFAULT_LENGTH));
        }
    }

    var Point = function(id, x, y, level) {
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

}

function init() {
    console.log("Create polygon");
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
