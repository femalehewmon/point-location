
var KPVertex = function(svg, x, y, depth){
    this.id = x + ", " + y;
    this.startDepth = depth;
    this.endDepth = Number.MAX_VALUE;
    this.x = x;
    this.y = y;

    this.element = document.createElementNS(NS, "circle");
    this.element.setAttribute("id", "vertex:" + this.id);
    this.element.setAttribute("cx", this.x);
    this.element.setAttribute("cy", this.y);
	this.element.setAttribute("r", 10);
    svg.appendChild(this.element);

    this.show = function(){
        this.element.setAttribute("visibility", "visible");
    }

    this.hide = function(){
        this.element.setAttribute("visibility", "hidden");
    }

    this.hide();
}

function hoverAnimation(el){

    $(el).on("hover", function(){
        // $(el).css("fill, blue");
          console.log("Hey, I'm hovering...and here's the element", el);
    })
}

var KPTriangle = function(svg, id, v1, v2, v3, depth){
    this.id = id;
    this.startDepth = depth;
    this.endDepth = Number.MAX_VALUE;
    this.xmid = 0;
    this.ymid = 0;
    this.isInPolygon = false;
    this.isInOuterTri = false;
    this.isInPolyHull = false;

    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.vertices = new Array();
    this.vertices.push(v1.id);
    this.vertices.push(v2.id);
    this.vertices.push(v3.id);

    this.height = Math.max(v1.y, v2.y, v3.y) - Math.min(v1.y, v2.y, v3.y); 

    points = 
        v1.x + ", " + v1.y + " " +
        v2.x + "," + v2.y + " " +
        v3.x + "," + v3.y;

    this.element = document.createElementNS(NS, "polygon");
    this.element.setAttribute("id", "tri-" + id);
    this.element.setAttribute("points", points);
    this.element.setAttribute("fill-opacity", "0");
    this.element.setAttribute("stroke", "rgb(0,0,0)");
    svg.appendChild(this.element);

    this.centroid = getCentroid(this.element.points);

    this.show = function(){
        this.element.setAttribute("visibility", "visible");
    }

    this.hide = function(){
        this.element.setAttribute("visibility", "hidden");
    }

    this.containsVertex = function(vertexId){
        var contains = false;
        if(vertexId === this.v1.id || 
            vertexId === this.v2.id ||
            vertexId === this.v3.id){
            contains = true;
                }
        return contains;
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

    this.hide();
}

var KPTStruct = function(svg){
    this.svg = svg;
    this.triId = 0;
    this.depth = 0;
    this.drawDepth = 0;

    this.drawPolyTris = false;
    this.drawOuterTris = false;
    this.addPolyTri = false;
    this.addOuterTri = false;
    this.polyTris = new Array();
    this.outerTris = new Array();

    this.oVertices = new Array(); // do not delete outer vertices
    this.vertices = {};
    this.tris = {};
    this.tris_by_vert = {};

    this.triAdjList = {};
    this.rootTri = null; // id of final triangle, to start findInPoly search

    // mark indepedent low-degree vertices
    this.markILDV = function(){
        console.log("Marking ILDV");
        ildv_found = false;
        neighbors = new Array();
        for(var key in this.vertices){
            v = this.vertices[key];
            // vertex is still visible, check to see if it is a ILDV
            if(v.endDepth === Number.MAX_VALUE){ 
                if(v.id in neighbors){
                    // vertex is a neighbor or an outer vertex, skip it
                    continue;
                }

                hullTris = new Array();
                for(var i=0; i < this.tris_by_vert[v.id].length; i++){
                    if(this.tris[this.tris_by_vert[v.id][i]].endDepth ===
                            Number.MAX_VALUE){
                        hullTris.push(this.tris_by_vert[v.id][i]);
                    }
                }
                degree = hullTris.length;
                if(degree > 1 && degree <= 8){
                    ildv_found = true;
                    for (var i=0; i < degree; i++) {
                        adjtri_id = hullTris[i];
                        adjtri = this.tris[adjtri_id];
                        // add adjacent vertices to neighbors list
                        neighbors.push(adjtri.v1.id);
                        neighbors.push(adjtri.v2.id);
                        neighbors.push(adjtri.v3.id);
                        // mark end depth to indicate that tri should be removed
                        this.tris[adjtri_id].endDepth = this.depth;
                    }
                    this.vertices[v.id].endDepth = this.depth;
                    // get hull of hole to retriangulate
                    hullToRemove = this.getTrisHull(hullTris, v);
                    holeTris = triangulate(hullToRemove);
                    // add new triangles to kpt structure
                    this.addTris(holeTris);
                }
            }
        }
        return ildv_found;
    }

    // must be called after markILDV
    this.removeILDV = function(){
        console.log("Removing ILDV");
        // update draw depth to current depth
        this.drawDepth = this.depth;
    }

    this.replaceILDV = function(){
        console.log("Filling in holes");
        this.drawCurrentLevel = true;
    }

    this.getTrisHull = function(trisInHull, centerVert){
        hullVerts = new Array();
        if(trisInHull.length > 0){
            // add starting points for hull of triangles
            currTri = this.tris[trisInHull[0]]; 
            for(var j=0; j < 3; j++){
                if(currTri.vertices[j] != centerVert.id){
                    hullVerts.push(this.vertices[currTri.vertices[j]]);
                } 
            }
            trisInHull = trisInHull.slice(1); // skip first value already added
            numtris = trisInHull.length;
            // skip final tri to avoid double counting endpoint 
            for(var i=0; i < numtris-1; i++){
                currVert = hullVerts[hullVerts.length - 1];
                // find next triangle with a shared endpoint
                var currTri = null;
                for(var j=0; j < trisInHull.length; j++){
                    if(this.tris[trisInHull[j]].containsVertex(currVert.id) &&
                      this.tris[trisInHull[j]].containsVertex(centerVert.id) &&
                      this.tris[trisInHull[j]].endDepth === this.depth){
                        // found adjacent triangle!
                        currTri = this.tris[trisInHull[j]];
                        break;
                    }
                }
                if(!currTri){
                    console.log("NEXT TRI NOT FOUND... something's wrong!");
                    return false;
                }
                // found adjacent triangle!
                for(var k=0; k < 3; k++){ 
                    // add next hull point 
                    // that is not the center vertex
                    // and is not the last added vertex
                    if(currTri.vertices[k] != currVert.id &&
                           currTri.vertices[k] != centerVert.id){
                        hullVerts.push(this.vertices[currTri.vertices[k]]);
                        break;
                   }
                }
                // remove found tri from search list
                trisInHull.splice(trisInHull.indexOf(currTri.id), 1);
            }
        }
        return hullVerts;
    }

    this.render = function(depth, showHoles){
        if(depth === undefined || depth === null){
            depth = this.drawDepth;
        }

        for(var key in this.tris){
            if(this.tris[key].startDepth <= depth &&
                    this.tris[key].endDepth > depth){
                if(showHoles && depth > 0){
                   if(this.tris[key].startDepth === depth){
                       this.tris[key].hide();
                   } else{
                       this.tris[key].show();
                   }
                }
                else{
                    if(depth === 0){
                        this.tris[key].hide();
                        if(this.drawPolyTris && 
                                this.polyTris.indexOf(
                                    parseInt(key, 10)) > -1){
                            this.tris[key].show();
                        } 
                        if(this.drawOuterTris &&
                                this.outerTris.indexOf(
                                    parseInt(key, 10)) > -1){
                                this.tris[key].show();
                        }
                    } else{
                        this.tris[key].show();
                    }
                }
            } else {
                this.tris[key].hide();
            }
        }
        for(var key in this.vertices){
            if(this.vertices[key].startDepth <= depth &&
                    this.vertices[key].endDepth > depth){
                if(showHoles && depth > 0){
                   if(this.vertices[key].startDepth === depth){
                       this.vertices[key].hide();
                   } else{
                       this.vertices[key].show();
                   }
                }
                else{
                    if(depth === 0){
                        this.vertices[key].hide();
                        if(this.drawPolyTris &&
                                this.polyTris.indexOf(
                                parseInt(key, 10)) > -1){
                            this.vertices[key].show();
                        } 
                        if(this.drawOuterTris && 
                                this.outerTris.indexOf(
                                    parseInt(key, 10)) > -1){
                            this.vertices[key].show();
                        }
                    } else{
                        this.vertices[key].show();
                    }
                }
            } else {
                this.vertices[key].hide();
            }
        }
    }

    this.addPolyTris = function(poly2tris){
       this.addPolyTri = true; 
       console.log("Adding polygon triangles", poly2tris);
       this.addTris(poly2tris, 0);
       this.addPolyTri = false; 
    }

    this.addOuterTris = function(poly2tris){
       this.addOuterTri = true; 
       console.log("Adding outer triangles", poly2tris);
       this.addTris(poly2tris, 0);
       this.addOuterTri = false; 
    }

    this.addTris = function(poly2tris, forceLevel){
        var startDepth = this.depth;
        if(forceLevel === undefined || forceLevel === null){
            this.depth += 1;
            console.log("Increased depth to " + this.depth);
        } else{
            startDepth = forceLevel;
        }
        // add triangles
        for(var i = 0; i < poly2tris.length; i++){
            var tri = this.addTri(poly2tris[i], startDepth);
            if(this.addPolyTri){
                console.log("Added poly tri", tri);
                this.polyTris.push(tri.id);
            }
            if(this.addOuterTri){
                console.log("Added outer tri", tri);
                this.outerTris.push(tri.id);
            }
        }
    }

    this.addTri = function(tri, depth){
        var v1 = this.addVertex(tri.getPoint(0).x, tri.getPoint(0).y, depth);
        var v2 = this.addVertex(tri.getPoint(1).x, tri.getPoint(1).y, depth);
        var v3 = this.addVertex(tri.getPoint(2).x, tri.getPoint(2).y, depth);
        this.triId += 1;
        var tri = new KPTriangle(this.svg, this.triId, v1, v2, v3, depth);

        this.tris_by_vert[v1.id].push(tri.id);
        this.tris_by_vert[v2.id].push(tri.id);
        this.tris_by_vert[v3.id].push(tri.id);
        this.tris[this.triId] = tri;
        return tri;
    }

    this.addVertex = function(x, y, depth){
        id = x + ", " + y;
        if(!(id in this.vertices)){
            vertex = new KPVertex(this.svg, x, y, depth);
            this.vertices[id] = vertex;
            this.tris_by_vert[id] = new Array();
        }
        return this.vertices[id];
    }

    this.pointInPoly = function(x, y){
        console.log("Looking for point in poly!");
        var pointFound = false;
        if(this.rootTri === null){
            for(var key in this.tris){
                if(this.tris[key].startDepth === this.depth - 1){
                    this.rootTri = this.key;
                }
            }
            if(this.rootTri === null){
                console.log("ROOT TRI NOT FOUND.. something's wrong!");
            } else{
                console.log("ROOT TRI FOUND!");
            }
        }

        stack = new Array();
        while(this.rootTri !== null){
            if(this.rootTri.containsPoint(x, y)){
                pointFound = true;    
                break;
            } else{
                for(var tri in this.adjList[this.rootTri.id]){
                    stack.push(tri);
                }
            }
            if(stack.length > 0){
                this.rootTri
            }
        }

        return pointFound;
    }

}

var triangulate = function(polyPoints, polyHolePoints){
    // add polygon points to triangulation
    var contour = new Array();
    for(var i = 0; i < polyPoints.length; i++){
        contour.push(
            new poly2tri.Point(polyPoints[i].x, polyPoints[i].y));
    }
    var swctx = new poly2tri.SweepContext(contour);
    // add holes if necessary
    if(polyHolePoints){
        var hole = new Array();
        for(var i = 0; i < polyHolePoints.length; i++){
            hole.push(
                new poly2tri.Point(polyHolePoints[i].x, polyHolePoints[i].y));
        }
        console.log("Added hole of size " + hole.length);
        swctx.addHole(hole);
    }
    // triangulate, thanks to poly2tri
    swctx.triangulate();
    triangles = swctx.getTriangles();
    return triangles;
}

movePoint = function(oldPos, oldCenter, newCenter){
    var centerOffset = oldCenter - oldPos; 
    return newCenter + centerOffset;
}

loadPolygon = function(svg, vertices){
    console.log("Load polygon");
    var points = "";
    for(var i=0; i < vertices.length; i++){
        points += vertices[i].x + ", " + vertices[i].y + " ";
    }
    var element = document.createElementNS(NS, "polygon");
    element.setAttribute("id", "mainPoly");
    element.setAttribute("points", points);
    element.setAttribute("fill-opacity", "0");
    element.setAttribute("stroke", "rgb(0,0,0)");
    svg.appendChild(element);
    return element;
}


