class SceneController {

	int sceneTimer;
	float scenePercentageStep;
	float scenePercentComplete;
	float sceneRelativePercentComplete;
	int SCENE_DURATION = 200;

	final String CREATE_POLYGON = "CREATE POLYGON";
	final String CENTER_AND_RESIZE_POLYGON = "CENTER AND RESIZE POLYGON";
	final String CREATE_KIRKPATRICK_DATA_STRUCT = "CREATE KP DATA STRUCT";
	final String ANIMATE_DATA_STRUCT_CREATION = "ANIMATE KP DATA STRUCT";

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

	public void update() {
		sceneTimer += 1;
		if ( sceneTimer >= SCENE_DURATION ) {
			nextScene();
		}
		scenePercentComplete = (float)sceneTimer / (float)SCENE_DURATION;
		sceneRelativePercentComplete =
			1.0 / (sceneControl.SCENE_DURATION - sceneControl.sceneTimer);
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
		reset();
	}

}
