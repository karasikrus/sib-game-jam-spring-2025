extends Node

enum GlobalStates {RUNNING, FREEZED}
@onready var currentState = GlobalStates.RUNNING

func freeze_updates():
	currentState = GlobalStates.FREEZED
	
