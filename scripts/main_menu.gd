extends CanvasLayer

@onready var play_button = $Play
@onready var quit_button = $Quit

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	GameManager.reset_game()

func _on_quit_pressed():
	get_tree().quit()
