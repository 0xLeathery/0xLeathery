extends Node

var _recipes: Array = []


func _ready() -> void:
	_load_recipes()
	for recipe in _recipes:
		if not bool(recipe.get("discoverable", true)):
			GameState.known_recipes.append(str(recipe["id"]))


func _load_recipes() -> void:
	var file := FileAccess.open("res://data/recipes/recipes.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load recipes.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("recipes.json must be an array")
		return
	_recipes.clear()
	for entry in parsed:
		_recipes.append(entry)


func get_all_recipes() -> Array:
	return _recipes.duplicate(true)


func get_recipe(recipe_id: String) -> Dictionary:
	for recipe in _recipes:
		if str(recipe.get("id", "")) == recipe_id:
			return recipe.duplicate(true)
	return {}


func find_matching_recipe(inputs: Array, tool: String) -> Dictionary:
	var normalized_inputs: Array = []
	for slot in inputs:
		normalized_inputs.append(slot if slot != null and str(slot) != "" else null)

	for recipe in _recipes:
		var recipe_tool := str(recipe.get("tool", "")) if recipe.get("tool") else ""
		if recipe_tool != tool:
			continue
		var recipe_inputs: Array = recipe.get("inputs", [])
		if _inputs_match(normalized_inputs, recipe_inputs):
			return recipe.duplicate(true)
	return {}


func _inputs_match(player_inputs: Array, recipe_inputs: Array) -> bool:
	if player_inputs.size() != 3:
		return false
	while recipe_inputs.size() < 3:
		recipe_inputs.append(null)
	for i in range(3):
		var a = player_inputs[i]
		var b = recipe_inputs[i]
		if a == null and b == null:
			continue
		if str(a) != str(b):
			return false
	return true


func get_known_recipes_for_book() -> Array:
	var result: Array = []
	for recipe in _recipes:
		var recipe_id := str(recipe["id"])
		if recipe_id in GameState.discovered_recipes or recipe_id in GameState.known_recipes:
			result.append(recipe.duplicate(true))
	return result
