extends Node2D

@export var sprite_name: String = "bush"

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	var path := "res://assets/sprites/props/%s.png" % sprite_name
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ensure_shadow()
	z_index = int(global_position.y)


func _ensure_shadow() -> void:
	if not ResourceLoader.exists("res://assets/sprites/characters/shadow.png"):
		return
	if has_node("Shadow"):
		return
	var shadow := Sprite2D.new()
	shadow.name = "Shadow"
	shadow.texture = load("res://assets/sprites/characters/shadow.png")
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shadow.z_index = -1
	shadow.position = Vector2(0, 12)
	shadow.modulate = Color(1, 1, 1, 0.35)
	add_child(shadow)
	move_child(shadow, 0)
