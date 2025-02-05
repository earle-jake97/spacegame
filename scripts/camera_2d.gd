extends Camera2D

# Variable to control how much the camera moves up/down
@export var camera_distance: float = 50.0  # Set default movement distance

# Original position for resetting
var original_position: Vector2

func _ready():
	original_position = position  # Store the initial position

func _physics_process(delta: float):
	var target_position = original_position  # Default to original position

	if Input.is_action_pressed("up"):
		target_position = original_position + Vector2(0, -camera_distance)
	elif Input.is_action_pressed("down"):
		target_position = original_position + Vector2(0, camera_distance)

	# Smoothly move the camera
	position = position.lerp(target_position, 4 * delta)
