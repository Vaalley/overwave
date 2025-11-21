class_name Player extends CharacterBody2D

@export var starting_weapon: WeaponData
var weapon_slot_scene = preload("res://weapon_slot.tscn")

signal health_changed(current_value, max_value)
signal player_died

@export var max_health: float = 100.0
var health: float = 100.0

var SPEED = 100.0

func _ready() -> void:
	add_to_group("Player")
	add_weapon(starting_weapon)
	
func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func add_weapon(weapon_data: WeaponData):
	var new_slot = weapon_slot_scene.instantiate()
	$WeaponManager.add_child(new_slot)
	new_slot.init(weapon_data, self)

func apply_upgrade(upgrade: UpgradeData):
	match upgrade.type:
		UpgradeData.UpgradeType.PLAYER_SPEED:
			SPEED += upgrade.value
			print("Speed is now: ", SPEED)
			
		UpgradeData.UpgradeType.ATTACK_SPEED:
			for weapon_slot in $WeaponManager.get_children():
				weapon_slot.timer.wait_time *= upgrade.value
			print("All weapon fire rates multiplied by: ", upgrade.value)
			
func take_damage(amount: float):
	health -= amount
	print("Ouch! Health is: ", health)
	
	health_changed.emit(health, max_health)
	
	if health <= 0:
		die()

func die():
	player_died.emit()
	# For now, just restart the game instantly
	get_tree().reload_current_scene()
