extends Node

var _nodes: Array = []
var _helper_jobs: Dictionary = {}


func _ready() -> void:
	_load_research()
	_load_helper_jobs()


func _load_research() -> void:
	var file := FileAccess.open("res://data/research/research.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load research.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("research.json must be an array")
		return
	_nodes.clear()
	for entry in parsed:
		_nodes.append(entry)


func _load_helper_jobs() -> void:
	var file := FileAccess.open("res://data/research/helper_jobs.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load helper_jobs.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("helper_jobs.json must be a dictionary")
		return
	_helper_jobs = parsed


func get_all_nodes() -> Array:
	return _nodes.duplicate(true)


func get_research_node(research_id: String) -> Dictionary:
	for node in _nodes:
		if str(node.get("id", "")) == research_id:
			return node.duplicate(true)
	return {}


func can_unlock(research_id: String) -> bool:
	var node := get_research_node(research_id)
	if node.is_empty():
		return false
	if research_id in GameState.unlocked_research:
		return false
	for req in node.get("requires", []):
		if str(req) not in GameState.unlocked_research:
			return false
	return GameState.has_items(node.get("cost", {}))


func get_helper_jobs() -> Dictionary:
	return _helper_jobs.duplicate(true)


func get_helper_job(job_id: String) -> Dictionary:
	return _helper_jobs.get(job_id, {}).duplicate()


func get_available_helper_jobs() -> Array:
	var jobs: Array = []
	for job_id in _helper_jobs.keys():
		jobs.append(_helper_jobs[job_id].duplicate(true))
	return jobs
