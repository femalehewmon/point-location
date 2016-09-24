final boolean DEMO = false;
final boolean DEBUG = false;

// Global variables
boolean animationPaused;
boolean animationReset;
ArrayList<Integer> animatingPolygons;
boolean firstRun;

// Helper global classes
SceneController sceneControl;
CompGeoHelper compGeoHelper;

// Variables for interaction with polygons (hover effect)
PGraphics pickbuffer;
ArrayList<Message> messages;
MSG_TRIANGLE = "MSG_TRIANGLE";
class Message {
	String k;
	String v;
}

// Views
PolygonCreationView pcreateView;
KirkpatrickMeshView kpView;
LayeredGraphView graphView;
PointLocationView plocateView;

// Float.X_INFINITY throwing error, so self define
POSITIVE_INFINITY = 9999999;
NEGATIVE_INFINITY = -9999999;

void setup() {

	// set size of visualization area with a fixed aspect ratio
	float border = $("#visualization").height() * 0.05;
	float aspectRatio = 16.0 / 9.0;
	float wtmp = $("#visualization").width() - border;
	float htmp = wtmp / aspectRatio;
	wtmp = htmp * aspectRatio;
	size(wtmp, htmp);

	// initialize global helper classes
	sceneControl = new SceneController();
	compGeoHelper = new CompGeoHelper();

	// initialize mouse interaction helpers
	messages = new ArrayList<Message>();
	pickbuffer = createGraphics(width, height);
	animatingPolygons = new ArrayList<Integer>();

	// create views
	float padding = border/2.0;
	float xPad = width-padding;
	float yPad = height-padding;
	pcreateView = new PolygonCreationView(padding, padding, xPad, yPad);
	kpView = new KirkpatrickMeshView(padding, padding, width/2.0, yPad);
	graphView = new LayeredGraphView(width/2.0, padding, width-padding, yPad);
	plocateView = new PointLocationView(padding, padding, width-padding, yPad);

	pcreateView.visible = true;
	kpView.visible = false;
	graphView.visible = false;
	plocateView.visible = false;

	animationPaused = false;
	animationReset = false;
	firstRun = true;
}

void setText(String text) {
	// set directly to html
	$("#explanation-text").text(text);
}

void updateAnimationSpeed(String rate) {
	console.log(rate);
	sceneControl.updateSceneDuration(float(rate));
}

void startDemo() {
	pcreateView.demo();
}

void playAnimation() {
	animationPaused = false;
	sceneControl.updateOnSceneDuration(true);
	$("#play-controls").hide();
	$("#pause-controls").show();
}

void pauseAnimation() {
	animationPaused = true;
	sceneControl.updateOnKeyPress();
	$("#play-controls").show();
	$("#pause-controls").hide();
}

void previousScene() {
	console.log("previous level");
	kpView.rollback();
	if ( kpView.initialized ) {
		graphView.rollback();
	}
}

void replayAnimation() {
	sceneControl.restart();
	showReplayControls(false);
	animationReset = true;
	firstRun = false;
}

void showReplayControls(boolean show) {
	if ( show ) {
		$("#replay-controls").show();
		$("#pause-controls").hide();
		$("#play-controls").hide();
	} else {
		$("#replay-controls").hide();
		if ( animationPaused ) {
			$("#play-controls").show();
		} else {
			$("#pause-controls").show();
		}
	}
}

void showPlaybackControls(boolean show) {
	if( show ) {
		$("#sidebar-bottom").show();
	} else {
		$("#sidebar-bottom").hide();
	}
}

void showPlaybackButton(boolean show) {
	if( show ) {
		$(".playback-button").show();
	} else {
		$(".playback-button").hide();
	}
}

void browserKeyPressed() {
	// block progressing scene if a polygon is still animating
	if ( animatingPolygons.size() == 0 ) {
		sceneControl.onKeyPress();
	} else{
		console.log("still animating..");
	}
}

void draw() {
	background(245, 245, 245);
	pickbuffer.background(255);

	switch( sceneControl.currScene ) {
		case sceneControl.CREATE_POLYGON:
			if ( !sceneControl.sceneReady ) {
				// reset poly creation view if first time entering scene
				pcreateView.visible = true;
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = false;

				pcreateView.reset();

				if ( DEMO ) {
					pcreateView.demo();
					pcreateView.update();
				}

				sceneControl.ready();
			}
			// do not update scene until polygon is finalized
			if ( pcreateView.polygon.finalized ) {
				$("#demo-controls").hide();
				// show polygon centering and scaling
				if( pcreateView.isDemo || sceneControl.update() ) {
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.CREATE_KIRKPATRICK_DATA_STRUCTURE:
			if ( !sceneControl.sceneReady ) {
				// reconfigure view to show playback controls
				showPlaybackControls(true);
				showPlaybackButton(false);
				pauseAnimation(true);

				if ( firstRun ) {
					// create kirkpatrick data structure
					LayeredMesh kpDataStruct =
						compGeoHelper.createKirkpatrickDataStructure(
								pcreateView.polygon, pcreateView.outerTri);
					kpView.setMesh(kpDataStruct,
							pcreateView.polygon,
							pcreateView.outerTri);
					graphView.setMesh(kpDataStruct,
							pcreateView.polygon);
				}

				pcreateView.visible = false;
				kpView.visible = true;
				graphView.visible = true;
				plocateView.visible = false;

				kpView.reset();
				kpView.update();
				graphView.reset();
				sceneControl.ready();
				if ( animationReset || pcreateView.isDemo ) {
					kpView.update();
				}
			}

			if ( sceneControl.update() ) {
				boolean notFinalized = kpView.update();
				if ( kpView.initialized ) {
					notFinalized = graphView.update() || notFinalized;
				}
				if ( notFinalized) {
					sceneControl.reset();
					if ( kpView.finalized ) {
						showPlaybackControls(false);
						sceneControl.enableAutoUpdate();
					}
				} else {
					showPlaybackControls(true);
					showPlaybackButton(false);
					pauseAnimation();
					sceneControl.nextScene();
				}
			}
			break;
		case sceneControl.POINT_LOCATION:
			if ( !sceneControl.sceneReady ) {
				pcreateView.visible = false;
				kpView.visible = false;
				graphView.visible = false;
				plocateView.visible = true;

				plocateView.reset();
				plocateView.setMesh(
						kpView.mesh, graphView.mesh, pcreateView.polygon );

				sceneControl.ready();
			}

			if( plocateView.pointSelected != null ) {
				showPlaybackControls(true);
				if ( sceneControl.update() ) {
					if ( plocateView.finalized ) {
						showReplayControls(false);
						showPlaybackControls(false);
						plocateView.reset();
						sceneControl.reset();
						// update once to avoid showing full hierarchy on reset
						plocateView.update();
					} else {
						plocateView.update();
						sceneControl.reset();
						if ( plocateView.finalized ) {
							// final scene
							showReplayControls(true);
							sceneControl.updateOnKeyPress();
						}
					}
				}
			} else if ( !plocateView.initialized ) {
				// full graph hierarchy shown for one scene
				if ( sceneControl.update() ) {
					plocateView.update();
					showPlaybackButton(true);
					showPlaybackControls(false);
				}
			}
			break;
	}

	pcreateView.render();
	plocateView.render();
	kpView.render();
	graphView.render();

	messages.clear();

	graphView.mouseUpdate();
	kpView.mouseUpdate();
	plocateView.mouseUpdate();

	if ( animationPaused ) {
		sceneControl.updateOnKeyPress();
	}
}

void mousePressed( ) {
	if (mouseButton == LEFT) {
		pcreateView.onMousePress();
		plocateView.onMousePress();
	}
}

void mouseReleased() {
	pcreateView.onMouseRelease();
}

