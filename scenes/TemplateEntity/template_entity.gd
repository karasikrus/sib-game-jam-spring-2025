extends CharacterBody2D
class_name TemplateEntity
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var entity_path : String = "res://scenes/TemplateEntity/"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_audio_streams()
	start_idle_animation()
	audio_player.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(StateManager.currentState == StateManager.GlobalStates.FREEZED):
		animation_player.stop(true)
		audio_player.stream_paused = true
		return
	var random_value : float = randf()
	if(random_value > 0.1):
		start_idle_animation()
	else:
		start_walk_animation()
	update_audio_stream_player()
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
	var current_animation = animation_player.get_current_animation()
	if(current_animation != animation_names[animation_state]):
		animation_player.play(animation_names[animation_state])

func start_idle_animation():
	animation_state = ANIMATION_STATE.IDLE

func start_walk_animation():
	#feel free to add direction logic
	animation_state = ANIMATION_STATE.WALK_RIGHT

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
