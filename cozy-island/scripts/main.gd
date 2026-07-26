extends Node

@onready var island_map: Node2D = $IslandMap
@onready var hud: CanvasLayer = $HUD
@onready var crafting_grid: Control = $CraftingGrid
@onready var inventory_panel: Control = $InventoryPanel
@onready var research_panel: Control = $ResearchPanel
@onready var dialogue_box: Control = $DialogueBox


func _ready() -> void:
	EventBus.game_message.emit("Cozy Island loaded. Explore the beach and head inland.")
