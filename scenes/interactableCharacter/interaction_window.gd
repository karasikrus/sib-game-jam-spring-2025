extends Control


@export var interactable_character :InteractableCharacter = null

@onready var is_on_button = false
@onready var hack_button = $Hack
@onready var hack_window = $HackWindow
@onready var riddle_text_label = $HackWindow/RiddleText
@onready var riddle_answer_input : TextEdit = $HackWindow/RiddleAnswer
@onready var submit_answer = $HackWindow/SuccesfulHackButton
@onready var talk_button = $Talk
@onready var talk_window = null

@onready var riddle_text : String = ""
@onready var riddle_answer : String = ""

@onready var hints_label = $HackWindow/Node2D/HintsText

#audio
#Don't have time to properly load them and store, so hacky-wacky for now
@export var audio_streams : Array[AudioStream] = []

enum AUDIO_STATE{
	HACK_WINDOW_CLOSE,
	HACK_WINDOW_OPEN,
	HACK_WINDOW_HELPER_CLICK,
	HACK_RIGHT_ANSWER,
	HACK_TIP_RECIEVED,
	HACK_TIPS_ARE_OVER,
	HACK_WRONG_ANSWER,
}

var audio_names = [
	"HackClose",
	"HackOpen",
	"HelperClick",
	"RightAnswer",
	"TipRecieved",
	"TipsAreOver",
	"WrongAnswer",
]

@onready var audio_player : AudioStreamPlayer =$HackWindow/AudioPlayer 
@onready var audio_player_for_tip : AudioStreamPlayer = $HackWindow/AudioPlayerForTips #second one as we can recieve tip and get sound of counter increment at the same time

func hide_talk_hack_buttons():
	hack_button.visible = false
	talk_button.visible = false

func show_talk_hack_buttons():
	hack_button.visible = true
	talk_button.visible = true

func on_hack_attempt():
	if(riddle_answer_input.text.to_lower() == riddle_answer.to_lower()):
		on_hack_succesful()
	else:
		on_hack_unsuccesful()

func on_hack_unsuccesful():
	play_sound(AUDIO_STATE.HACK_WRONG_ANSWER)

func on_hack_succesful():
	interactable_character.unlock_nodes()
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
	interactable_character.is_hacked = true
	#could be replace with default state if there no more logic
	show_talk_hack_buttons()
	hack_window.visible = false
	submit_answer.visible = false
	self.visible = false
	StateManager.currentState = StateManager.GlobalStates.RUNNING
	play_sound(AUDIO_STATE.HACK_RIGHT_ANSWER)


func reset_to_defult_state():
	self.visible = false
	hack_window.visible = false
	#talk_window.visible = false
	hack_button.visible = true
	talk_button.visible = true
	StateManager.currentState = StateManager.GlobalStates.RUNNING

func main_character_arrived():
	if interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.PRESSED_HACK:
		interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.HACKING
		hide_talk_hack_buttons()
		hack_window.visible = true
		is_on_button = false
		StateManager.currentState = StateManager.GlobalStates.FREEZED
		play_sound(AUDIO_STATE.HACK_WINDOW_OPEN)
	elif interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.PRESSED_TALK:
		interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
		interactable_character.start_dialogue()
		self.visible = false
		is_on_button = false
		#StateManager.currentState = StateManager.GlobalStates.FREEZED
	interactable_character.waiting_for_character = false
	

func mouse_on_button():
	is_on_button = true
	
func mouse_off_button():
	is_on_button = false


func play_sound(state : AUDIO_STATE):
	audio_player.stream = audio_streams[state]
	audio_player.play()

func play_sound_for_tip(state : AUDIO_STATE):
	audio_player_for_tip.stream = audio_streams[state]
	audio_player_for_tip.play()

func pressed_hacked():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_HACK
	interactable_character.waiting_for_character = true
	
	
func pressed_talk():
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_TALK
	interactable_character.waiting_for_character = true
	
func _input(event):
	if not self.visible:
		return
	if event is InputEventMouseButton and not is_on_button:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if (interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.HACKING):
				play_sound(AUDIO_STATE.HACK_WINDOW_CLOSE)
			interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.IDLE
			is_on_button = false
			reset_to_defult_state()

		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main_character : TemplateEntity = get_tree().get_first_node_in_group("MainCharacter") as TemplateEntity
	main_character.arrival_signal.connect(self.main_character_arrived)
	riddle_text = interactable_character.riddle_text
	riddle_answer = interactable_character.riddle_answer
	riddle_text_label.text = riddle_text
	reset_to_defult_state()
	pass # Replace with function body.

func request_more_hints() -> void:
	var current_hint_index = interactable_character.current_hint
	if current_hint_index ==interactable_character.hints.size():
		play_sound_for_tip(AUDIO_STATE.HACK_TIPS_ARE_OVER)
		return
	interactable_character.current_click_count += 1
	play_sound(AUDIO_STATE.HACK_WINDOW_HELPER_CLICK)
	if interactable_character.hints_number_clicks[current_hint_index] == interactable_character.current_click_count:
		current_hint_index += 1
		interactable_character.current_hint = current_hint_index
		interactable_character.current_click_count = 0
		play_sound_for_tip(AUDIO_STATE.HACK_TIP_RECIEVED)
	var result_text = ""
	for i in range(0, interactable_character.current_hint):
		result_text += interactable_character.hints[i]
		result_text += "\n"
	hints_label.text = result_text
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
