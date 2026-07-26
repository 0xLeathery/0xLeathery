extends Node2D

const GatherableScene := preload("res://scenes/entities/gatherable.tscn")
const CompanionScene := preload("res://scenes/entities/companion_npc.tscn")
const CampBuildingScene := preload("res://scenes/entities/camp_building.tscn")
const ZoneMarkerScene := preload("res://scenes/entities/zone_marker.tscn")

@onready var day_night_overlay: CanvasModulate = $DayNightOverlay
@onready var player: CharacterBody2D = $Player
@onready var sleep_area: Area2D = $Camp/SleepArea
@onready var gatherables_root: Node2D = $Gatherables
@onready var camp_root: Node2D = $Camp

var _gatherable_defs: Array[Dictionary] = [
	{"pos": Vector2(320, 560), "resource_id": "stick", "zone_id": "beach", "yield_amount": 2},
	{"pos": Vector2(420, 520), "resource_id": "berry", "zone_id": "beach", "yield_amount": 2, "gather_time": 0.8},
	{"pos": Vector2(520, 580), "resource_id": "vine", "zone_id": "beach", "yield_amount": 1},
	{"pos": Vector2(760, 420), "resource_id": "log", "zone_id": "forest", "required_tool": "axe", "yield_amount": 2},
	{"pos": Vector2(900, 380), "resource_id": "log", "zone_id": "forest", "required_tool": "axe", "yield_amount": 2},
	{"pos": Vector2(840, 500), "resource_id": "berry", "zone_id": "forest", "yield_amount": 3},
	{"pos": Vector2(980, 460), "resource_id": "stone", "zone_id": "forest", "yield_amount": 2},
	{"pos": Vector2(1100, 420), "resource_id": "flint", "zone_id": "forest", "yield_amount": 1},
	{"pos": Vector2(1180, 300), "resource_id": "fish", "zone_id": "river", "gather_time": 1.5, "yield_amount": 1},
	{"pos": Vector2(1280, 280), "resource_id": "fresh_water", "zone_id": "river", "gather_time": 0.7, "yield_amount": 2},
	{"pos": Vector2(1360, 320), "resource_id": "clay", "zone_id": "river", "yield_amount": 2},
	{"pos": Vector2(1450, 260), "resource_id": "fish", "zone_id": "river", "gather_time": 1.5},
	{"pos": Vector2(1560, 220), "resource_id": "iron_ore", "zone_id": "river", "required_tool": "axe", "yield_amount": 1},
	{"pos": Vector2(300, 220), "resource_id": "stone", "zone_id": "cave", "yield_amount": 2},
	{"pos": Vector2(380, 180), "resource_id": "vine", "zone_id": "cave", "yield_amount": 2},
]

var _zone_defs: Array[Dictionary] = [
	{"rect": Rect2(0, 480, 640, 240), "zone_id": "beach", "color": Color(0.93, 0.84, 0.62, 0.35)},
	{"rect": Rect2(640, 280, 560, 440), "zone_id": "forest", "color": Color(0.18, 0.49, 0.2, 0.25)},
	{"rect": Rect2(1120, 160, 480, 360), "zone_id": "river", "color": Color(0.2, 0.45, 0.75, 0.25)},
	{"rect": Rect2(160, 80, 480, 260), "zone_id": "cave", "color": Color(0.35, 0.28, 0.22, 0.35)},
]


func _ready() -> void:
	_spawn_zones()
	_spawn_gatherables()
	_spawn_camp_buildings()
	_spawn_companion()
	EventBus.time_changed.connect(_on_time_changed)
	sleep_area.body_entered.connect(_on_sleep_area_entered)
	_on_time_changed(GameState.time_of_day, GameState.day_count)


func _spawn_zones() -> void:
	for def in _zone_defs:
		var marker := ZoneMarkerScene.instantiate()
		marker.zone_id = def["zone_id"]
		marker.zone_color = def["color"]
		marker.position = def["rect"].position
		var shape_rect := marker.get_node("ColorRect") as ColorRect
		shape_rect.size = def["rect"].size
		shape_rect.color = def["color"]
		var collision := marker.get_node("CollisionShape2D") as CollisionShape2D
		var rect_shape := collision.shape as RectangleShape2D
		rect_shape.size = def["rect"].size
		add_child(marker)


func _spawn_gatherables() -> void:
	for def in _gatherable_defs:
		var node := GatherableScene.instantiate()
		node.position = def["pos"]
		node.resource_id = def.get("resource_id", "log")
		node.zone_id = def.get("zone_id", "forest")
		node.yield_amount = int(def.get("yield_amount", 1))
		node.gather_time = float(def.get("gather_time", 1.2))
		node.required_tool = def.get("required_tool", "")
		gatherables_root.add_child(node)


func _spawn_camp_buildings() -> void:
	var defs := [
		{"id": "fire_pit", "pos": Vector2(240, 260), "color": Color("#E67E22")},
		{"id": "bed", "pos": Vector2(300, 240), "color": Color("#8E44AD")},
		{"id": "storage_crate", "pos": Vector2(200, 300), "color": Color("#935116")},
		{"id": "workshop", "pos": Vector2(360, 280), "color": Color("#7D6608")},
	]
	for def in defs:
		var building := CampBuildingScene.instantiate()
		building.building_id = def["id"]
		building.building_color = def["color"]
		building.position = def["pos"]
		camp_root.add_child(building)


func _spawn_companion() -> void:
	var companion := CompanionScene.instantiate()
	companion.position = Vector2(280, 280)
	camp_root.add_child(companion)


func _on_time_changed(hour: float, _day: int) -> void:
	day_night_overlay.color = SurvivalMeters.get_ambient_modulate(hour)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sleep"):
		if player.global_position.distance_to(sleep_area.global_position) < 80.0:
			GameState.sleep_at_camp()


func _on_sleep_area_entered(body: Node2D) -> void:
	if body.name == "Player":
		EventBus.game_message.emit("Press F near the bed to sleep.")
