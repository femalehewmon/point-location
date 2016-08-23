class SceneController {
	int sceneTimer;
	float scenePercentageStep;
	float scenePercentComplete;
	float sceneRelativePercentComplete;

	int DEFAULT_SCENE_DURATION = 100;
	int sceneDuration;

	final String CREATE_POLYGON = "CREATE POLYGON";
	final String SETUP_KIRKPATRICK_DATA_STRUCTURE = "SETUP KP DATA STRUCT";
	final String CREATE_KIRKPATRICK_DATA_STRUCTURE = "CREATE KP DATA STRUCT";
	final String POINT_LOCATION = "POINT LOCATION";

	boolean sceneReady;
	boolean updateSceneOnKeyPress;
	boolean controllerKeyPressed;
	boolean autoUpdate;

	public SceneController() {
		this.currScene = CREATE_POLYGON;
		this.sceneDuration = DEFAULT_SCENE_DURATION;
		this.sceneReady = false;
		this.autoUpdate = false;

		reset();
	}

	public void restart() {
		reset();
		this.sceneReady = false;
		this.currScene = SETUP_KIRKPATRICK_DATA_STRUCTURE;
	}

	public void reset() {
		this.sceneTimer = 0;
		this.scenePercentageStep = 1.0/(float)sceneDuration;
		this.scenePercentComplete = 0.0;
		this.sceneRelativePercentComplete = 0.0;
		this.updateSceneOnKeyPress = false;
		this.controllerKeyPressed = false;
	}

	public void ready() {
		this.sceneReady = true;
	}

	public void enableAutoUpdate() {
		updateOnSceneDuration(false);
		this.autoUpdate = true;
	}

	public void updateSceneDuration(float scale) {
		sceneDuration = DEFAULT_SCENE_DURATION / scale;
	}

	public boolean update() {
		if ( !updateSceneOnKeyPress ) {
			boolean next_scene = false;
			sceneTimer += 1;
			if ( sceneTimer >= sceneDuration ) {
				next_scene = true;
			}
			scenePercentComplete = (float)sceneTimer / (float)sceneDuration;
			sceneRelativePercentComplete =
				1.0 / (sceneControl.sceneDuration - sceneControl.sceneTimer);
			return next_scene;
		} else {
			if ( controllerKeyPressed ) {
				updateSceneOnKeyPress = false;
				return controllerKeyPressed;
			}
		}
	}

	public void updateOnSceneDuration(boolean forceUpdate) {
		if ( forceUpdate ) {
			sceneTimer = sceneDuration;
		}
		updateSceneOnKeyPress = false;
	}

	public void updateOnKeyPress() {
		if (!this.autoUpdate) {
			controllerKeyPressed = false;
			updateSceneOnKeyPress = true;
		}
	}

	public void onKeyPress() {
		controllerKeyPressed = true;
	}

	public void previousScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				break;
			case SETUP_KIRKPATRICK_DATA_STRUCTURE:
				this.currScene = CREATE_POLYGON;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCTURE:
				this.currScene = SETUP_KIRKPATRICK_DATA_STRUCTURE;
				break;
			case POINT_LOCATION:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCTURE;
				break;
		}
		if(DEBUG){
		console.log("Previous scene " + this.currScene);
		}
		reset();
		this.sceneReady = false;
	}

	public void nextScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				this.currScene = SETUP_KIRKPATRICK_DATA_STRUCTURE;
				break;
			case SETUP_KIRKPATRICK_DATA_STRUCTURE:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCTURE;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCTURE:
				this.currScene = POINT_LOCATION;
				break;
			case POINT_LOCATION:
				this.currScene = POINT_LOCATION;
				break;
		}
		if(DEBUG){
		console.log("Next scene " + this.currScene);
		}
		reset();
		this.sceneReady = false;
		this.autoUpdate = false;
	}

String newline = "\r\n";
String create = "Click anywhere within the bounds of the visualization to create a polygon with non-overlapping edges.";

String created = "Nice polygon! Let's resize and move it over a bit so that it is easier to work with.";

String centered = "That's better. We are now ready to start creating our data structure.";

String explanation1 = "We are going to step through the creation of a data structure that allows for the efficient identification of a point inside an arbitrarily sized polygon. Proposed by David Kirkpatrick in his 1983 paper \"Optimal search in planar subdivisions\", the creation of this structure relies on the ability to remove a constant fraction of vertices in each stage of the algorithm. In doing so, a directed acyclic graph, which can be queried in O(logn) time, is created.";

String explanation2 = "The creation of the data structure begins by triangulating the polygon and its surrounding area. Once triangulated, a set of independent vertices connected to <= 8 edges are identified, their connected triangles are removed, and the resulting holes are once again triangulated. This process is repeated until there is a single triangle remaining that encompasses the total area in which point location is desired.";

String explanation3 = "Ok? Let's begin! You'll notice that a play button has appeared at the bottom of the screen. Press it at any time to begin auto-playing the animation. Otherwise, continue to step through manually by pressing the space bar.";

String triangulate_poly = "First, we triangulate the original polygon and its convex hull.";
String add_outer_tri = "Next, we surround the outer area of the polygon with a large triangle. This outer triangle can be arbitrarily large to encompass as much potential space as your point location needs to cover.";
String triangulate_outer_tri = "Now, we triangulate the space between the triangulated polygon and the edges of the outer triangle.";
String before_begin1 = "Looking good. We can now begin to build our directed acyclic graph by identifying, removing, and re-triangulating sets of independent low degree vertices. The resulting graph is created and can be stored in O(n) time and space on the order of the number of vertices in the original polygon.";
String before_begin2 = "Hover over the triangles in the graph at any point in the creation process to see the graph connections made so far.";

String ildv_identified = "Identify a set of independent low degree vertices.";
String ildv_selected = "Select one of the vertices in the set and identify its surrounding triangles.";
String ildv_removed = "Remove the independent low degree vertex and its surrounding triangles.";
String retriangulate = "Re-triangulate the hole and connect the newly created triangles to the graph via directed edges to the triangles they replaced.";
String graph_complete = "Finally, we add the root triangle to the hierarchy, and our directed acyclic graph is complete!";

String place_point = "Place a point anywhere inside the colored triangle.";
String point_locating = "We will now traverse our directed acyclic graph to efficiently determine whether or not the point is located inside our original polygon.";
String point_inside = "The point was inside the original polygon!";
String point_outside = "The point was outside the original polygon.";

}
