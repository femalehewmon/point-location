class SceneController {
	int sceneTimer;
	float scenePercentageStep;
	float scenePercentComplete;
	float sceneRelativePercentComplete;
	int SCENE_DURATION = 50;

	final String CREATE_POLYGON = "CREATE POLYGON";
	final String CENTER_AND_RESIZE_POLYGON = "CENTER AND RESIZE POLYGON";
	final String TRIANGULATE_POLY = "TRIANGULATE POLY";
	final String SURROUND_POLY_WITH_OUTER_TRI = "SURROUND POLY WITH OUTER TRI";
	final String TRIANGULATE_OUTER_TRI = "TRIANGULATE OUTER TRI";
	final String CREATE_KIRKPATRICK_DATA_STRUCT = "CREATE KP DATA STRUCT";
	final String DONE = "DONE";

	public SceneController() {
		this.currScene = CREATE_POLYGON;
		reset();
	}

	public void reset() {
		this.sceneTimer = 0;
		this.scenePercentageStep = 1.0/(float)SCENE_DURATION;
		this.scenePercentComplete = 0.0;
		this.sceneRelativePercentComplete = 0.0;
	}

	public boolean update() {
		boolean next_scene = false;
		sceneTimer += 1;
		if ( sceneTimer >= SCENE_DURATION ) {
			next_scene = true;
		}
		scenePercentComplete = (float)sceneTimer / (float)SCENE_DURATION;
		sceneRelativePercentComplete =
			1.0 / (sceneControl.SCENE_DURATION - sceneControl.sceneTimer);
		return next_scene;
	}

	public void previousScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				break;
			case CENTER_AND_RESIZE_POLYGON:
				this.currScene = CREATE_POLYGON;
				break;
			case TRIANGULATE_POLY:
				this.currScene = CENTER_AND_RESIZE_POLYGON;
				break;
			case SURROUND_POLY_WITH_OUTER_TRI:
				this.currScene = TRIANGULATE_POLY;
				break;
			case TRIANGULATE_OUTER_TRI:
				this.currScene = SURROUND_POLY_WITH_OUTER_TRI;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCT:
				this.currScene = TRIANGULATE_OUTER_TRI;
				break;
			case DONE:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCT;
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
				this.currScene = TRIANGULATE_POLY;
				break;
			case TRIANGULATE_POLY:
				this.currScene = SURROUND_POLY_WITH_OUTER_TRI;
				break;
			case SURROUND_POLY_WITH_OUTER_TRI:
				this.currScene = TRIANGULATE_OUTER_TRI;
				break;
			case TRIANGULATE_OUTER_TRI:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCT;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCT:
				this.currScene = DONE;
				break;
			case DONE:
				break;
		}
		console.log("Next scene " + this.currScene);
		reset();
	}

}
