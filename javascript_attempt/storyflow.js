CREATE_POLY = 1;
MOVE_POLY = 2;
TRIANGULATE_POLY = 3;
tri_main_poly = 3.1;
tri_convex_hull = 3.2;
draw_outer_tri = 3.3;
tri_outer_tri = 3.4;

var StoryLine = function(){

    this.frames = new Array();

    var addFrame = function(frame){
        this.frames.push(frame);
    }
}

var Frame = function(stage, substage, extra){
    this.stage = stage;
    this.substage = substage;
    this.extra = extra;
}

