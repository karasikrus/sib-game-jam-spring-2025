extends Node2D

@export var dialogue : Dialogue

@onready var dialogue_manager: DialogueManager = $DialogueManager

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		dialogue_manager.play_dialogue(dialogue)
		
		
	
