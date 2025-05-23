extends CanvasLayer
class_name MainMenu

var options_scene = preload("res://scenes/menu/options_menu.tscn")

func _ready():
	%PlayButton.pressed.connect(on_play_pressed)
	%OptionsButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)
	

func on_play_pressed():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	LevelManager.load_specific_scene("res://scenes/intro/intro.tscn")
	SceneTransition.open_screen()


func on_options_pressed():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	LevelManager.load_specific_scene("res://scenes/menu/options_menu.tscn")
	SceneTransition.open_screen()


func on_quit_pressed():
	get_tree().quit()

func on_options_closed(options_instance: Node):
	options_instance.queue_free()
