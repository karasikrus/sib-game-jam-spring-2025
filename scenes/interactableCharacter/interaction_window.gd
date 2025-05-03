extends Control


@export var interactable_character :InteractableCharacter = null

@onready var is_on_button = false

func mouse_on_button():
	is_on_button = true
	
func mouse_off_button():
	is_on_button = false


func pressed_hacked():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_HACK
	
func pressed_talk():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_TALK
	
	
func _input(event):
	if not self.visible:
		return
	if event is InputEventMouseButton and not is_on_button:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() :
			interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
			is_on_button = false
			self.visible = false
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
