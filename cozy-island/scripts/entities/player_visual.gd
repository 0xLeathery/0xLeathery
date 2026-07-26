extends Node2D

const BODY_COLOR := Color("#F4D03F")
const OUTLINE_COLOR := Color("#5D4037")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, OUTLINE_COLOR)
	draw_circle(Vector2.ZERO, 11, BODY_COLOR)
	draw_circle(Vector2(-3, -3), 3, Color(1, 1, 1, 0.35))
