extends MarginContainer
class_name DialogueOptionButton

signal option_pressed

@export var hoveredModulateColor : Color
@export var pressedModulateColor : Color

@onready var button: Button = %Button
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var isHovered : bool
var isDown : bool


func disable():
	visible = false
	process_mode = ProcessMode.PROCESS_MODE_DISABLED

func enable():
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	visible = true
	

func set_text(text : String):
	rich_text_label.text = "[left]" + text + "[/left]"

func reset():
	isHovered = false
	isDown = false
	updateDisplay()

func updateDisplay():
	if isDown:
		rich_text_label.modulate = pressedModulateColor
	elif isHovered:
		rich_text_label.modulate = hoveredModulateColor
	else:
		rich_text_label.modulate = Color.WHITE

func _on_button_mouse_entered() -> void:
	isHovered = true
	updateDisplay()


func _on_button_mouse_exited() -> void:
	isHovered = false
	updateDisplay()


func _on_button_button_down() -> void:
	isDown = true
	updateDisplay()


func _on_button_pressed() -> void:
	reset()
	option_pressed.emit()
