extends MarginContainer
class_name TextBubble

@export var dialogueCharacter : DialogueCharacter

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var timer: Timer = %Timer

var currentLine : DialogueLine

func _ready():
	DialogueSignalBus.play_dialog_line.connect(try_playing_line)
	audio_stream_player.finished.connect(on_finished)
	timer.timeout.connect(on_finished)

func try_playing_line(line : DialogueLine):
	if line.character.id == dialogueCharacter.id:
		play_line(line)

func play_line(line : DialogueLine):
	currentLine = line
	rich_text_label.text = "[center]" + line.text + "[/center]"
	visible = true
	if line.voiceOver != null:
		audio_stream_player.stream = line.voiceOver
		audio_stream_player.play()
	else:
		timer.start()

func on_finished():
	visible = false
	DialogueSignalBus.dialog_line_finished.emit(currentLine)
