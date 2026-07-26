extends CharacterBody2D

const BASE_SPEED := 180.0
const INTERACT_DISTANCE := 56.0

@onready var sprite: ColorRect = $Sprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_prompt: Label = $InteractionPrompt

var _nearby_interactables: Array[Node] = []


func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	interaction_prompt.visible = false


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	velocity = input_vector * BASE_SPEED * GameState.get_movement_speed_multiplier()
	move_and_slide()
	_update_interaction_prompt()


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
		interaction_prompt.text = "Press E to interact"


func _on_interaction_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent != self and parent.has_method("interact"):
		if parent not in _nearby_interactables:
			_nearby_interactables.append(parent)


func _on_interaction_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	_nearby_interactables.erase(parent)
