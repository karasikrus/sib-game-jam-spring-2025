extends "res://scenes/movementNode/movement_node.gd"
class_name NextSceneNode
# Load the custom images for the mouse cursor.
var next_scene_move_icon = load("res://scenes/cursors/cursor_next_zone.png")
var default_icon = load("res://scenes/cursors/default_cursor.png")
@export var next_scene_name = "res://scenes/main/main.tscn"
@onready var is_cursor_in_transition_area = false
@onready var waiting_for_character = false
@onready var main_character : TemplateEntity = get_tree().get_first_node_in_group("MainCharacter") as TemplateEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_name.append_text(name)
	main_character.arrival_signal.connect(self.on_character_arrival)
	pass # Replace with function body.

func on_character_arrival():
	if waiting_for_character and is_available:
		Input.set_custom_mouse_cursor(null)
		LevelManager.load_specific_scene(next_scene_name)
	waiting_for_character = false
	

func _show_scene_transition_cursor():
	is_cursor_in_transition_area = true
	if not is_available:
		return
	Input.set_custom_mouse_cursor(next_scene_move_icon)
	pass

func _show_standard_cursor():
	is_cursor_in_transition_area = false
	Input.set_custom_mouse_cursor(default_icon)
	pass
	

func _input(event):
	if event is InputEventMouseButton and event.pressed and is_cursor_in_transition_area:
		waiting_for_character = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
