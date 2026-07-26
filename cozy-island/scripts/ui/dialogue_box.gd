extends Control

@onready var speaker_label: Label = %SpeakerLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var continue_button: Button = %ContinueButton

var _lines: PackedStringArray = []
var _index: int = 0


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_advance)
	EventBus.dialogue_requested.connect(_start_dialogue)


func _start_dialogue(speaker: String, lines: PackedStringArray) -> void:
	_lines = lines
	_index = 0
	speaker_label.text = speaker
	visible = true
	_show_current_line()


func _show_current_line() -> void:
	if _index >= _lines.size():
		visible = false
		return
	dialogue_label.text = _lines[_index]


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		visible = false
		GameState.story_stage += 1
		return
	_show_current_line()
