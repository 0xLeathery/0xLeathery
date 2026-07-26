extends CharacterBody2D

const BASE_SPEED := 180.0
const INTERACT_DISTANCE := 56.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_prompt: Label = $InteractionPrompt
@onready var camera: Camera2D = $Camera2D

var _nearby_interactables: Array[Node] = []
var _facing := "down"


func _ready() -> void:
	_build_frames()
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	interaction_prompt.visible = false
	get_viewport().size_changed.connect(_update_camera_zoom)
	_update_camera_zoom()
	anim.play("idle_down")


func _build_frames() -> void:
	var frames := SpriteFrames.new()
	var sheet := load("res://assets/sprites/characters/player_sheet.png") as Texture2D
	var dirs := ["down", "left", "right", "up"]
	for dy in range(dirs.size()):
		var direction: String = dirs[dy]
		frames.add_animation("walk_%s" % direction)
		frames.set_animation_speed("walk_%s" % direction, 8.0)
		frames.add_animation("idle_%s" % direction)
		frames.set_animation_speed("idle_%s" % direction, 1.0)
		frames.set_animation_loop("walk_%s" % direction, true)
		frames.set_animation_loop("idle_%s" % direction, true)
		for fx in range(4):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(fx * 32, dy * 32, 32, 32)
			frames.add_frame("walk_%s" % direction, atlas)
			if fx == 0:
				frames.add_frame("idle_%s" % direction, atlas)
	anim.sprite_frames = frames
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	var touch_vector := MobileInput.get_move_vector()
	if touch_vector.length_squared() > 0.01:
		input_vector = touch_vector
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	velocity = input_vector * BASE_SPEED * GameState.get_movement_speed_multiplier()
	move_and_slide()
	_update_animation(input_vector)
	_update_interaction_prompt()


func _update_animation(input_vector: Vector2) -> void:
	if input_vector.length_squared() > 0.02:
		if absf(input_vector.x) > absf(input_vector.y):
			_facing = "right" if input_vector.x > 0.0 else "left"
		else:
			_facing = "down" if input_vector.y > 0.0 else "up"
		var walk := "walk_%s" % _facing
		if anim.animation != walk:
			anim.play(walk)
	else:
		var idle := "idle_%s" % _facing
		if anim.animation != idle:
			anim.play(idle)


func _update_camera_zoom() -> void:
	var vp := get_viewport().get_visible_rect().size
	if vp.y <= 0:
		return
	var target_zoom := clampf(720.0 / vp.y, 1.0, 1.85)
	if MobileInput.enabled:
		target_zoom = maxf(target_zoom, 1.45)
	camera.zoom = Vector2.ONE * target_zoom


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()


func _try_interact() -> void:
	var target := _get_closest_interactable()
	if target == null:
		return
	if target.has_method("interact"):
		target.interact(self)


func _get_closest_interactable() -> Node:
	var closest: Node = null
	var closest_dist := INTERACT_DISTANCE
	for node in _nearby_interactables:
		if not is_instance_valid(node):
			continue
		var dist := global_position.distance_to(node.global_position)
		if dist <= closest_dist:
			closest_dist = dist
			closest = node
	return closest


func _update_interaction_prompt() -> void:
	var target := _get_closest_interactable()
	if target == null:
		interaction_prompt.visible = false
		return
	interaction_prompt.visible = true
	if target.has_method("get_prompt"):
		interaction_prompt.text = target.get_prompt()
	else:
		interaction_prompt.text = "Tap Gather" if MobileInput.enabled else "Press E"


func _on_interaction_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent != self and parent.has_method("interact"):
		if parent not in _nearby_interactables:
			_nearby_interactables.append(parent)


func _on_interaction_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	_nearby_interactables.erase(parent)
