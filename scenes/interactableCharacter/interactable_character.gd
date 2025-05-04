extends CharacterBody2D
class_name InteractableCharacter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var entity_path : String = "res://scenes/InteractableCharacter/"

@onready var interaction_area = $InteractionArea
@onready var is_highlited = false

@onready var waiting_for_character = false

@export var nodes_to_unlock : Array[MovementNode] = []

@onready var main_character : TemplateEntity = get_tree().get_first_node_in_group("MainCharacter") as TemplateEntity
@export var hints_path : String
@onready var hints : Array[String] = []
@onready var hints_state : Array[bool] = []
@onready var current_hint = 0
@onready var current_click_count = 0
@export var hints_number_clicks : Array[int] = [1, 5, 10, 10, 10, 25, 25, 50] #still changable from editor

@export var animation_start_name = "InteractableCharacter"
enum INTERACTION_STATE{
	IDLE,
	HIGHLIGHTED,
	PRESSED_INTERCATION,
	PRESSED_TALK,
	PRESSED_HACK,
	TALKING,
	HACKING,
	INTERACTION_STATE_COUNT,
}

@onready var interaction_state : INTERACTION_STATE = INTERACTION_STATE.IDLE
@onready var interaction_window = $InteractionWindow
@export var riddle_text : String = ""
@export var riddle_answer : String = ""
@onready var is_hacked = false
# Called when the node enters the scene tree for the first time.
@onready var sprite = $Sprite2D

@onready var need_to_start_idle = 0.0

@export var dialogue_options_block : DialogueOptionsBlock

func set_mouse_on_object():
	if interaction_state == INTERACTION_STATE.IDLE:
		interaction_state = INTERACTION_STATE.HIGHLIGHTED
	StateManager.isMouseHighlightingObject = true
	pass

func set_mouse_off_object():
	if interaction_state == INTERACTION_STATE.HIGHLIGHTED:
		interaction_state = INTERACTION_STATE.IDLE
	StateManager.isMouseHighlightingObject = false
	pass

func unlock_nodes():
	for node in nodes_to_unlock:
		node.is_available = true

func _input(event):
	
	#if interaction_state >= INTERACTION_STATE.PRESSED_INTERCATION:
		#that is button problem now
		#return
	
	if event is InputEventMouseButton and event.pressed:
		print(interaction_state)
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and interaction_state == INTERACTION_STATE.HIGHLIGHTED:
			interaction_state = INTERACTION_STATE.PRESSED_INTERCATION
			interaction_window.visible = true


func parse_hints():
	var hints_txt = FileAccess.open(hints_path, FileAccess.READ)
	while not hints_txt.eof_reached(): # iterate through all lines until the end of file is reached
		var line = hints_txt.get_line()
		hints.append(line)
	hints_txt.close()

func _ready() -> void:
	init_audio_streams()
	#audio_player.play()
	start_idle_animation()
	parse_hints()
	sprite.material = sprite.material.duplicate() #cringe, godot can not set variable per instance, so we duplicating material
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(StateManager.currentState == StateManager.GlobalStates.FREEZED):
		animation_player.stop(true)
		audio_player.stream_paused = true
		return
	
	if(randf() > 0.5):
		need_to_start_idle += delta
	if(need_to_start_idle > 1.0):
		need_to_start_idle = 0.0
		animation_state = ANIMATION_STATE.IDLE
		update_animation()
	sprite.material.set_shader_parameter("is_highlighted", interaction_state == INTERACTION_STATE.HIGHLIGHTED)
	update_audio_stream_player()
	

func start_dialogue():
	var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
	dialogue_manager.play_options_block(dialogue_options_block)
	dialogue_manager.dialogue_ended.connect(on_dialogue_end)

func on_dialogue_end():
	pass

#region Animations

enum ANIMATION_STATE{
	IDLE,
	WALK_RIGHT,
	WALK_LEFT,
	ANIMATION_STATE_COUNT,
}

var animation_names = [
	"idle",
	"walk_right",
	"walk_left"
]

@onready var animation_state : ANIMATION_STATE = ANIMATION_STATE.IDLE
	

func update_animation():
	
	animation_player.play(animation_start_name + "/" + animation_names[animation_state])
	pass


func start_idle_animation():
	animation_state = ANIMATION_STATE.IDLE

func start_walk_animation_right():
	#feel free to add direction logic
	animation_state = ANIMATION_STATE.WALK_RIGHT

func start_walk_animation_left():
	animation_state = ANIMATION_STATE.WALK_LEFT
	
#endregion

#region Sound

static func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


enum AUDIO_STATE{
	IDLE,
	AUDIO_STATE_COUNT,
}
var audio_names = [
	"idle",
]
var audio_is_looping = [
	true
]
static var audio_streams = []
static var initialized_stream = false
@onready var audio_state : AUDIO_STATE = AUDIO_STATE.IDLE
#sorry, need to guarantee, that we are initing sound in one thread
static var audio_mutex: Mutex = Mutex.new()


func init_audio_streams():
	if(initialized_stream):
		return
	if(audio_mutex.try_lock()):
		for index in range(AUDIO_STATE.AUDIO_STATE_COUNT):
			var name = (entity_path + audio_names[index] + ".mp3")
			var is_looping = audio_is_looping[index]
			audio_streams.push_back(load_mp3(name))
			audio_streams.back().set_loop(is_looping)
		initialized_stream = true
		audio_mutex.unlock()
		
		
func update_audio_stream_player():
	if(audio_player.stream_paused == true):
		audio_player.stream_paused = false
	#might be quite sharp change, but should work for now
	var current_playing_stream = audio_player.stream.resource_path.get_file().get_basename()
	if (current_playing_stream != audio_names[audio_state]):
		audio_player.set_stream(audio_streams[audio_state])
		audio_player.play()
		
func play_idle():
	audio_state = AUDIO_STATE.IDLE

#endregion
