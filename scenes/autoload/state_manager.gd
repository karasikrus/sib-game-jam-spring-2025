extends Node

enum GlobalStates {RUNNING, FREEZED}
@onready var currentState = GlobalStates.RUNNING

@onready var isMouseHighlightingObject = false

@onready var isMovingToInteract = false

func freeze_updates():
	currentState = GlobalStates.FREEZED
	
