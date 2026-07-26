extends Node

func _ready() -> void:
	_validate()


func _validate() -> void:
	var item := ItemDatabase.get_item("log")
	if not item.has("name"):
		push_error("Item database failed")
		get_tree().quit(1)
		return
	var recipe_count := RecipeRegistry.get_all_recipes().size()
	var research_count := ResearchRegistry.get_all_nodes().size()
	if recipe_count < 40 or research_count < 8:
		push_error("Expected >=40 recipes and >=8 research nodes")
		get_tree().quit(1)
		return
	print("Cozy Island validation passed.")
	print("  Items loaded: ", ItemDatabase.get_all_items().size())
	print("  Recipes loaded: ", recipe_count)
	print("  Research nodes: ", research_count)
	get_tree().quit(0)
