extends StaticBody2D

@export var resource_id: String = "log"
@export var sprite_name: String = "rock"
@export var yield_amount: int = 1
@export var gather_time: float = 1.2
@export var respawn_time: float = 20.0
@export var zone_id: String = "forest"
@export var required_tool: String = ""
@export var energy_cost: float = 4.0

@onready var sprite: Sprite2D = $Sprite
@onready var prompt_label: Label = $PromptLabel
@onready var timer: Timer = $RespawnTimer

var _depleted: bool = false
var _gathering: bool = false


func _ready() -> void:
	prompt_label.text = ""
	timer.wait_time = respawn_time
	timer.timeout.connect(_on_respawn)
	var path := "res://assets/sprites/props/%s.png" % sprite_name
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true


func get_prompt() -> String:
	if _depleted:
		return "Depleted..."
	var item_name := ItemDatabase.get_display_name(resource_id)
	if required_tool != "" and int(GameState.inventory.get(required_tool, 0)) <= 0:
		return "Needs %s" % ItemDatabase.get_display_name(required_tool)
	return "Gather %s" % item_name


func interact(_player: Node) -> void:
	if _depleted or _gathering:
		return
	if required_tool != "" and int(GameState.inventory.get(required_tool, 0)) <= 0:
		EventBus.game_message.emit("You need a %s for this." % ItemDatabase.get_display_name(required_tool))
		return
	if GameState.energy < energy_cost:
		EventBus.game_message.emit("Too tired to gather. Rest first.")
		return
	_gathering = true
	prompt_label.text = "Gathering..."
	await get_tree().create_timer(gather_time).timeout
	if not is_instance_valid(self):
		return
	GameState.energy = maxf(GameState.energy - energy_cost, 0.0)
	GameState.add_item(resource_id, yield_amount)
	GameState.discover_zone(zone_id)
	EventBus.item_gathered.emit(resource_id, yield_amount)
	EventBus.meters_changed.emit()
	Sfx.play_gather()
	_set_depleted(true)
	_gathering = false


func _set_depleted(value: bool) -> void:
	_depleted = value
	sprite.modulate = Color(0.55, 0.55, 0.55, 0.4) if _depleted else Color.WHITE
	prompt_label.text = ""
	if _depleted:
		timer.start()


func _on_respawn() -> void:
	_set_depleted(false)
