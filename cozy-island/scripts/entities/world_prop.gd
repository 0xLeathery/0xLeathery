extends Node2D

@export var sprite_name: String = "bush"

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	var path := "res://assets/sprites/props/%s.png" % sprite_name
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	sprite.centered = true
	# Y-sort feel
	z_index = int(global_position.y)
