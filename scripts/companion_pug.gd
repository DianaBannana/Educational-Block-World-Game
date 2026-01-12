extends CharacterBody3D

# Pug companion that follows Ethan

@export var follow_distance: float = 3.0
@export var follow_speed: float = 4.0

var player: Node3D
var animation_player: AnimationPlayer
var audio_player: AudioStreamPlayer3D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	animation_player = $AnimationPlayer
	audio_player = $AudioStreamPlayer3D
	play_animation("sit")

func _physics_process(delta):
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > follow_distance:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * follow_speed
		velocity.z = direction.z * follow_speed
		play_animation("walk")
		move_and_slide()
	else:
		velocity.x = 0
		velocity.z = 0
		play_animation("wag_tail")

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func play_sound(sound_name: String):
	var sound_path = "res://sounds/pug/" + sound_name
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		audio_player.stream = sound
		audio_player.play()

func help_with_puzzle():
	play_animation("interact")
	play_sound("bark1")
	# Pug can provide visual hints for puzzles

