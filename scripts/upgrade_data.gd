extends Resource
class_name UpgradeData # This lets us create "UpgradeData" files

# We define what *kinds* of upgrades exist
enum UpgradeType { PLAYER_SPEED, ATTACK_SPEED }

@export var name: String
@export_multiline var description: String
@export var type: UpgradeType
@export var value: float
