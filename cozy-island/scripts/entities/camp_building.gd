extends Area2D

@export var building_id: String = "fire_pit"
@export var building_color: Color = Color("#E67E22")


func _ready() -> void:
	$Sprite.color = building_color
	_update_visibility()
	EventBus.building_placed.connect(_on_building_placed)


func _on_building_placed(placed_id: String) -> void:
	if placed_id == building_id:
		_update_visibility()


func _update_visibility() -> void:
	visible = GameState.camp_buildings.get(building_id, false)


func get_prompt() -> String:
	return "%s [built]" % building_id.replace("_", " ").capitalize()
