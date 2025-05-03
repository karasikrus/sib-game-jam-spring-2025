extends Node
class_name DialogueManager

var currentDialogue : Dialogue
var currentLineIndex : int
var currentLine : DialogueLine

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
	
