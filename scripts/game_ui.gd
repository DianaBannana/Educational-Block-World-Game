extends Control

# Floating UI panel showing Hearts, Coins, Current Level (top-left)

@onready var hearts_container: HBoxContainer = $Panel/VBoxContainer/HeartsContainer
@onready var coins_label: Label = $Panel/VBoxContainer/CoinsLabel
@onready var level_label: Label = $Panel/VBoxContainer/LevelLabel

var heart_icons: Array = []

func _ready():
	add_to_group("game_ui")
	setup_hearts()
	GameManager.coins_changed.connect(update_coins)
	GameManager.health_changed.connect(update_health)
	GameManager.level_changed.connect(update_level)

func setup_hearts():
	for i in range(5):
		var heart = TextureRect.new()
		heart.texture = preload("res://ui/heart_full.png")
		heart.custom_minimum_size = Vector2(32, 32)
		hearts_container.add_child(heart)
		heart_icons.append(heart)

func update_health(health: int):
	for i in range(heart_icons.size()):
		if i < health:
			heart_icons[i].texture = preload("res://ui/heart_full.png")
		else:
			heart_icons[i].texture = preload("res://ui/heart_empty.png")

func update_coins(coins: int):
	coins_label.text = "Coins: " + str(coins)

func update_diamonds(diamonds: int):
	# Can add diamond display if needed
	pass

func update_level(level: int):
	level_label.text = "Level: " + str(level)

