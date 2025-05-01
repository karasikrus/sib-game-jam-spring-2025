extends Node


@onready var current_scene = "res://scenes/menu/main_menu.tscn" 
@onready var current_scene_index = 0

#our option menu now is cringe
var scene_list = [
	"res://scenes/menu/main_menu.tscn",
	"res://scenes/menu/options_menu.tscn",
	"res://scenes/main/main.tscn",
]

func reload_scene():
	get_tree().change_scene_to_file(scene_list[current_scene_index])

func load_specific_scene(name : String):
	var index : int = 0
	index = scene_list.find(name)
	if(index != -1):
		current_scene_index = index
		get_tree().change_scene_to_file(scene_list[current_scene_index])
	
func move_to_next_scene():
	current_scene_index += 1
	get_tree().change_scene_to_file(scene_list[current_scene_index])
