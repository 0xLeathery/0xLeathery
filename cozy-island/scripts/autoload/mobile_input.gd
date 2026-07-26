extends Node

## Provides touch movement vector for mobile devices (iOS/Android).

var move_vector: Vector2 = Vector2.ZERO
var enabled: bool = false


func _ready() -> void:
	enabled = _should_enable_mobile_controls()


func _should_enable_mobile_controls() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	var os_name := OS.get_name()
	return os_name == "iOS" or os_name == "Android"


func set_move_vector(vector: Vector2) -> void:
	if not enabled:
		return
	move_vector = vector


func clear_move_vector() -> void:
	move_vector = Vector2.ZERO


func get_move_vector() -> Vector2:
	if not enabled:
		return Vector2.ZERO
	return move_vector


func press_action(action: String) -> void:
	if not is_inside_tree():
		return
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	get_tree().root.get_viewport().push_input(event)


func release_action(action: String) -> void:
	if not is_inside_tree():
		return
	var event := InputEventAction.new()
	event.action = action
	event.pressed = false
	get_tree().root.get_viewport().push_input(event)
