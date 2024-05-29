extends Camera2D

var target_zoom: float = zoom.x

const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 1.0
const ZOOM_INCREMENT: float = 0.1

const ZOOM_RATE: float = 8.0

const CAMERA_SPEED: float = 800.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()

func _physics_process(delta: float) -> void:
	zoom = lerp(
		zoom,
		target_zoom * Vector2.ONE,
		ZOOM_RATE * delta
	)
	set_physics_process(
		not is_equal_approx(zoom.x, target_zoom)
	)

func _process(delta):
	var motion = Vector2()
	# WASD movement
	if Input.is_action_pressed("camera_up"):
		motion.y -= 1
	if Input.is_action_pressed("camera_down"):
		motion.y += 1
	if Input.is_action_pressed("camera_left"):
		motion.x -= 1
	if Input.is_action_pressed("camera_right"):
		motion.x += 1

	# Normalize the motion vector to ensure consistent speed in all directions
	motion = motion.normalized()

	# Move the camera
	position += motion * CAMERA_SPEED * delta


func zoom_out() -> void:
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_in() -> void:
	target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)
