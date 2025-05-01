extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	StateManager.currentState = StateManager.GlobalStates.FREEZED
	Dialogic.start("timeline_test") # Replace with function body.
	Dialogic.timeline_ended.connect(func(): StateManager.currentState = StateManager.GlobalStates.RUNNING)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
