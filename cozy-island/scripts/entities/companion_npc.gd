extends StaticBody2D

@export var speaker_name: String = "Mira"
@export var dialogue_lines: PackedStringArray = [
	"Welcome to our little camp. The island is gentle if you take your time.",
	"Try combining items in the crafting grid. Some recipes hide until you experiment.",
	"Build a workshop when you can — helpers will keep the camp running while you explore.",
]

var _dialogue_index: int = 0


func _ready() -> void:
	$Label.text = speaker_name


func get_prompt() -> String:
	return "Talk to %s [E]" % speaker_name


func interact(_player: Node) -> void:
	var lines := _get_contextual_dialogue()
	EventBus.dialogue_requested.emit(speaker_name, lines)


func _get_contextual_dialogue() -> PackedStringArray:
	if GameState.story_stage == 0:
		return PackedStringArray([
			"You washed ashore at dawn. I'm Mira — I tend this cave while you explore.",
			"Gather sticks and berries on the beach. Press C to open crafting.",
		])
	if not GameState.camp_buildings.get("fire_pit", false):
		return PackedStringArray([
			"A fire pit would make cooking much cozier. Craft one with stone and sticks.",
		])
	if not GameState.camp_buildings.get("workshop", false):
		return PackedStringArray([
			"I've seen ruins inland. Research a workshop — we could use the help.",
		])
	if GameState.raft_blueprint_unlocked:
		return PackedStringArray([
			"The raft frame is ready. You could leave... or we could stay and make this home.",
		])
	return dialogue_lines
