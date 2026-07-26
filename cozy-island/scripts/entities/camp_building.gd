extends Area2D

@export var building_id: String = "fire_pit"
@export var sprite_name: String = "fire_pit"

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	var path := "res://assets/sprites/props/%s.png" % sprite_name
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	_update_visibility()
	EventBus.building_placed.connect(_on_building_placed)


func _on_building_placed(placed_id: String) -> void:
	if placed_id == building_id:
		_update_visibility()


func _update_visibility() -> void:
	visible = GameState.camp_buildings.get(building_id, false)


func get_prompt() -> String:
	return building_id.replace("_", " ").capitalize()
