extends Area3D

# Treasure chest that gives rewards when opened

@export var reward_id: String = "coin_medium"
@export var is_open: bool = false

var animation_player: AnimationPlayer
var player_in_range: bool = false

func _ready():
	animation_player = $AnimationPlayer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		show_interaction_prompt()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		hide_interaction_prompt()

func _input(event):
	if player_in_range and event.is_action_pressed("interact") and not is_open:
		open_chest()

func open_chest():
	is_open = true
	animation_player.play("open")
	GameManager.play_dialogue("treasure_chest_found")
	
	# Give reward after animation
	await animation_player.animation_finished
	give_reward()

func give_reward():
	# Spawn reward item
	GameManager.spawn_reward(global_position + Vector3(0, 1, 0), reward_id)
	
	# Also add directly to inventory
	match reward_id:
		"coin_small", "coin_medium", "coin_large":
			var value = get_reward_value(reward_id)
			GameManager.add_coins(value)
		"diamond_small", "diamond_large":
			var value = get_reward_value(reward_id)
			GameManager.add_diamonds(value)
		"building_tool_part_1", "building_tool_part_2":
			GameManager.add_building_tool_part(reward_id)

func get_reward_value(reward_id: String) -> int:
	var file = FileAccess.open("res://data/rewards.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		for reward in data.get("rewards", []):
			if reward.get("id") == reward_id:
				return reward.get("value", 0)
		file.close()
	return 0

func show_interaction_prompt():
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt:
		prompt.show()

func hide_interaction_prompt():
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt:
		prompt.hide()

