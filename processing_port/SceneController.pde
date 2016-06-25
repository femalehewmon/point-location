class SceneController {

	int sceneTimer;
	float scenePercentComplete;
	float scenePercentageStep;
	int SCENE_DURATION = 200;

	final String CREATE_POLYGON = "CREATE POLYGON";
	final String CENTER_AND_RESIZE_POLYGON = "CENTER AND RESIZE POLYGON";
	final String CREATE_KIRKPATRICK_DATA_STRUCT = "CREATE KP DATA STRUCT";
	final String ANIMATE_DATA_STRUCT_CREATION = "ANIMATE KP DATA STRUCT";

	public SceneController() {
		this.currScene = CREATE_POLYGON;
		this.sceneTimer = 0;
	}

	public void update() {
		sceneTimer += 1;
		if ( sceneTimer >= SCENE_DURATION ) {
			nextScene();
		}
		scenePercentComplete = (float)sceneTimer / (float)SCENE_DURATION;
	}

	public void nextScene() {
		console.log("Next scene");
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				this.currScene = CENTER_AND_RESIZE_POLYGON;
				break;
			case CENTER_AND_RESIZE_POLYGON:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCT;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCT:
				break;
		}
		this.scenePercentageStep = 1.0 / (float) SCENE_DURATION;
		sceneTimer = 0;
	}

}
