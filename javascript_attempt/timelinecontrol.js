CREATE_POLYGON = "createPoly";
TEXT_CREATE_POLYGON_START = "Click anywhere within the box to create a simple polygon with no intersecting edges."
TEXT_CREATE_POLYGON_FINISHED = "Nice polygon!";
TEXT_CREATE_POLYGON_1 = "Though it looks unassuming, there are many things we can do with this simple shape. For example, you could use it to define the boundaries of a region on a map, or even as the outer base to a more complicated object in a video game."
TEXT_CREATE_POLYGON_2 = "But, how do we go about interacting with this this shape? Imagine you are trying to interact with it on the screen of this computer. How would you determine if your mouse pointer was inside or outside its bounds? You could step around the outside of the polygon and determine which side of each edge you are on. Assuming you step around the polygon in a counter-clockwise direction, if you are able to traverse the entire boundary of the polygon and always stay to the left all edges then you are inside the shape. This idea does seem to work, but imagine you need to determine if not just your mouse pointer is inside the shape, but the mouse pointer of 100 of your friends. Wow, that's suddenly a lot of checking. Furthermore, what if your polygon was much larger... let's say it has 1000x more edges than this polygon. As you can imagine, the computational cost is getting out of hand. If you are search for the location of n points against polygons with a total of n edges, your time complexity would quickly reach O(n^2)."
TEXT_CREATE_POLYGON_3 = "There must be a better way. Luickly for us, David G. Kirkpatrick, a professor of computer science at the University of British Columbia, came up with an efficient method for point location inside of a polygon in 1983. In his algorithm, he proposes a step-by-step triangulation of the polygon and its immediate surrounding area. At each stage of the triangulation, a set of independent, low-degree vertices are removed and the resulting hole is re-triangulated. This processes systematically builds a tree, which can be queried in O(logn) time. Looking back at our previous situation, if we are looking for n points in a total of n edges, we now have n queries of O(logn), for a total of O(nlogn), a significant improvement to the initial quadratic result.";
TEXT_CREATE_POLYGON_4 = "To get a better feel for the algorithm, lets step through the data structure build up with your polygon.";

SETUP_TRIANGULATION = "setupTris";
TEXT_SETUP_TRIANGULATION_START = "To start, triangulate the original polygon."
TEXT_SETUP_TRIANGULATION_START = "This looks like a good start, but what about the area outside of the polygon? To handle this area, we draw a triangle that overlaps the area immediatley around the polygon. Next, we triangulate the area between the original polygon and this outer triangle."
DRAW_TRIANGULATION = "drawTris";
POINT_LOCATION = "pointLocation";
FIND_POINT = "findPoint";


MAX_COUNT = 100;
counter = 0;
stage = CREATE_POLYGON;
subStage = 0;
showHoles = false; // flag to show holes after ildv are removed
function draw(){
    switch(stage){
        case CREATE_POLYGON:
            // at this point, poly is still custom
            // load into an svg polygon
            if(DEMO){
                repositionPolygon();
                stage = SETUP_TRIANGULATION;
                $("#textbox").html(TEXT_CREATE_POLYGON_FINISHED);
            }else{
                if(poly.isFinished){
                    // reposition polygon
                    while(svg.firstChild){
                        svg.removeChild(svg.firstChild);
                    }
                    poly = loadPolygon(svg, poly.points);
                    repositionPolygon();
                    stage = SETUP_TRIANGULATION;

                    $("#textbox").html(TEXT_CREATE_POLYGON_FINISHED);
                }
            }
            break;
        case SETUP_TRIANGULATION:
            switch(subStage){
                case 0:
                    $("#textbox").html(
                            "Let's triangulate the polygon");
                    // triangulate main polygon
                    if(counter >= MAX_COUNT){
                        console.log("Triangulate main poly");
                        poly.setAttribute("visibility", "hidden");
                        kptstruct = new KPTStruct(svg);
                        polytris = triangulate(poly.points);
                        kptstruct.addTris(polytris, true, true);
                        counter = 0;
                        subStage++;

                    }
                    counter++;
                    break;
                case 1:
                    // draw and triangulate convex hull
                    /*
                    if(counter >= MAX_COUNT){
                        console.log("Draw and triangulate CH");
                        polyhull = getConvexHull(poly.points); 
                        //hulltris = 
                        //    triangulate(polyhull, poly.points);
                        //kptstruct.addTris(hulltris, true);
                        //fdg.addNodes(hulltris);
                        subStage++;
                    }
                    counter++;
                    */
                    subStage++;
                    break;
                case 2:
                    // draw and triangulate outer triangle
                    $("#textbox").html(
                            TEXT_SETUP_TRIANGULATION_START);
                    if(counter >= MAX_COUNT){
                        $("#textbox").html(
                                );
                        outerTri = drawOuterTriangle(CENTER);
                        counter = 0;
                        subStage++;
                    }
                    counter++;
                    break;
                case 3:
                    if(counter >= MAX_COUNT){
                        console.log("Triangulate outer tri");
                        outertris = triangulate(
                                    outerTri.points, poly.points);
                        kptstruct.addTris(outertris, false, true);
                        counter = 0;
                        subStage++;
                    }
                    counter++;
                    break;
                case 4:
                    // find and remove ILDVs
                    while(kptstruct.markILDV()){
                        kptstruct.markILDV();
                        removedToNewTris = kptstruct.removeILDV();
                    }

                    // create graph layout and load triangles
                    fdg = new LayeredFDG();
                    loadNodes(kptstruct.tris, kptstruct.depth);

                    // move to next stage
                    subStage = 0;
                    stage = DRAW_TRIANGULATION;
                    console.log("Going to draw triangulation");
                    break;
            }
            break;
        case DRAW_TRIANGULATION:
            if(counter >= MAX_COUNT){
                if(subStage <= fdg.maxLevel){
                    if(!showHoles){
                        subStage++;
                    }
                    showHoles = !showHoles;
                    counter = 0;
                } else{
                    subStage = 0;
                    counter = 0;
                    stage = POINT_LOCATION; 
                }
            } 
            kptstruct.render(subStage, showHoles);
            if(showHoles){
                fdg.render(subStage-1);
            } else{
                fdg.render(subStage);
            }
            counter++;
            break;
        case POINT_LOCATION:
            fdg.render(0);
            kptstruct.render(0);
            /*
            if(counter >= MAX_COUNT){
                //this.svg.addEventListener("click", clickCB.bind(this));
                $('#outerTri').attr('visibility', 'hidden');
                //$('#mainPoly').attr('visibility', 'visible');
                poly.setAttribute("visibility", "visible");
                kptstruct.render(-1);
                fdg.render(-1);
                
                $('#polySVG').click(function(){
                    console.log("Adding point to find");
                    pointToFind = document.createElementNS(NS, "circle");
                    pointToFind.setAttribute("id", "pointToFind");
                    pointToFind.setAttribute("cx", event.clientX);
                    pointToFind.setAttribute("cy", event.clientY);
                    pointToFind.setAttribute("fill", "rgb(255, 0, 0)");
                    pointToFind.setAttribute("r", 10);
                    svg.appendChild(pointToFind);
                    subStage = 0;
                    counter = 0;
                    stage = FIND_POINT;
                });
            }
            */
            counter++;
            break;
        case FIND_POINT:
            if(kptstruct.pointInPoly(
                        pointToFind.cx, pointToFind.cy)){
                console.log("POINT IN POLY");
            } else{
                console.log("POINT NOT IN POLY");
            }
            break;
    }
    window.requestAnimationFrame(draw);
}
