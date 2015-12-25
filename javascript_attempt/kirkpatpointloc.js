
var KPVertex = function(svg, x, y, depth){
    this.id = x + ", " + y;
    this.startDepth = depth;
    this.endDepth = Infinity;
    this.x = x;
    this.y = y;

    this.element = document.createElementNS(NS, "circle");
    this.element.setAttribute("id", "vertex:" + this.id);
    this.element.setAttribute("cx", this.x);
    this.element.setAttribute("cy", this.y);
	this.element.setAttribute("r", 10);
    svg.appendChild(this.element);

    this.render = function(){
        this.element.visibility = true;
    }

    this.hide = function(){
        this.element.visibility = false;
    }
}

var KPTriangle = function(svg, id, v1, v2, v3, depth){
    this.id = id;
    this.startDepth = depth;
    this.endDepth = Infinity;
    this.xmid = 0;
    this.ymid = 0;
    this.isInPolygon = false;
    this.isInOuterTri = false;
    this.isInPolyHull = false;

    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;

    points = 
        v1.x + ", " + v1.y + " " +
        v2.x + "," + v2.y + " " +
        v3.x + "," + v3.y;

    this.element = document.createElementNS(NS, "polygon");
    this.element.setAttribute("id", "tri:" + id);
    this.element.setAttribute("points", points);
    this.element.setAttribute("fill-opacity", "0");
    this.element.setAttribute("stroke", "rgb(0,0,0)");
    svg.appendChild(this.element);

    this.render = function(){
        this.element.visibility = true;
    }

    this.hide = function(){
        this.element.visibility = false;
    }

    this.setInPoly = function(){
        this.isInPolygon = true;
    }
    this.setInOuterTri = function(){
        this.isInOuterTri = true;
    }
    this.setInPolyHull = function(){
        this.isInPolyHull = true;
    }

    this.setMidPoints = function(x, y){
        if(x && y) {
            this.xmid = x;
            this.ymid = y;
        } else{
            // calculate mid point from vertices
        }
    }

}


var KPTStruct = function(svg){
    this.svg = svg;
    this.triId = 0;
    this.depth = 0;
    this.drawDepth = 0;

    this.vertices = new Array();
    this.tris = new Array();
    this.tris_by_vert = {};

    this.overtices = new Array(); // do not delete outer vertices

    // mark indepedent low-degree vertices
    this.markILDV = function(){
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
    this.removeILDV = function(){
        // update draw depth to current depth
        this.drawDepth = this.depth;
    }

    this.getTrisHull = function(htris, centervert){
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

    this.render = function(depth){
        if(!depth){
            depth = this.drawDepth;
        }
        for(var key in this.tris){
            if(this.tris[key].startDepth <= depth &&
                    this.tris[key].endDepth > depth){
                this.tris[key].render();
            } else {
                this.tris[key].hide();
            }
        }
        for(var i=0; i < this.vertices.length; i++){
            if(this.vertices[i].startDepth <= depth &&
                    this.vertices[i].endDepth > depth){
                this.vertices[i].render();
            } else {
                this.vertices[i].hide();
            }
        }
    }

    this.addTris = function(poly2tris, dont_increase_level){
        for(var i = 0; i < poly2tris.length; i++){
            this.addTri(poly2tris[i], this.depth);
        }
        if(!dont_increase_level){
            console.log("Increased level");
            this.depth += 1;
        }
    }

    this.addTri = function(tri, depth){
        v1 = this.addVertex(tri.getPoint(0).x, tri.getPoint(0).y, depth);
        v2 = this.addVertex(tri.getPoint(1).x, tri.getPoint(1).y, depth);
        v3 = this.addVertex(tri.getPoint(2).x, tri.getPoint(2).y, depth);
        this.triId += 1;
        tri = new KPTriangle(this.svg, this.triId, v1, v2, v3, depth);
        console.log("Adding new tri: " + tri.id);
        this.tris_by_vert[v1.id].push(tri);
        this.tris_by_vert[v2.id].push(tri);
        this.tris_by_vert[v3.id].push(tri);
        this.tris[this.triId] = tri;
    }

    this.addVertex = function(x, y){
        vertex = new KPVertex(this.svg, x, y);
        id = vertex.id;
        if(!(id in this.vertices)){
            console.log("Adding new vertex: " + x + " " + y);
            this.vertices[id] = vertex;
            this.tris_by_vert[id] = new Array();
        }
        return this.vertices[id];
    }
}

var triangulate = function(poly, polyhole){
    console.log("Triangulating");
    // add polygon points to triangulation
    var contour = new Array();
    for(var i = 0; i < poly.points.length; i++){
        contour.push(
            new poly2tri.Point(poly.points[i].x, poly.points[i].y));
    }
    var swctx = new poly2tri.SweepContext(contour);
    // add holes if necessary
    if(polyhole){
        var hole = new Array();
        for(var i = 0; i < polyhole.points.length; i++){
            hole.push(
                new poly2tri.Point(polyhole.points[i].x, polyhole.points[i].y));
        }
        console.log("Added hole of size " + hole.length);
        swctx.addHole(hole);
    }
    // triangulate
    swctx.triangulate();
    triangles = swctx.getTriangles();
    console.log("triangulated into " + triangles.length);
    return triangles;
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
    element.setAttribute("fill-opacity", "0");
    element.setAttribute("stroke", "rgb(0,0,0)");
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
    element.setAttribute("fill-opacity", "0");
    element.setAttribute("stroke", "rgb(0,0,0)");
    svg.appendChild(element);
    return element;
}

