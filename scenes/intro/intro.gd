extends Node2D

@onready var audio_player = $AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = intro_pictures[0]
	audio_player.play()
	pass # Replace with function body.

@export var intro_pictures : Array[Texture]= []

var current_picture = 0

var timer = 0.0
@onready var audio_time = 32.0
@onready var show_for = audio_time / 4.0
@onready var sprite = $Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= show_for:
		current_picture += 1
		timer = 0.0
	if(current_picture == intro_pictures.size()):
		LevelManager.load_specific_scene("res://scenes/zone1/zone1.tscn")
		SceneTransition.open_screen()
	else:
		sprite.texture = intro_pictures[current_picture]
	pass
