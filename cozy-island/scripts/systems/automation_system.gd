class_name AutomationSystem
extends RefCounted

static func try_unlock_research(research_id: String) -> Dictionary:
	var result := {"success": false, "message": ""}
	if not ResearchRegistry.can_unlock(research_id):
		result["message"] = "Cannot unlock this research yet."
		return result
	var node := ResearchRegistry.get_research_node(research_id)
	var cost: Dictionary = node.get("cost", {})
	if not GameState.consume_items(cost):
		result["message"] = "Missing resources for research."
		return result
	GameState.unlock_research(research_id)
	result["success"] = true
	result["message"] = "Unlocked: %s" % str(node.get("name", research_id))
	return result


static func get_helper_speed_multiplier() -> float:
	return 1.25 if "automation_boost" in GameState.unlocked_research else 1.0
