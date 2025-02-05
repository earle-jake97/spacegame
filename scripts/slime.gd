extends CharacterBody2D

const SPEED = 60

var direction = 1
@onready var raycast_right: RayCast2D = $RaycastRight
@onready var raycast_left: RayCast2D = $RaycastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var timer: Timer = $Timer
@onready var hitbox: Area2D = $Hitbox


@export var health = 30

@export var can_move = true
@export var lightness = 200.0
@export var damage: int

const GRAVITY = 980.0 # Default gravity
const FALL_MULTIPLIER = 2 # Increases gravity when falling to reduce floatiness



var can_flinch = true
var timer_on = false
var is_inside = false
var dashed_through = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not can_move:
		if player.global_position.x > global_position.x:
				animated_sprite.flip_h = false

		else: animated_sprite.flip_h = true
	if velocity.y > 0: # Falling
		velocity.y += GRAVITY * FALL_MULTIPLIER * delta
	elif not is_on_floor(): # Rising but not falling
		velocity.y += GRAVITY * delta
	if(health <= 0):
			queue_free()
	if(is_inside):
		if can_flinch and not player.is_dashing:
			can_flinch = false
			timer_on = true
			timer.start()
			var direction = 1 if player.global_position.x > global_position.x else -1
			player.flinch_from_enemy(direction)  # Apply the flinch to the player

	if raycast_right.is_colliding() and not raycast_right.get_collider().is_in_group("player"):
		direction = -1
		animated_sprite.flip_h = true
		
	if raycast_left.is_colliding() and not raycast_left.get_collider().is_in_group("player"):
		direction = 1
		animated_sprite.flip_h = false
		
	if can_move and is_on_floor():
		velocity.x = move_toward(velocity.x, direction * SPEED, 15)
	if not can_move and is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 15)

	
	move_and_slide()



func _on_timer_timeout() -> void:
			can_flinch = true
			timer_on = false

func take_damage(damage):
	var cursor_pos = get_global_mouse_position()
	var direction = (cursor_pos - player.global_position).normalized()
	print("Cursor direction: " + str(direction))
	if dashed_through:
		velocity.y = -1 * (lightness/1.2)
		velocity.x = -direction.x*lightness/3
	else:
		velocity.y = -1 * (lightness/1.2)
		velocity = direction * lightness
		velocity.y -= lightness / 1.2  # Add upward velocity for a "knockback" effect
	dashed_through = false
	health -= damage

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var player = area.get_parent()
		while player and not player.is_in_group("player"):
			player = player.get_parent()
		if player and player.has_method("flinch_from_enemy"):
			is_inside = true
		if player and is_inside and GameManager.is_player_immune() == false and not player.is_dashing:
			GameManager.harm_player(damage)

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		if player.is_dashing:
			dashed_through = true
			take_damage(5)
		if player.has_method("flinch_from_enemy"):
			is_inside = false
