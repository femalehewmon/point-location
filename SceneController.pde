class SceneController {
	int sceneTimer;
	float scenePercentageStep;
	float scenePercentComplete;
	float sceneRelativePercentComplete;

	int DEFAULT_SCENE_DURATION = 85;
	int sceneDuration;

	final String CREATE_POLYGON = "CREATE POLYGON";
	final String CENTER_AND_RESIZE_POLYGON = "CENTER AND RESIZE POLYGON";
	final String CREATE_MESH = "CREATE MESH";
	final String TRIANGULATE_POLY = "TRIANGULATE POLY";
	final String SURROUND_POLY_WITH_OUTER_TRI = "SURROUND POLY WITH OUTER TRI";
	final String CREATE_KIRKPATRICK_DATA_STRUCT = "CREATE KP DATA STRUCT";
	final String POINT_LOCATION = "POINT LOCATION";
	final String DONE = "DONE";

	boolean sceneReady = false;
	boolean updateSceneOnKeyPress = false;

	public SceneController() {
		this.currScene = CREATE_POLYGON;
		this.sceneDuration = DEFAULT_SCENE_DURATION;
		reset();
	}

	public void restart() {
		reset();
		this.currScene = CREATE_MESH;
		console.log("Restarting animation");
	}

	public void reset() {
		this.sceneTimer = 0;
		this.scenePercentageStep = 1.0/(float)sceneDuration;
		this.scenePercentComplete = 0.0;
		this.sceneRelativePercentComplete = 0.0;
		this.sceneReady = false;
	}

	public void updateSceneDuration(float scale) {
		sceneDuration = DEFAULT_SCENE_DURATION / scale;
		console.log("New sceneDruation: " + sceneDuration);
	}

	public boolean update(boolean moveToNextScene) {
		boolean next_scene = false;
		sceneTimer += 1;
		if ( sceneTimer >= sceneDuration ) {
			next_scene = true;
		}
		scenePercentComplete = (float)sceneTimer / (float)sceneDuration;
		sceneRelativePercentComplete =
			1.0 / (sceneControl.sceneDuration - sceneControl.sceneTimer);
		sceneReady = true;
		if ( moveToNextScene && next_scene ) {
			nextScene();
		}
		return next_scene;
	}

	public void addTextScene( String text ) {
		setText(text);
	}

	public boolean update() {
		return update(false);
	}

	public void updateOnKeyPress() {
		sceneReady = true;
		console.log("updating on key press only ");
		updateSceneOnKeyPress = true;
	}

	public void keyWasPressed() {
		if ( updateSceneOnKeyPress ) {
			reset();
			nextScene();
			updateSceneOnKeyPress = false;
		}
	}

	public void previousScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				break;
			case CENTER_AND_RESIZE_POLYGON:
				this.currScene = CREATE_POLYGON;
				break;
			case CREATE_MESH:
				this.currScene = CENTER_AND_RESIZE_POLYGON;
				break;
			case TRIANGULATE_POLY:
				this.currScene = CREATE_MESH;
				break;
			case SURROUND_POLY_WITH_OUTER_TRI:
				this.currScene = TRIANGULATE_POLY;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCT:
				this.currScene = SURROUND_POLY_WITH_OUTER_TRI;
				break;
			case POINT_LOCATION:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCT;
				break;
			case DONE:
				this.currScene = POINT_LOCATION;
				break;
		}
		console.log("Next scene " + this.currScene);
		reset();

	}

	public void nextScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				this.currScene = CENTER_AND_RESIZE_POLYGON;
				break;
			case CENTER_AND_RESIZE_POLYGON:
				this.currScene = CREATE_MESH;
				break;
			case CREATE_MESH:
				this.currScene = TRIANGULATE_POLY;
				break;
			case TRIANGULATE_POLY:
				this.currScene = SURROUND_POLY_WITH_OUTER_TRI;
				break;
			case SURROUND_POLY_WITH_OUTER_TRI:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCT;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCT:
				this.currScene = POINT_LOCATION;
				break;
			case POINT_LOCATION:
				this.currScene = POINT_LOCATION;
				break;
			case DONE:
				break;
		}
		console.log("Next scene " + this.currScene);
		reset();
	}

String create = "Click anywhere within the bounds of the visualization to create a polygon with non-overlapping edges. Alternatively, click the DEMO button below to use a polygon that we have predefined.";

String created = "Nice polygon! Let's resize and move it over a bit so that it is easier to work with.";

String centered = "That's better. We are now ready to start creating our data structure.";

String explanation1 = "We are going to step through the creation of a data structure that allows for the efficient identification of a points location in an arbitrarily sized polygon. Developed by Kirkpatrick in 1963, this data structure allows for both the efficient time and storage.";

String explanation2 = "The data structure is created by triangulating the polygon and its surrounding area. Once triangulated, independent low degree vertices, that is, vertices that are connected to <= 7 edges, are identified and their connecting triangles are removed. The hole that is left after the triangles are removed is once again triangulated. This process is repeated until there is a single triangle remaining that encompasses the area of the original outer triangle.";

String begin = "Ok? Let's begin!";

String triangulate_poly = "First, we triangulate the original polygon.";
String add_outer_tri = "Next, we surround the outer area of the polygon with a large triangle. This outer triangle can be arbitarily large to cover as much potential space as you point location needs to cover.";
String triangulate_outer_tri = "Now, we triangulate the space between the triangulated polygon and the edges of the outer triangle.";
String before_begin = "Looking good. We can now begin to build our DAG by identifying, removing, and retriangulating sets of independent low degree vertices";

String ildv_identified = "Identify a set of independent low degree vertices";
String ildv_selected = "Select one of those vertices";
String ildv_removed = "Remove the independent low degree vertex and its surrounding triangles";
String retriangulate = "Retriangulate the hole";

}
