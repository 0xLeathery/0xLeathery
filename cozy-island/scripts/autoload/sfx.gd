extends Node

@onready var gather_player: AudioStreamPlayer = $Gather
@onready var ui_click_player: AudioStreamPlayer = $UiClick
@onready var ui_open_player: AudioStreamPlayer = $UiOpen


func _ready() -> void:
	_load_stream(gather_player, "res://assets/audio/gather.ogg")
	_load_stream(ui_click_player, "res://assets/audio/ui_click.ogg")
	_load_stream(ui_open_player, "res://assets/audio/ui_open.ogg")


func _load_stream(player: AudioStreamPlayer, path: String) -> void:
	if ResourceLoader.exists(path):
		player.stream = load(path)
		player.volume_db = -8.0


func play_gather() -> void:
	if gather_player.stream:
		gather_player.play()


func play_ui_click() -> void:
	if ui_click_player.stream:
		ui_click_player.play()


func play_ui_open() -> void:
	if ui_open_player.stream:
		ui_open_player.play()
