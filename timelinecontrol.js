// primary stages of program
CREATE_POLYGON = "createPoly";
SETUP_TRIANGULATION = "triangulation";
DRAW_STRUCTURES = "drawStructs";
    triangulate_poly = "triangulatePoly";
    draw_outer_tri = "drawOuterTri";
    triangulate_outer_tri = "triangulateOuter";
    iteratively_remove_ildv = "removeILDV";
POINT_LOCATION = "pointLocation";
DONE = "done";

stage = CREATE_POLYGON;
subStage = 0; // used for finer control in primary stages
drawLevel = 0;

counter = 0;
MAX_COUNT = 100;
showHoles = false; // flag to show holes after ildv are removed

function draw(){
    switch(stage){
        case CREATE_POLYGON:
            // at this point, poly is still custom
            // load into an svg polygon
            if(poly === undefined || poly === null){
                createPolygon();
                $("#textbox").html("Click to create a a simple polygon with non-overlapping edges.");
            } else{
                if(DEMO){
                    repositionPolygon();
                    stage = SETUP_TRIANGULATION;
                    $("#textbox").html("Nice polygon!");
                } else{
                    if(poly.isFinished){
                        // reposition polygon
                        while(svg.firstChild){
                            svg.removeChild(svg.firstChild);
                        }
                        poly = loadPolygon(svg, poly.points);
                        repositionPolygon();
                        stage = SETUP_TRIANGULATION;
                        $("#textbox").html("Nice polygon!");
                        poly.setAttribute("visibility", "hidden");

                    }
                }
            }
            break;
        case SETUP_TRIANGULATION:
            // triangulate main polygon 
            polytris = triangulate(poly.points);
            kpt.addPolyTris(polytris);
            fdg.addPolyTris(kpt.polyTris); // add ids only, workaround

            // create and triangulate outer polygon
            if(outerTri === undefined || outerTri === null){
                createOuterTriangle();
            }
            outertris = triangulate(
                        outerTri.points, poly.points);
            kpt.addOuterTris(outertris);
            fdg.addOuterTris(kpt.outerTris);

            // find and remove ILDVs
            while(kpt.markILDV()){
                kpt.markILDV();
                removedToNewTris = kpt.removeILDV();
            }

            // finally, load triangles into data structures
            loadNodes(kpt.tris, kpt.depth);

            stage = DRAW_TRIANGULATION;
            subStage = triangulate_poly;
            break;
        case DRAW_TRIANGULATION:
            if(counter >= MAX_COUNT){
                console.log("In stage ", stage, subStage);
                switch(subStage){
                    case triangulate_poly:
                        kpt.drawPolyTris = true;
                        fdg.drawPolyTris = true;

                        poly.setAttribute("visibility", "hidden");
                        subStage = draw_outer_tri;
                        break;
                    case draw_outer_tri:
                        outerTri.setAttribute("visibility", "visible");
                        subStage = triangulate_outer_tri;
                        break;
                    case triangulate_outer_tri:
                        kpt.drawOuterTris = true;
                        fdg.drawOuterTris = true;
                        subStage = iteratively_remove_ildv;
                        drawLevel = 0;
                        break;
                    case iteratively_remove_ildv:
                        if(drawLevel <= fdg.maxLevel){
                            drawLevel++;
                        } else{
                            stage = POINT_LOCATION;
                        }
                        break;
                }
                kpt.render(drawLevel);
                fdg.render(drawLevel);
                counter = 0;
            } 
            counter++;
            break;
        case POINT_LOCATION:
            kpt.render(0);
            fdg.render(fdg.maxLevel);
            /*
            if(counter >= MAX_COUNT){
                //this.svg.addEventListener("click", clickCB.bind(this));
                $('#outerTri').attr('visibility', 'hidden');
                //$('#mainPoly').attr('visibility', 'visible');
                poly.setAttribute("visibility", "visible");
                kpt.render(-1);
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
            counter++;
            */
            stage = DONE;
            break;
        case FIND_POINT:
            if(kpt.pointInPoly(
                        pointToFind.cx, pointToFind.cy)){
                console.log("POINT IN POLY");
            } else{
                console.log("POINT NOT IN POLY");
            }
            stage = DONE;
            break;
    }
    window.requestAnimationFrame(draw);
}

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


