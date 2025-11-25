extends Camera2D

var speed = 300
var zoom_speed = 0.1
var super_speed = speed * 2.0

func _process(delta: float) -> void:
	var move = Input.get_vector("left", "right", "up", "down")

	if Input.is_key_pressed(KEY_SHIFT):
		position += move * super_speed * delta
	else:
		position += move * speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoom_speed, zoom_speed)
			# Clamp zoom so it doesn't invert
			zoom.x = max(0.1, zoom.x)
			zoom.y = max(0.1, zoom.y)
