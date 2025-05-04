extends Control


@export var interactable_character :InteractableCharacter = null

@onready var is_on_button = false
@onready var hack_button = $Control/Control/Hack
@onready var hack_window = $Control/HackWindow
@onready var riddle_text_label = $Control/HackWindow/RiddleText
@onready var riddle_answer_input : TextEdit = $Control/HackWindow/Sprite2D2/RiddleAnswer
@onready var submit_answer = $Control/HackWindow/SuccesfulHackButton
@onready var talk_button = $Control/Control/Talk
@onready var talk_window = null

@onready var riddle_text : String = ""
@onready var riddle_answer : String = ""

@onready var hints_label = $Control/HackWindow/Node2D/HintsText

@onready var request_hint_button = $Control/HackWindow/Node2D/RequestHelp

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


@onready var audio_player : AudioStreamPlayer =$Control/HackWindow/AudioPlayer 
@onready var audio_player_for_hint_request : AudioStreamPlayer = $Control/HackWindow/AudioPlayerHintsRequest
@onready var audio_player_for_tip : AudioStreamPlayer = $Control/HackWindow/AudioPlayerForTips #second one as we can recieve tip and get sound of counter increment at the same time

@onready var hint_appearance_timer = $Control/HackWindow/Node2D/HintAppearanceTimer
@onready var idle_input_timer = $Control/HackWindow/Node2D/IdleInputSymbolTimer
@onready var is_input_symbol_rendered = false



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
		start_hint_input_idle_timer()
		hack_window.visible = true
		is_on_button = false
		StateManager.currentState = StateManager.GlobalStates.FREEZED
		play_sound(AUDIO_STATE.HACK_WINDOW_OPEN)
	elif interactable_character.interaction_state == InteractableCharacter.INTERACTION_STATE.PRESSED_TALK:
		interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.TALKING
		reset_to_defult_state()
		interactable_character.start_dialogue()
		self.visible = false
		is_on_button = false
		StateManager.currentState = StateManager.GlobalStates.FREEZED
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

@export var pitchScaleMax = 2
func play_sound_for_hint_request(state : AUDIO_STATE):
	audio_player_for_hint_request.stream = audio_streams[state]
	var progress = float(interactable_character.current_click_count) / interactable_character.hints_number_clicks[interactable_character.current_hint]
	audio_player_for_hint_request.pitch_scale = lerp(1, pitchScaleMax, progress)
	audio_player_for_hint_request.play()

func pressed_hacked():
	(hack_button as TextureButton).scale = Vector2(0.95, 0.95)
	interactable_character.interaction_state = InteractableCharacter.INTERACTION_STATE.PRESSED_HACK
	interactable_character.waiting_for_character = true
	
	
func button_pressed_scale(button : TextureButton):
	button.scale = Vector2(0.95, 0.95)
	
func button_unpressed_scale(button : TextureButton):
	button.scale = Vector2(1.0, 1.0)
	
func hack_button_pressed_scale():
	button_pressed_scale(hack_button)
	
func hack_button_unpressed_scale():
	button_unpressed_scale(hack_button)
	
func talk_button_pressed_scale():
	button_pressed_scale(talk_button)
	
func talk_button_unpressed_scale():
	button_unpressed_scale(talk_button)
	
func request_hint_button_pressed_scale():
	button_pressed_scale(request_hint_button)
	
func request_hint_button_unpressed_scale():
	button_unpressed_scale(request_hint_button)
	
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


#potentially worth adding per symbol adding to hints 
func request_more_hints() -> void:
	var current_hint_index = interactable_character.current_hint
	if current_hint_index == interactable_character.hints.size():
		play_sound_for_tip(AUDIO_STATE.HACK_TIPS_ARE_OVER)
		return
	interactable_character.current_click_count += 1
	play_sound_for_hint_request(AUDIO_STATE.HACK_WINDOW_HELPER_CLICK)
	if interactable_character.hints_number_clicks[current_hint_index] == interactable_character.current_click_count:
		current_hint_index += 1
		interactable_character.current_click_count = 0
		var added_line = interactable_character.hints[interactable_character.current_hint]
		add_hint_to_label(hints_label, added_line)	
		play_sound_for_tip(AUDIO_STATE.HACK_TIP_RECIEVED)
		interactable_character.current_hint = current_hint_index
	pass
	
func add_hint_to_label(label: RichTextLabel, text: String):
	label.remove_paragraph(label.get_paragraph_count() - 1)
	label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	
	label.push_color(Color.WHITE)
	label.add_text(">")
	label.pop()
	
	label.push_color(Color.DARK_SEA_GREEN)
	label.add_text(text)
	label.add_text("\n")
	label.pop()
	
	label.pop()
	
func add_input_symbol(label: RichTextLabel):
	label.remove_paragraph(label.get_paragraph_count() - 1)
	label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	label.push_color(Color.WHITE)
	label.add_text(">")
	label.pop()
	
	label.push_color(Color.DARK_SEA_GREEN)
	label.add_text("_")
	label.pop()
	
	label.pop()
	
func remove_input_symbol(label: RichTextLabel):
	label.remove_paragraph(label.get_paragraph_count() - 1)
	
	label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	label.push_color(Color.WHITE)
	label.add_text(">")
	label.pop()
	label.pop()
	pass

func start_hint_input_idle_timer():
	if is_input_symbol_rendered:
		remove_input_symbol(hints_label)
		is_input_symbol_rendered = false
	else:
		is_input_symbol_rendered = true
		add_input_symbol(hints_label)
	idle_input_timer.start()

func end_hint_input_idle_timer():
	start_hint_input_idle_timer()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
