extends Node2D

const TILE := 32
const MAP_W := 52
const MAP_H := 22

const GatherableScene := preload("res://scenes/entities/gatherable.tscn")
const CompanionScene := preload("res://scenes/entities/companion_npc.tscn")
const CampBuildingScene := preload("res://scenes/entities/camp_building.tscn")
const PropScene := preload("res://scenes/entities/world_prop.tscn")

@onready var day_night_overlay: CanvasModulate = $DayNightOverlay
@onready var player: CharacterBody2D = $Player
@onready var sleep_area: Area2D = $Camp/SleepArea
@onready var gatherables_root: Node2D = $Gatherables
@onready var camp_root: Node2D = $Camp
@onready var props_root: Node2D = $Props
@onready var tile_map: TileMapLayer = $Terrain

var _gatherable_defs: Array = [
	{"pos": Vector2(10, 17), "resource_id": "stick", "zone_id": "beach", "sprite": "stick", "yield_amount": 2},
	{"pos": Vector2(13, 16), "resource_id": "berry", "zone_id": "beach", "sprite": "berry_bush", "yield_amount": 2, "gather_time": 0.8},
	{"pos": Vector2(16, 18), "resource_id": "vine", "zone_id": "beach", "sprite": "vine", "yield_amount": 1},
	{"pos": Vector2(24, 13), "resource_id": "log", "zone_id": "forest", "sprite": "palm_tree", "required_tool": "axe", "yield_amount": 2},
	{"pos": Vector2(28, 12), "resource_id": "log", "zone_id": "forest", "sprite": "round_tree", "required_tool": "axe", "yield_amount": 2},
	{"pos": Vector2(26, 15), "resource_id": "berry", "zone_id": "forest", "sprite": "berry_bush", "yield_amount": 3},
	{"pos": Vector2(30, 14), "resource_id": "stone", "zone_id": "forest", "sprite": "rock", "yield_amount": 2},
	{"pos": Vector2(33, 13), "resource_id": "flint", "zone_id": "forest", "sprite": "flint", "yield_amount": 1},
	{"pos": Vector2(37, 9), "resource_id": "fish", "zone_id": "river", "sprite": "fish", "gather_time": 1.5, "yield_amount": 1},
	{"pos": Vector2(40, 8), "resource_id": "fresh_water", "zone_id": "river", "sprite": "water_spot", "gather_time": 0.7, "yield_amount": 2},
	{"pos": Vector2(42, 10), "resource_id": "clay", "zone_id": "river", "sprite": "clay", "yield_amount": 2},
	{"pos": Vector2(45, 8), "resource_id": "fish", "zone_id": "river", "sprite": "fish", "gather_time": 1.5},
	{"pos": Vector2(48, 7), "resource_id": "iron_ore", "zone_id": "river", "sprite": "iron_ore", "required_tool": "axe", "yield_amount": 1},
	{"pos": Vector2(9, 6), "resource_id": "stone", "zone_id": "cave", "sprite": "rock", "yield_amount": 2},
	{"pos": Vector2(12, 5), "resource_id": "vine", "zone_id": "cave", "sprite": "vine", "yield_amount": 2},
]

var _decor_defs: Array = [
	{"pos": Vector2(8, 16), "sprite": "palm_tree"},
	{"pos": Vector2(18, 17), "sprite": "bush"},
	{"pos": Vector2(22, 14), "sprite": "round_tree"},
	{"pos": Vector2(27, 11), "sprite": "palm_tree"},
	{"pos": Vector2(31, 16), "sprite": "bush"},
	{"pos": Vector2(35, 12), "sprite": "rock"},
	{"pos": Vector2(11, 8), "sprite": "rock"},
	{"pos": Vector2(15, 7), "sprite": "bush"},
]


func _ready() -> void:
	_build_tileset_and_map()
	_spawn_decor()
	_spawn_gatherables()
	_spawn_camp_buildings()
	_spawn_companion()
	_setup_fire_particles()
	EventBus.time_changed.connect(_on_time_changed)
	sleep_area.body_entered.connect(_on_sleep_area_entered)
	_on_time_changed(GameState.time_of_day, GameState.day_count)
	player.global_position = Vector2(11, 17) * TILE + Vector2(TILE / 2, TILE / 2)
	var zone_timer := Timer.new()
	zone_timer.wait_time = 0.5
	zone_timer.autostart = true
	zone_timer.timeout.connect(_update_zone_discovery)
	add_child(zone_timer)


func _build_tileset_and_map() -> void:
	var source := TileSetAtlasSource.new()
	var tex := load("res://assets/sprites/tilesets/cozy_terrain.png") as Texture2D
	source.texture = tex
	source.texture_region_size = Vector2i(TILE, TILE)
	for i in range(12):
		source.create_tile(Vector2i(i % 8, int(i / 8)))

	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	tileset.add_source(source, 0)
	tile_map.tile_set = tileset

	for y in range(MAP_H):
		for x in range(MAP_W):
			var atlas := _tile_for_cell(x, y)
			tile_map.set_cell(Vector2i(x, y), 0, atlas)

	var water_timer := Timer.new()
	water_timer.wait_time = 0.22
	water_timer.autostart = true
	water_timer.timeout.connect(_animate_water)
	add_child(water_timer)


func _tile_for_cell(x: int, y: int) -> Vector2i:
	# Water around edges / river band
	if y >= 19 or x <= 1 or x >= MAP_W - 2:
		return Vector2i(6 + ((x + y) % 4), 0) # water frames
	if x >= 35 and x <= 46 and y >= 6 and y <= 12:
		return Vector2i(6 + ((x + y) % 4), 0)
	if x >= 34 and x <= 47 and (y == 5 or y == 13):
		return Vector2i(2, 1) # shore
	# Cave
	if x >= 5 and x <= 18 and y >= 2 and y <= 9:
		return Vector2i(4, 0)
	# Forest
	if x >= 20 and x <= 36 and y >= 8 and y <= 18:
		return Vector2i(3, 0)
	# Path toward camp
	if x >= 9 and x <= 12 and y >= 9 and y <= 16:
		return Vector2i(5, 0)
	# Beach / grass mix
	if y >= 15:
		return Vector2i(0, 0) if (x + y) % 5 != 0 else Vector2i(1, 0)
	return Vector2i(2, 0)


func _spawn_decor() -> void:
	for def in _decor_defs:
		var prop := PropScene.instantiate()
		prop.position = def["pos"] * TILE + Vector2(TILE / 2, TILE / 2)
		prop.sprite_name = def["sprite"]
		props_root.add_child(prop)


func _spawn_gatherables() -> void:
	for def in _gatherable_defs:
		var node := GatherableScene.instantiate()
		node.position = def["pos"] * TILE + Vector2(TILE / 2, TILE / 2)
		node.resource_id = def.get("resource_id", "log")
		node.zone_id = def.get("zone_id", "forest")
		node.sprite_name = def.get("sprite", "rock")
		node.yield_amount = int(def.get("yield_amount", 1))
		node.gather_time = float(def.get("gather_time", 1.2))
		node.required_tool = def.get("required_tool", "")
		gatherables_root.add_child(node)


func _spawn_camp_buildings() -> void:
	var defs := [
		{"id": "fire_pit", "pos": Vector2(8, 7), "sprite": "fire_pit"},
		{"id": "bed", "pos": Vector2(10, 6), "sprite": "bed"},
		{"id": "storage_crate", "pos": Vector2(7, 8), "sprite": "storage_crate"},
		{"id": "workshop", "pos": Vector2(12, 7), "sprite": "workshop"},
	]
	for def in defs:
		var building := CampBuildingScene.instantiate()
		building.building_id = def["id"]
		building.sprite_name = def["sprite"]
		building.position = def["pos"] * TILE + Vector2(TILE / 2, TILE / 2)
		camp_root.add_child(building)
	sleep_area.position = Vector2(10, 6) * TILE + Vector2(TILE / 2, TILE / 2)


func _spawn_companion() -> void:
	var companion := CompanionScene.instantiate()
	companion.position = Vector2(9, 7) * TILE + Vector2(TILE / 2, TILE / 2)
	camp_root.add_child(companion)


func _setup_fire_particles() -> void:
	var particles := GPUParticles2D.new()
	particles.name = "FireParticles"
	particles.position = Vector2(8, 7) * TILE + Vector2(TILE / 2, TILE / 2 - 8)
	particles.amount = 22
	particles.lifetime = 0.75
	particles.explosiveness = 0.05
	if ResourceLoader.exists("res://assets/sprites/fx/spark.png"):
		particles.texture = load("res://assets/sprites/fx/spark.png")
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 18.0
	mat.initial_velocity_min = 12.0
	mat.initial_velocity_max = 28.0
	mat.gravity = Vector3(0, -8, 0)
	mat.scale_min = 0.45
	mat.scale_max = 1.15
	mat.color = Color(1.0, 0.55, 0.15, 0.95)
	particles.process_material = mat
	particles.emitting = false
	camp_root.add_child(particles)
	EventBus.building_placed.connect(func(id: String) -> void:
		if id == "fire_pit":
			particles.emitting = true
	)
	if GameState.camp_buildings.get("fire_pit", false):
		particles.emitting = true


func _update_zone_discovery() -> void:
	if player == null:
		return
	var cell := Vector2i(player.global_position / TILE)
	if cell.x >= 5 and cell.x <= 18 and cell.y >= 2 and cell.y <= 9:
		GameState.discover_zone("cave")
	elif cell.x >= 35 and cell.x <= 46 and cell.y >= 6 and cell.y <= 12:
		GameState.discover_zone("river")
	elif cell.x >= 20 and cell.x <= 36 and cell.y >= 8 and cell.y <= 18:
		GameState.discover_zone("forest")
	elif cell.y >= 15:
		GameState.discover_zone("beach")


func _animate_water() -> void:
	var frame := int(Time.get_ticks_msec() / 220.0) % 4
	for y in range(MAP_H):
		for x in range(MAP_W):
			var cell := Vector2i(x, y)
			var atlas: Vector2i = tile_map.get_cell_atlas_coords(cell)
			if atlas.y == 0 and atlas.x >= 6 and atlas.x <= 9:
				tile_map.set_cell(cell, 0, Vector2i(6 + frame, 0))


func _on_time_changed(hour: float, _day: int) -> void:
	day_night_overlay.color = SurvivalMeters.get_ambient_modulate(hour)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sleep"):
		if player.global_position.distance_to(sleep_area.global_position) < 80.0:
			GameState.sleep_at_camp()


func _on_sleep_area_entered(body: Node2D) -> void:
	if body.name == "Player":
		EventBus.game_message.emit("Press Sleep near the bed to rest.")
