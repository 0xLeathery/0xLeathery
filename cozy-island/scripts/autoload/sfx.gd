extends Node

@onready var gather_player: AudioStreamPlayer = $Gather
@onready var ui_click_player: AudioStreamPlayer = $UiClick
@onready var ui_open_player: AudioStreamPlayer = $UiOpen
@onready var footstep_player: AudioStreamPlayer = $Footstep


func _ready() -> void:
	_load_stream(gather_player, "res://assets/audio/gather.ogg", -8.0)
	_load_stream(ui_click_player, "res://assets/audio/ui_click.ogg", -8.0)
	_load_stream(ui_open_player, "res://assets/audio/ui_open.ogg", -8.0)
	_load_stream(footstep_player, "res://assets/audio/footstep.ogg", -16.0)


func _load_stream(player: AudioStreamPlayer, path: String, volume_db: float) -> void:
	if ResourceLoader.exists(path):
		player.stream = load(path)
		player.volume_db = volume_db


func play_gather() -> void:
	if gather_player.stream:
		gather_player.play()


func play_ui_click() -> void:
	if ui_click_player.stream:
		ui_click_player.play()


func play_ui_open() -> void:
	if ui_open_player.stream:
		ui_open_player.play()


func play_footstep() -> void:
	if footstep_player and footstep_player.stream:
		footstep_player.pitch_scale = randf_range(0.92, 1.08)
		footstep_player.play()
