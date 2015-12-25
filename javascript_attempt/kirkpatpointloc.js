
var KPVertex = function(x, y, depth){
    this.id = x + ", " + y;
    this.startdepth = depth;
    this.enddepth = Infinity;
    this.x = x;
    this.y = y;

    var render = function(){
        this.svgelm.visibility = true;
    }

    var hide = function(){
        this.svgelm.visibility = false;
    }
}

var KPTriangle = function(id, v1, v2, v3, depth){
    this.id = id;
    this.startdepth = depth;
    this.enddepth = Infinity;
    this.xmid = 0;
    this.ymid = 0;
    this.isInPolygon = false;
    this.isInOuterTri = false;
    this.isInPolyHull = false;

    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;

    var render = function(){
        this.svgelm.visibility = true;
    }

    var hide = function(){
        this.svgelm.visibility = false;
    }

    var setInPoly = function(){
        this.isInPolygon = true;
    }
    var setInOuterTri = function(){
        this.isInOuterTri = true;
    }
    var setInPolyHull = function(){
        this.isInPolyHull = true;
    }

    var setMidPoints = function(x, y){
        if(x && y) {
            this.xmid = x;
            this.ymid = y;
        } else{
            // calculate mid point from vertices
        }
    }

}


var KPTStruct = function(){
    this.tri_id = 0;
    this.depth = 0;
    this.drawdepth = 0;

    this.vertices = new Array();
    this.tris = new Array();
    this.tris_by_vert = {};

    this.overtices = new Array(); // do not delete outer vertices

    // mark indepedent low-degree vertices
    var markILDV = function(){
        neighbors = new Array();
        for(v in this.vertices){
            // vertex is still visible, check to see if it is a ILDV
            if(v.end_depth == Infinity){ 
                if(v.id in neighbors || v.id in this.overtices){
                    // vertex is a neighbor or an outer vertex, skip it
                    continue;
                }

                degree = this.tris_by_vert[v.id].length;
                if(degree <= 8){
                    for (var i=0; i < degree; i++) {
                        adjtri = this.tris[this.tris_by_vert[v.id][i]];
                        // add adjacent vertices to neighbors list
                        neighbors.push(adjtri.v1.id);
                        neighbors.push(adjtri.v2.id);
                        neighbors.push(adjtri.v3.id);
                        // mark end depth to indicate that tri should be removed
                        this.adjtri.end_depth = this.depth;
                        this.vertices[v1.id].end_depth = this.depth;
                        this.vertices[v2.id].end_depth = this.depth;
                        this.vertices[v3.id].end_depth = this.depth;
                    }
                    // get hull of hole to retriangulate
                    hulltoremove = this.getTrisHull(this.tris_by_vert[v.id], v);
                    holetris = triangulate(hulltoremove);
                    // add new triangles to kpt structure
                    this.addTris(holetris);
                }
            }
        }
    }

    // must be called after markILDV
    var removeILDV = function(){
        // update draw depth to current depth
        this.drawdepth = this.depth;
    }

    var getTrisHull = function(htris, centervert){
        hullverts = new Array();
        if(htris.length > 0){
            // add starting points for hull of triangles
            currtri = this.tris[htris[0]]; 
            for(var j=0; j < 3; j++){
                if(currtri.vertices[j] != centervert){
                    hullverts.push(currtri.vertices[j]);
                } 
            }
            htris = htris.slice(1);
            numtris = htris.length;
            // skip final tri to avoid double counting endpoint 
            for(var i=0; i < numtris-1; i++){
                currvert = hullverts[-1];
                // find next triangle with a shared endpoint
                nvert_found = false;
                for(var j=0; j < tris.length; j++){
                    currtri = this.tris[htris[j]];
                    if(currvert in currtri.vertices){
                        // found adjacent triangle!
                        for(var k=0; k < 3; k++){ 
                            if(currtri.vertices[k] != currvert &&
                                   currtri.vertices[k] != centervert){
                                hullverts.push(currtri.vertices[k]);
                                nvert_found = true;
                                break;
                           }
                        }
                    }
                }
                if(!nvert_found){
                    console.log("NEXT TRI NOT FOUND... something's wrong!");
                    break;
                }
                // remove adjacent tri from search list
                htris.splice(htris.indexOf(currtri), 1);
            }
        }
        return hullverts;
    }

    var render = function(){
        render(this.drawdepth);
    }

    var render = function(depth){
        for(var i=0; i < this.tris.length; i++){
            if(this.tris[i].startdepth < depth &&
                    this.tris[i].enddepth > depth){
                this.tris[i].render();
            } else {
                this.tris[i].hide();
            }
        }
        for(var i=0; i < this.vertices.length; i++){
            if(this.vertices[i].startdepth < depth &&
                    this.vertices[i].enddepth > depth){
                this.vertices[i].render();
            } else {
                this.vertices[i].hide();
            }
        }
    }

    var addTris = function(poly2tris, dont_increase_level){
        poly2tris.forEach(function(t){
            this.addTri(t, this.depth);
        })
        if(!dont_increase_level){
            this.depth += 1;
        }
    }

    var addTri = function(tri, depth){
        v1 = addVertex(tri.getPoint(0).x, tri.getPoint(0).y, depth);
        v2 = addVertex(tri.getPoint(1).x, tri.getPoint(1).y, depth);
        v3 = addVertex(tri.getPoint(2).x, tri.getPoint(2).y, depth);
        this.tri_id += 1;
        tri = new KPTriangle(this.tri_id, v1, v2, v3, depth);
        this.tris_by_vert[v1.id].push(tri);
        this.tris_by_vert[v2.id].push(tri);
        this.tris_by_vert[v3.id].push(tri);
        this.tris[this.tri_id] = tri;
    }

    var addVertex = function(x, y){
        vertex = new KPVertex(x, y);
        id = vertex.id;
        if(!id in this.vertices){
            this.vertices[id] = vertex;
        }
        return this.vertices[id];
    }
}

var triangulate = function(poly, polyhole){
    var contour = new Array();
    for(var i in poly.points){
        contour.push(
            new poly2tri.Point(poly.points[i].x, poly.points[i].y));
    }
    var swctx = new poly2tri.SweepContext(contour);
    if(polyhole){
        var hole = new Array();
        for(var i in polyhole.points){
            hole.push(
                new poly2tri.Point(polyhole.points[i].x, polyhole.points[i].y));
        }
        swctx.addHole(hole);
    }
    swctx.triangulate();
    var triangles = swctx.getTriangles();
    triangles.forEach(function(t){
        var p1 = new Point(t.getPoint(0).x, t.getPoint(0).y);
        var p2 = new Point(t.getPoint(1).x, t.getPoint(1).y);
        var p3 = new Point(t.getPoint(2).x, t.getPoint(2).y);
        poly.addEdge(p1, p2);
        poly.addEdge(p1, p3);
        poly.addEdge(p2, p3);
    })
}

loadPolygon = function(svg, vertices){
    console.log("Load polygon");
    var points = "";
    for(var i=0; i < vertices.length; i++){
        console.log("added point");
        points += vertices[i].x + ", " + vertices[i].y + " ";
    }
    var element = document.createElementNS(NS, "polygon");
    element.setAttribute("points", points);
    svg.appendChild(element);
    return element;
}

drawOuterTriangle = function(svg){
    console.log("Draw outer tri");

    topY = MARGIN;
    bottomY = CANVAS_HEIGHT - MARGIN;
    rightX = CANVAS_WIDTH/2 - MARGIN;
    leftX = MARGIN;
    centerX = CANVAS_WIDTH/4;

    var points = "";
    points += leftX + ", " + bottomY;
    points += " ";
    points += centerX + ", " + topY;
    points += " ";
    points += rightX + ", " + bottomY;
    console.log("outer tri points: " + points);

    var element = document.createElementNS(NS, "polygon");
    element.setAttribute("id", "outerTri");
    element.setAttribute("points", points);
    //element.setAttribute("fill-opacity", 0);
    element.setAttribute("stroke", "rgb(0,0,0)");
    svg.appendChild(element);
    return element;
}

