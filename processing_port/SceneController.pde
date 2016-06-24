class SceneController {

	int sceneTimer;
	final int SCENE_DURATION = 500;

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
	}

	public void nextScene() {
		switch ( this.currScene ) {
			case CREATE_POLYGON:
				this.currScene = CENTER_AND_RESIZE_POLYGON;
				break;
			case CENTER_AND_RESIZE_POLYGON:
				this.currScene = CREATE_KIRKPATRICK_DATA_STRUCTURE;
				break;
			case CREATE_KIRKPATRICK_DATA_STRUCTURE:
				break;
		}
		sceneTimer = 0;
	}

}
