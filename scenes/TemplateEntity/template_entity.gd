extends CharacterBody2D
class_name TemplateEntity
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var entity_path : String = "res://scenes/TemplateEntity/"

@export var movement_nodes :  MovementNodes = null
@export var starting_node : MovementNode = null
@onready var current_node : MovementNode = null
@onready var next_node : MovementNode = null
@onready var next_nodes : Array[MovementNode] = []
@export var movement_velocity = 1000.0
@onready var movement_timer = $MovementTimer
@onready var time_to_next_node = -1.0

signal arrival_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_audio_streams()
	start_idle_animation()
	#audio_player.play()
	global_position = starting_node.global_position
	current_node = starting_node
	next_node = starting_node
	next_nodes = []
	movement_timer.timeout.connect(move_end_callback)
	start_idle_animation()
	pass # Replace with function body.



# при клике стартуем по набору точек
# как таймер выходит переходим на другую
# если в процессе еще раз нажали, то доходим
# до текущей цели и стартуем заново, но второе что-то пока лень делать
func _input(event):
	if StateManager.currentState == StateManager.GlobalStates.FREEZED:
		return
	if event is InputEventMouseButton and !StateManager.isMouseHighlightingObject:
		if movement_timer.time_left > 0 or !next_nodes.is_empty():
			return
		var closest_node_to_click = movement_nodes.get_closest_available_node_to_position(get_global_mouse_position())
		
		if not closest_node_to_click.is_available:
			#node is blocked
			return
		next_nodes = movement_nodes.get_list_of_nodes_to_get_from_a_to_b(current_node, closest_node_to_click).duplicate()
		if !next_nodes.is_empty():
			next_node = next_nodes.pop_front()
			var next_node_vector = next_node.global_position - current_node.global_position
			var distance_to_next_node = next_node_vector.length() 
			var time = distance_to_next_node / movement_velocity
			time_to_next_node = time
			movement_timer.start(time)
		else:
			arrival_signal.emit()
		
		

func process_move_to_next_node(delta: float):

	if(next_node == current_node):
		return
	global_position = lerp(next_node.global_position, current_node.position, movement_timer.time_left / time_to_next_node)
	return 

func move_end_callback():
	if next_nodes.size() == 0:
		current_node = next_node
		arrival_signal.emit()
		start_idle_animation()
		return
	current_node = next_node
	next_node = next_nodes.pop_front()
	var next_node_vector = next_node.global_position - current_node.global_position
	if next_node_vector.x > 0:
		start_walk_animation_right()
	else:
		start_walk_animation_left()
		
	var distance_to_next_node = next_node_vector.length() 
	var time = distance_to_next_node / movement_velocity
	time_to_next_node = time
	movement_timer.start(time)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(StateManager.currentState == StateManager.GlobalStates.FREEZED):
		animation_player.stop(true)
		audio_player.stream_paused = true
		return
	process_move_to_next_node(delta)
	#update_audio_stream_player()
	update_animation()


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
	animation_player.play(animation_names[animation_state])
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
