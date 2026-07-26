extends Node

## Ambient bed of looping waves + birds using generated/copied audio.

@onready var waves: AudioStreamPlayer = $Waves
@onready var birds: AudioStreamPlayer = $Birds
@onready var fire: AudioStreamPlayer = $Fire


func _ready() -> void:
	_setup_player(waves, "res://assets/audio/waves.ogg", -16.0)
	_setup_player(birds, "res://assets/audio/soft.ogg", -22.0)
	_setup_player(fire, "res://assets/audio/gather.ogg", -28.0)
	if waves.stream:
		waves.play()
	if birds.stream:
		birds.play()
	EventBus.building_placed.connect(_on_building)
	if GameState.camp_buildings.get("fire_pit", false) and fire.stream:
		fire.play()


func _setup_player(player: AudioStreamPlayer, path: String, volume: float) -> void:
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		player.stream = stream
		player.volume_db = volume


func _on_building(building_id: String) -> void:
	if building_id == "fire_pit" and fire.stream and not fire.playing:
		fire.play()
