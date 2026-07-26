extends Node

const MAX_INVENTORY_SLOTS := 25
const IN_GAME_DAY_SECONDS := 600.0
const METER_MAX := 100.0

var inventory: Dictionary = {}
var hunger: float = 85.0
var thirst: float = 85.0
var energy: float = 90.0
var time_of_day: float = 8.0
var day_count: int = 1
var skills: Dictionary = {
	"woodworking": 0,
	"cooking": 0,
	"stonework": 0,
	"weaving": 0,
}
var discovered_recipes: Array[String] = []
var known_recipes: Array[String] = []
var camp_buildings: Dictionary = {
	"fire_pit": false,
	"bed": false,
	"storage_crate": false,
	"workshop": false,
}
var unlocked_research: Array[String] = []
var helpers: Array[Dictionary] = []
var discovered_zones: Array[String] = ["beach"]
var relaxed_mode: bool = false
var raft_blueprint_unlocked: bool = false
var story_stage: int = 0

var _time_accumulator: float = 0.0


func _ready() -> void:
	_reset_starter_inventory()


func _process(delta: float) -> void:
	_advance_time(delta)
	_decay_meters(delta)
	_tick_helpers(delta)
	_tick_automation(delta)


func _reset_starter_inventory() -> void:
	inventory.clear()
	add_item("stick", 3)
	add_item("flint", 1)


func get_meter_decay_multiplier() -> float:
	return 0.5 if relaxed_mode else 1.0


func add_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var item := ItemDatabase.get_item(item_id)
	if item.is_empty():
		return false
	var current := int(inventory.get(item_id, 0))
	var max_stack := int(item.get("stack", 99))
	var new_total := mini(current + amount, max_stack)
	var added := new_total - current
	if added <= 0:
		return false
	inventory[item_id] = new_total
	EventBus.inventory_changed.emit()
	return true


func remove_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(inventory.get(item_id, 0))
	if current < amount:
		return false
	current -= amount
	if current <= 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = current
	EventBus.inventory_changed.emit()
	return true


func has_items(requirements: Dictionary) -> bool:
	for item_id in requirements.keys():
		if int(inventory.get(item_id, 0)) < int(requirements[item_id]):
			return false
	return true


func consume_items(requirements: Dictionary) -> bool:
	if not has_items(requirements):
		return false
	for item_id in requirements.keys():
		remove_item(item_id, int(requirements[item_id]))
	return true


func get_skill_level(skill: String) -> int:
	return int(skills.get(skill, 0))


func add_skill_xp(skill: String, amount: int = 1) -> void:
	var current := get_skill_level(skill)
	var next := current + amount
	skills[skill] = next
	EventBus.skill_gained.emit(skill, next)


func restore_meter(meter: String, amount: float) -> void:
	match meter:
		"hunger":
			hunger = clampf(hunger + amount, 0.0, METER_MAX)
		"thirst":
			thirst = clampf(thirst + amount, 0.0, METER_MAX)
		"energy":
			energy = clampf(energy + amount, 0.0, METER_MAX)
	EventBus.meters_changed.emit()


func apply_item_consumable(item_id: String) -> void:
	var item := ItemDatabase.get_item(item_id)
	if item.is_empty():
		return
	var effects: Dictionary = item.get("effects", {})
	for meter in effects.keys():
		restore_meter(meter, float(effects[meter]))


func discover_recipe(recipe_id: String) -> void:
	if recipe_id in discovered_recipes:
		return
	discovered_recipes.append(recipe_id)
	EventBus.recipe_discovered.emit(recipe_id)


func discover_zone(zone_id: String) -> void:
	if zone_id in discovered_zones:
		return
	discovered_zones.append(zone_id)
	EventBus.zone_discovered.emit(zone_id)


func place_building(building_id: String) -> bool:
	if camp_buildings.get(building_id, false):
		return false
	camp_buildings[building_id] = true
	EventBus.building_placed.emit(building_id)
	return true


func unlock_research(research_id: String) -> bool:
	if research_id in unlocked_research:
		return false
	unlocked_research.append(research_id)
	var node := ResearchRegistry.get_research_node(research_id)
	for unlock in node.get("unlocks", []):
		_apply_unlock(str(unlock))
	EventBus.research_unlocked.emit(research_id)
	return true


func _apply_unlock(unlock_id: String) -> void:
	match unlock_id:
		"building_workshop":
			pass
		"helper_slot_1":
			if helpers.is_empty():
				helpers.append({"name": "Mira", "job": "", "progress": 0.0})
		"helper_slot_2":
			if helpers.size() < 2:
				helpers.append({"name": "Kai", "job": "", "progress": 0.0})
		"helper_slot_3":
			if helpers.size() < 3:
				helpers.append({"name": "Luna", "job": "", "progress": 0.0})
		"raft_blueprint":
			raft_blueprint_unlocked = true
		_:
			pass


func assign_helper(helper_index: int, job_id: String) -> void:
	if helper_index < 0 or helper_index >= helpers.size():
		return
	helpers[helper_index]["job"] = job_id
	helpers[helper_index]["progress"] = 0.0
	EventBus.helper_assigned.emit(helper_index, job_id)


func set_relaxed_mode(enabled: bool) -> void:
	relaxed_mode = enabled
	EventBus.relaxed_mode_changed.emit(enabled)


func sleep_at_camp() -> void:
	if not camp_buildings.get("bed", false):
		EventBus.game_message.emit("Build a bed at camp before you can sleep.")
		return
	energy = METER_MAX
	hunger = maxf(hunger - 8.0, 0.0)
	thirst = maxf(thirst - 10.0, 0.0)
	time_of_day = 7.0
	day_count += 1
	EventBus.time_changed.emit(time_of_day, day_count)
	EventBus.meters_changed.emit()
	EventBus.game_message.emit("You slept peacefully. Day %d begins." % day_count)


func get_movement_speed_multiplier() -> float:
	if hunger <= 0.0 or thirst <= 0.0 or energy <= 0.0:
		return 0.65
	return 1.0


func get_craft_success_multiplier() -> float:
	if energy <= 15.0:
		return 0.7
	return 1.0


func _advance_time(delta: float) -> void:
	_time_accumulator += delta
	var hours_per_second := 24.0 / IN_GAME_DAY_SECONDS
	time_of_day += delta * hours_per_second
	if time_of_day >= 24.0:
		time_of_day -= 24.0
		day_count += 1
	EventBus.time_changed.emit(time_of_day, day_count)


func _decay_meters(delta: float) -> void:
	var mult := get_meter_decay_multiplier()
	var hour_delta := delta * (24.0 / IN_GAME_DAY_SECONDS)
	hunger = maxf(hunger - hour_delta * 1.2 * mult, 0.0)
	thirst = maxf(thirst - hour_delta * 1.5 * mult, 0.0)
	if energy > 0.0:
		energy = maxf(energy - hour_delta * 0.8 * mult, 0.0)
	EventBus.meters_changed.emit()


func _tick_helpers(delta: float) -> void:
	if not camp_buildings.get("workshop", false):
		return
	for helper in helpers:
		var job_id := str(helper.get("job", ""))
		if job_id.is_empty():
			continue
		var job := ResearchRegistry.get_helper_job(job_id)
		if job.is_empty():
			continue
		var inputs: Dictionary = job.get("inputs", {})
		if not inputs.is_empty() and not has_items(inputs):
			continue
		helper["progress"] = float(helper.get("progress", 0.0)) + delta * AutomationSystem.get_helper_speed_multiplier()
		var duration := float(job.get("duration", 8.0))
		if float(helper["progress"]) >= duration:
			if not inputs.is_empty():
				consume_items(inputs)
			var output_id := str(job.get("output", ""))
			var output_amount := int(job.get("output_amount", 1))
			add_item(output_id, output_amount)
			helper["progress"] = 0.0
			EventBus.production_completed.emit(job_id, output_id, output_amount)


func _tick_automation(delta: float) -> void:
	pass
