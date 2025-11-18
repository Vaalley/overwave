extends Resource
class_name UpgradeData

enum UpgradeType { PLAYER_SPEED, ATTACK_SPEED }

@export var name: String
@export_multiline var description: String
@export var type: UpgradeType
@export var value: float
