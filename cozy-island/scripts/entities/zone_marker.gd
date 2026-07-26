extends Area2D

@export var zone_id: String = "beach"
@export var zone_color: Color = Color(0.2, 0.2, 0.2, 0.35)


func _ready() -> void:
	$ColorRect.color = zone_color
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameState.discover_zone(zone_id)
