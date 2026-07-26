extends Node2D

var base_color: Color = Color.WHITE


func _draw() -> void:
	var dark := base_color.darkened(0.35)
	draw_circle(Vector2.ZERO, 16, dark)
	draw_circle(Vector2.ZERO, 13, base_color)
	draw_circle(Vector2(-4, -4), 4, base_color.lightened(0.25))
