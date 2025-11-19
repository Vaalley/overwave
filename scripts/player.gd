class_name Player extends CharacterBody2D

@export var starting_weapon: WeaponData
var weapon_slot_scene = preload("res://weapon_slot.tscn")

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
			
