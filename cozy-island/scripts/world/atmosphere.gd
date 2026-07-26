extends Node2D

## World atmosphere: glow environment, fire light, water sparkles, forest leaves.

@onready var day_night: CanvasModulate = $"../DayNightOverlay"
@onready var camp_root: Node2D = $"../Camp"
@onready var player: CharacterBody2D = $"../Player"

var _fire_light: PointLight2D
var _water_fx: GPUParticles2D
var _leaf_fx: GPUParticles2D
var _world_env: WorldEnvironment
var _light_pulse := 0.0


func _ready() -> void:
	_setup_glow()
	_setup_fire_light()
	_setup_water_sparkles()
	_setup_leaf_dust()
	EventBus.time_changed.connect(_on_time_changed)
	EventBus.building_placed.connect(_on_building)
	_on_time_changed(GameState.time_of_day, GameState.day_count)
	if GameState.camp_buildings.get("fire_pit", false):
		_enable_fire(true)


func _process(delta: float) -> void:
	if _fire_light and _fire_light.enabled:
		_light_pulse += delta * 6.0
		_fire_light.energy = 1.15 + sin(_light_pulse) * 0.2 + sin(_light_pulse * 2.3) * 0.08
		_fire_light.texture_scale = 1.4 + sin(_light_pulse * 0.7) * 0.08


func _setup_glow() -> void:
	_world_env = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_strength = 0.85
	env.glow_bloom = 0.25
	env.glow_hdr_threshold = 0.85
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.08
	env.adjustment_contrast = 1.04
	_world_env.environment = env
	add_child(_world_env)


func _setup_fire_light() -> void:
	_fire_light = PointLight2D.new()
	_fire_light.name = "CampfireLight"
	_fire_light.position = Vector2(8, 7) * 32 + Vector2(16, 8)
	if ResourceLoader.exists("res://assets/sprites/fx/soft_light.png"):
		_fire_light.texture = load("res://assets/sprites/fx/soft_light.png")
	_fire_light.color = Color(1.0, 0.65, 0.3, 1.0)
	_fire_light.energy = 1.2
	_fire_light.texture_scale = 1.5
	_fire_light.shadow_enabled = false
	_fire_light.enabled = false
	_fire_light.range_item_cull_mask = 1
	camp_root.add_child(_fire_light)


func _setup_water_sparkles() -> void:
	_water_fx = GPUParticles2D.new()
	_water_fx.name = "WaterSparkles"
	_water_fx.position = Vector2(40, 9) * 32
	_water_fx.amount = 24
	_water_fx.lifetime = 2.2
	_water_fx.preprocess = 1.0
	_water_fx.visibility_rect = Rect2(-400, -200, 800, 400)
	if ResourceLoader.exists("res://assets/sprites/fx/spark.png"):
		_water_fx.texture = load("res://assets/sprites/fx/spark.png")
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(220, 80, 0)
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 10.0
	mat.gravity = Vector3(0, -4, 0)
	mat.scale_min = 0.4
	mat.scale_max = 1.0
	mat.color = Color(0.85, 0.95, 1.0, 0.7)
	_water_fx.process_material = mat
	add_child(_water_fx)


func _setup_leaf_dust() -> void:
	_leaf_fx = GPUParticles2D.new()
	_leaf_fx.name = "LeafDust"
	_leaf_fx.position = Vector2(27, 13) * 32
	_leaf_fx.amount = 14
	_leaf_fx.lifetime = 4.0
	_leaf_fx.preprocess = 2.0
	if ResourceLoader.exists("res://assets/sprites/fx/leaf.png"):
		_leaf_fx.texture = load("res://assets/sprites/fx/leaf.png")
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(180, 120, 0)
	mat.direction = Vector3(0.4, 0.2, 0)
	mat.spread = 40.0
	mat.initial_velocity_min = 4.0
	mat.initial_velocity_max = 14.0
	mat.gravity = Vector3(0, 6, 0)
	mat.scale_min = 0.6
	mat.scale_max = 1.2
	mat.color = Color(0.55, 0.75, 0.4, 0.75)
	_leaf_fx.process_material = mat
	add_child(_leaf_fx)


func _on_building(building_id: String) -> void:
	if building_id == "fire_pit":
		_enable_fire(true)


func _enable_fire(on: bool) -> void:
	if _fire_light:
		_fire_light.enabled = on


func _on_time_changed(hour: float, _day: int) -> void:
	if day_night:
		day_night.color = SurvivalMeters.get_ambient_modulate(hour)
	if _world_env and _world_env.environment:
		var night := SurvivalMeters.is_night(hour)
		_world_env.environment.glow_intensity = 0.55 if night else 0.28
		_world_env.environment.glow_bloom = 0.4 if night else 0.2
		# Boost fire visibility at night
		if _fire_light and _fire_light.enabled:
			_fire_light.color = Color(1.0, 0.55, 0.22, 1.0) if night else Color(1.0, 0.7, 0.35, 1.0)
			_fire_light.texture_scale = 1.9 if night else 1.4
