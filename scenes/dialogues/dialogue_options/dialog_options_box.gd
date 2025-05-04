extends Control
class_name DialogueOptionsBox

signal option_a
signal option_b
signal option_c
signal option_exit

@onready var dialogue_option_c: DialogueOptionButton = %DialogueOptionC
@onready var dialogue_option_b: DialogueOptionButton = %DialogueOptionB
@onready var dialogue_option_a: DialogueOptionButton = %DialogueOptionA
@onready var dialogue_option_exit: DialogueOptionButton = %DialogueOptionExit

var currentDialogueOptionsBlock : DialogueOptionsBlock

func _ready() -> void:
	dialogue_option_a.option_pressed.connect(option_a_pressed)
	dialogue_option_b.option_pressed.connect(option_b_pressed)
	dialogue_option_c.option_pressed.connect(option_c_pressed)
	dialogue_option_exit.option_pressed.connect(option_exit_pressed)
	disable()

func disable():
	dialogue_option_a.disable()
	dialogue_option_b.disable()
	dialogue_option_c.disable()
	dialogue_option_exit.disable()

func setDialogueOptionsBlock(dialogueOptionsBlock : DialogueOptionsBlock):
	currentDialogueOptionsBlock = dialogueOptionsBlock
	updateDialogueButton(dialogue_option_exit, currentDialogueOptionsBlock.optionExit)
	updateDialogueButton(dialogue_option_a, currentDialogueOptionsBlock.optionA)
	updateDialogueButton(dialogue_option_b, currentDialogueOptionsBlock.optionB)
	updateDialogueButton(dialogue_option_c, currentDialogueOptionsBlock.optionC)
	

func updateDialogueButton(dialogueOptionButton: DialogueOptionButton, dialogueOption : DialogueOption):
	if dialogueOption != null:
		dialogueOptionButton.enable()
		dialogueOptionButton.set_text(dialogueOption.optionText)
	else:
		dialogueOptionButton.disable()

func option_a_pressed():
	disable()
	option_a.emit()

func option_b_pressed():
	disable()
	option_b.emit()

func option_c_pressed():
	disable()
	option_c.emit()

func option_exit_pressed():
	disable()
	option_exit.emit()

	
