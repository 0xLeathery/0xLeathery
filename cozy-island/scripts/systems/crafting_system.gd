class_name CraftingSystem
extends RefCounted

static func try_craft(inputs: Array, tool: String) -> Dictionary:
	var result := {"success": false, "message": "", "recipe_id": ""}
	var normalized_tool := tool if tool != null and tool != "" else ""

	for i in range(inputs.size()):
		var slot = inputs[i]
		if slot != null and str(slot) != "":
			if int(GameState.inventory.get(str(slot), 0)) <= 0:
				result["message"] = "Missing ingredients."
				return result

	if normalized_tool != "" and int(GameState.inventory.get(normalized_tool, 0)) <= 0:
		result["message"] = "Required tool not in inventory."
		return result

	var recipe := RecipeRegistry.find_matching_recipe(inputs, normalized_tool)
	if recipe.is_empty():
		_consume_failed_experiment(inputs)
		result["message"] = "Nothing useful came from that experiment."
		return result

	var recipe_id := str(recipe["id"])
	if not _requirements_met(recipe):
		result["message"] = "You are not ready to craft this yet."
		return result

	var energy_cost := float(recipe.get("energy_cost", 5.0))
	if GameState.energy < energy_cost:
		result["message"] = "Too tired to craft. Rest or eat first."
		return result

	var skill := str(recipe.get("skill", "woodworking"))
	var required_level := int(recipe.get("skill_level", 0))
	if GameState.get_skill_level(skill) < required_level:
		result["message"] = "Your %s skill is too low." % skill.capitalize()
		return result

	if randf() > GameState.get_craft_success_multiplier():
		_consume_failed_experiment(inputs)
		result["message"] = "Your tired hands fumbled the craft."
		return result

	for slot in inputs:
		if slot != null and str(slot) != "":
			GameState.remove_item(str(slot), 1)

	GameState.energy = maxf(GameState.energy - energy_cost, 0.0)
	GameState.add_skill_xp(skill, 1)

	var special := str(recipe.get("special", ""))
	if special != "":
		_apply_special_craft(special)
	else:
		var output_id := str(recipe.get("output", ""))
		var output_amount := int(recipe.get("output_amount", 1))
		if output_id != "" and output_amount > 0:
			GameState.add_item(output_id, output_amount)

	if bool(recipe.get("discoverable", true)):
		GameState.discover_recipe(recipe_id)
	else:
		if recipe_id not in GameState.known_recipes:
			GameState.known_recipes.append(recipe_id)

	EventBus.meters_changed.emit()
	result["success"] = true
	result["recipe_id"] = recipe_id
	result["message"] = "Crafted %s!" % ItemDatabase.get_display_name(str(recipe.get("output", recipe_id)))
	return result


static func _requirements_met(recipe: Dictionary) -> bool:
	var building := str(recipe.get("requires_building", ""))
	if building != "" and not GameState.camp_buildings.get(building, false):
		return false
	var research := str(recipe.get("requires_research", ""))
	if research != "" and research not in GameState.unlocked_research:
		return false
	return true


static func _consume_failed_experiment(inputs: Array) -> void:
	for slot in inputs:
		if slot != null and str(slot) != "":
			if randf() < 0.5:
				GameState.remove_item(str(slot), 1)
	if randf() < 0.25:
		GameState.add_item("scrap", 1)


static func _apply_special_craft(special: String) -> void:
	match special:
		"build_fire_pit":
			GameState.place_building("fire_pit")
			EventBus.game_message.emit("You built a cozy fire pit at camp.")
		"build_bed":
			GameState.place_building("bed")
			EventBus.game_message.emit("You crafted a comfortable bed.")
		"build_storage":
			GameState.place_building("storage_crate")
			EventBus.game_message.emit("Storage crate assembled at camp.")
		"build_workshop":
			GameState.place_building("workshop")
			EventBus.game_message.emit("Workshop is ready! Helpers can be assigned.")
		_:
			pass
