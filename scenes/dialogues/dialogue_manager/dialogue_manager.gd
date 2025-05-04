extends Node
class_name DialogueManager

signal dialogue_started
signal dialogue_ended

@onready var dialog_options_box: DialogueOptionsBox = %DialogOptionsBox

var currentDialogueOptionsBlock : DialogueOptionsBlock
var currentDialogue : Dialogue
var currentLineIndex : int
var currentLine : DialogueLine
var isInExitDialogue : bool

func _ready() -> void:
	dialog_options_box.option_a.connect(play_option_a)
	dialog_options_box.option_b.connect(play_option_b)
	dialog_options_box.option_c.connect(play_option_c)
	dialog_options_box.option_exit.connect(play_option_exit)
	

func play_options_block(optionsBlock : DialogueOptionsBlock, playIntroLine : bool = false):
	currentDialogueOptionsBlock = optionsBlock
	if playIntroLine:
		play_dialogue(optionsBlock.introDialogue)
		return
	dialog_options_box.setDialogueOptionsBlock(currentDialogueOptionsBlock)

func play_option_a():
	play_dialogue(currentDialogueOptionsBlock.optionA.dialogue)

func play_option_b():
	play_dialogue(currentDialogueOptionsBlock.optionB.dialogue)

func play_option_c():
	play_dialogue(currentDialogueOptionsBlock.optionC.dialogue)
	
func play_option_exit():
	isInExitDialogue = true
	play_dialogue(currentDialogueOptionsBlock.optionExit.dialogue)


func play_dialogue(dialogue):
	currentDialogue = dialogue
	currentLineIndex = 0
	play_line(currentLineIndex)

func play_line(index : int):
	currentLine = currentDialogue.lines[index]
	DialogueSignalBus.play_dialog_line.emit(currentLine)
	DialogueSignalBus.dialog_line_finished.connect(on_line_finished)

func on_line_finished(line):
	if currentLine == line:
		if currentDialogue.lines.size() > currentLineIndex + 1:
			currentLineIndex += 1
			play_line(currentLineIndex)
		elif isInExitDialogue:
			isInExitDialogue = false
			dialogue_ended.emit()
		else:
			play_options_block(currentDialogueOptionsBlock)
			
	
