extends Control


@export var interactable_character :InteractableCharacter = null

@onready var is_on_button = false


func main_character_arrived():
	if interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.PRESSED_HACK:
		interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
		self.visible = false
		is_on_button = false
	elif interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.PRESSED_TALK:
		interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
		self.visible = false
		is_on_button = false
	interactable_character.waiting_for_character = false

func mouse_on_button():
	is_on_button = true
	
func mouse_off_button():
	is_on_button = false


func pressed_hacked():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_HACK
	interactable_character.waiting_for_character = true
	
func pressed_talk():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_TALK
	interactable_character.waiting_for_character = true
	
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
	var main_character : TemplateEntity = get_tree().get_first_node_in_group("MainCharacter") as TemplateEntity
	main_character.arrival_signal.connect(self.main_character_arrived)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
