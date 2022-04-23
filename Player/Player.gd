extends KinematicBody2D
class_name Player

signal mine(target_pos)
signal collected_ore()

onready var speed = 56
onready var x_direction = 0 # 1 = right, -1 = left
onready var y_direction = 1 # 1 = down, -1 = up
onready var direction = Vector2(0, 1)

onready var pickaxe = $Pickaxe
onready var animation_player = $AnimationPlayer
onready var move_cooldown_timer = $MoveCooldownTimer

func _physics_process(delta):
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	x_direction = sign(velocity.x)
	y_direction = sign(velocity.y)
	if x_direction != 0 or y_direction != 0:
		direction.x = x_direction
		direction.y = y_direction
		if x_direction != 0 and y_direction != 0:
			direction.y = 0
	if _can_move():
		move_and_slide(velocity)

func _can_move() -> bool:
	if not move_cooldown_timer.is_stopped():
		return false
	return true

func _process(delta):
	if Input.is_action_just_pressed("main_action"):
		var dir = direction
		var mine_pos = global_position + direction * 16
		pickaxe.global_position = mine_pos
		animation_player.stop()
		animation_player.play("mine")
		move_cooldown_timer.start()
		emit_signal("mine", mine_pos)

func _on_MoveCooldown_timeout():
	# Unused for now
	pass

func collect(ore) -> void:
	if ore.ore_type == Globals.ORE_TYPE.Gold:
		Globals.current_score += 10
	elif ore.ore_type == Globals.ORE_TYPE.Iron:
		pass # TODO: Should iron give score? Repair pickaxe?
	elif ore.ore_type == Globals.ORE_TYPE.Emerald:
		Globals.current_score += 200
	elif ore.ore_type == Globals.ORE_TYPE.Ruby:
		Globals.current_score += 500
	elif ore.ore_type == Globals.ORE_TYPE.Sapphire:
		Globals.current_score += 1000
	emit_signal("collected_ore")
