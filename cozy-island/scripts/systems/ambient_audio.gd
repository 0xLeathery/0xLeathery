extends Node

## Placeholder ambient audio controller.
## Replace stream paths with real OGG/WAV assets under res://assets/audio/

@onready var waves: AudioStreamPlayer = $Waves
@onready var fire: AudioStreamPlayer = $Fire
@onready var birds: AudioStreamPlayer = $Birds


func _ready() -> void:
	for player: AudioStreamPlayer in [waves, fire, birds]:
		player.volume_db = -18.0
	# Streams can be assigned in-editor when audio assets are added.
	if waves.stream:
		waves.play()
	if fire.stream:
		fire.play()
	if birds.stream:
		birds.play()
