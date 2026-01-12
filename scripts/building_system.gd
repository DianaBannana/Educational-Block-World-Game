extends Node

# Building system for portal gate construction

var portal_parts: Dictionary = {
	"part_1": false,
	"part_2": false
}

func _ready():
	GameManager.building_tool_parts_changed.connect(_on_parts_changed)

func _on_parts_changed(parts: Array):
	check_portal_ready()

func check_portal_ready():
	if "building_tool_part_1" in parts:
		portal_parts["part_1"] = true
	
	if "building_tool_part_2" in parts:
		portal_parts["part_2"] = true
	
	if portal_parts["part_1"] and portal_parts["part_2"]:
		build_portal()

func build_portal():
	var portal_location = get_tree().get_first_node_in_group("portal_location")
	if portal_location:
		var portal_scene = preload("res://objects/portal_gate.tscn").instantiate()
		get_tree().current_scene.add_child(portal_scene)
		portal_scene.global_position = portal_location.global_position
		portal_scene.enable()
		GameManager.play_dialogue("portal_complete")

