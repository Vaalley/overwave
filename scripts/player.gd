class_name Player extends CharacterBody2D


var SPEED = 100.0

var projectile_scene = preload("res://projectile.tscn")

func _ready() -> void:
	add_to_group("Player")
	
	$FireTimer.timeout.connect(_on_fire_timer_timeout)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_fire_timer_timeout():
	# Create an instance of the bullet
	var p = projectile_scene.instantiate()
	
	# Set its starting position to where the player is
	p.global_position = global_position
	
	# (We'll aim it later. For now, just fire right)
	p.velocity = Vector2.RIGHT 
	
	# Add the bullet to the main game, NOT the player
	# This is so it doesn't move with the player
	get_tree().root.add_child(p)

func apply_upgrade(upgrade: UpgradeData):
	# We check the "type" we defined in our resource
	match upgrade.type:
		UpgradeData.UpgradeType.PLAYER_SPEED:
			SPEED += upgrade.value # e.g., 100 + 15
			print("Speed is now: ", SPEED)
			
		UpgradeData.UpgradeType.ATTACK_SPEED:
			# We multiply the timer's wait time to make it shorter
			$FireTimer.wait_time *= upgrade.value # e.g., 1.0 * 0.9
			print("Fire rate is now: ", $FireTimer.wait_time)