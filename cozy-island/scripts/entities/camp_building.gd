extends Area2D

@export var building_id: String = "fire_pit"
@export var sprite_name: String = "fire_pit"

@onready var sprite: Sprite2D = $Sprite

var _fire_anim: AnimatedSprite2D


func _ready() -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	if building_id == "fire_pit" and ResourceLoader.exists("res://assets/sprites/props/fire_pit_sheet.png"):
		_setup_fire_anim()
	else:
		var path := "res://assets/sprites/props/%s.png" % sprite_name
		if ResourceLoader.exists(path):
			sprite.texture = load(path)
	_update_visibility()
	EventBus.building_placed.connect(_on_building_placed)


func _setup_fire_anim() -> void:
	sprite.visible = false
	_fire_anim = AnimatedSprite2D.new()
	_fire_anim.name = "FireAnim"
	_fire_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fire_anim.centered = true
	var frames := SpriteFrames.new()
	frames.add_animation("burn")
	frames.set_animation_speed("burn", 8.0)
	frames.set_animation_loop("burn", true)
	var sheet := load("res://assets/sprites/props/fire_pit_sheet.png") as Texture2D
	for fx in range(4):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(fx * 32, 0, 32, 32)
		frames.add_frame("burn", atlas)
	_fire_anim.sprite_frames = frames
	add_child(_fire_anim)
	_fire_anim.play("burn")


func _on_building_placed(placed_id: String) -> void:
	if placed_id == building_id:
		_update_visibility()


func _update_visibility() -> void:
	var built: bool = GameState.camp_buildings.get(building_id, false)
	visible = built
	if _fire_anim:
		if built:
			_fire_anim.play("burn")
		else:
			_fire_anim.stop()


func get_prompt() -> String:
	return building_id.replace("_", " ").capitalize()
