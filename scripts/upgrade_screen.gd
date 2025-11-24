extends CanvasLayer

@export var all_upgrades: Array

@onready var button1 = $VBoxContainer/Button
@onready var button2 = $VBoxContainer/Button2
@onready var button3 = $VBoxContainer/Button3


func _ready():
	# ExperienceManager.level_up.connect(_on_level_up)
	button1.pressed.connect(_on_choice_made.bind(button1))
	button2.pressed.connect(_on_choice_made.bind(button2))
	button3.pressed.connect(_on_choice_made.bind(button3))


func _on_level_up(_new_level):
	get_tree().paused = true
	self.visible = true

	all_upgrades.shuffle()
	var choices = all_upgrades.slice(0, 2)
	
	button1.text = choices[0].name
	button2.text = choices[1].name
	#button3.text = choices[2].name
	
	button1.set_meta("upgrade", choices[0])
	button2.set_meta("upgrade", choices[1])
	#button3.set_meta("upgrade", choices[2])


func _on_choice_made(button_pressed: Button):
	var upgrade_chosen: UpgradeData = button_pressed.get_meta("upgrade")
	
	get_tree().get_first_node_in_group("Player").apply_upgrade(upgrade_chosen)
	
	get_tree().paused = false
	self.visible = false
