extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -130.0
const JUMP_HOLD_TIME = 0.1 # Maximum time the jump button can be held for a higher jump
const GRAVITY = 400 # Default gravity
const FALL_MULTIPLIER = 1.5 # Increases gravity when falling to reduce floatiness
const MAX_FALL_SPEED = 200.0 # Maximum downward velocity
const ASCENT_MULTIPLIER = 1 # Reduced gravity while ascending
const UNDERWATER_GRAVITY = 100.0  # Reduced gravity underwater
const UNDERWATER_JUMP_VELOCITY = -60.0  # Lower jump height underwater
const UNDERWATER_FLOATINESS = 0.5  # Increase floatiness underwater

@export var max_aerial_jumps: int = 0
@export var dash_distance: int = 300

@onready var game_manager = GameManager
@onready var meleeVariable = get_tree().get_first_node_in_group("player_weapon")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var canvas_modulate: CanvasModulate = $AnimatedSprite2D/CanvasModulate
@onready var attack_hitbox: Area2D = $MeleeArea
@export var attack_duration: float = 0.2  # Duration of the attack (in seconds)
@export var attack_damage: int = 10  # Damage dealt by the attack
@export var attack_range: float = 10.0  # Distance the hitbox appears from the player

var jump_time_remaining = 0.0 # Timer for jump hold duration
var is_jumping = false # Track whether the player is in a jump
var is_flinched = false
var flinch_timer = 0.0 # Timer for how long the flinch lasts
var flinch_duration = 0.1 # Duration of the flinch effect
var flinch_strength = 400 # Strength of the push away from the enemy
var aerial_jumps_used = 0
var is_dashing = false
var dash_timer = 0.0
var dash_duration = 0.3
var dash_velocity
var is_underwater = false

var cursor_position = Vector2.ZERO
var mouseDirection = Vector2.ZERO
var attacking = false
var temp_jumps = 0


var dashed_from_air = false

func _ready() -> void:
	attack_hitbox.global_position = Vector2(-1000000000, -1000000000)
	for upgrade in game_manager.upgrades:
		if "jump" in upgrade:
			temp_jumps += 1
			max_aerial_jumps = temp_jumps
	
func _physics_process(delta: float) -> void:
	
	cursor_position = get_global_mouse_position()  # Get mouse position in the global coordinates
	mouseDirection = (cursor_position - global_position).normalized()
	
		# Adjust gravity if underwater
	var current_gravity = GRAVITY
	var current_jump_velocity = JUMP_VELOCITY

	if is_underwater:
		current_gravity = UNDERWATER_GRAVITY
		current_jump_velocity = UNDERWATER_JUMP_VELOCITY
	
	if is_dashing:
		if velocity.x < 0:
			animated_sprite.flip_h = true
			animated_sprite.rotate(-0.5)
		else:
			animated_sprite.flip_h = false
			animated_sprite.rotate(0.5)
			
		velocity = dash_velocity
		dash_timer -= delta
		if is_on_floor() and dashed_from_air:
			if velocity.x < 0:
				dash_velocity = Vector2(-1,0) * dash_distance
			else:
				dash_velocity = Vector2(1,0) * dash_distance
		if dash_timer <= 0:
			is_dashing = false
			animated_sprite.rotation = 0
			velocity = Vector2(0, 0)
	
	if Input.is_action_just_pressed("Dash") and game_manager.upgrades.has("dash"):
		dash()
	
	if Input.is_action_just_pressed("Melee") and game_manager.upgrades.has("melee"):
		attack()
	
	if is_flinched:
		flinch_timer -= delta
		if flinch_timer <= 0:
			is_flinched = false
			velocity.x = 0
			animated_sprite.modulate = Color(1, 1, 1) # Reset color to white
	# Add gravity with a fall multiplier if descending
	if velocity.y > 0: # Falling
		velocity.y += current_gravity * FALL_MULTIPLIER * delta
	elif not is_on_floor() and velocity.y < 0: # Rising
		velocity.y += current_gravity * delta * ASCENT_MULTIPLIER
	else: 
		velocity.y += current_gravity * delta

	# Clamp the maximum downward velocity
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	# Handle jumps
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		jump(delta, current_jump_velocity)
	elif Input.is_action_just_pressed("jump") and aerial_jumps_used < max_aerial_jumps and not is_dashing:
		jump(delta, current_jump_velocity)
		aerial_jumps_used += 1

	if Input.is_action_pressed("jump") and is_jumping and not is_dashing:
		# Continue jump if button is held and within time limit
		if jump_time_remaining > 0:
			velocity.y -= current_gravity* ASCENT_MULTIPLIER * delta
			jump_time_remaining -= delta
		else:
			is_jumping = false

	if Input.is_action_just_released("jump") and velocity.y < 0 and not is_dashing:
		# Stop jump boost when button is released
		velocity.y /= 5
		is_jumping = false

	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# ANIMATIONS
	if is_on_floor():
		aerial_jumps_used = 0
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	if direction:
		if is_flinched:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)
		#If it is not on the floor or hasn't just hit something, no immediate movement
		elif not is_on_floor() or meleeVariable and not is_dashing:
			velocity.x = move_toward(velocity.x, direction * SPEED, 30)
		elif not is_on_floor() or meleeVariable and is_dashing:
			pass
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)

	move_and_slide()

# Function to trigger flinch when the player is hit by an enemy
func flinch_from_enemy(direction) -> void:
	print("Should be flinching")
	# Set the flinch state and apply a push in the opposite direction of the enemy
	is_flinched = true
	flinch_timer = flinch_duration
	if animated_sprite.modulate == Color(1, 1, 1):
		animated_sprite.modulate = Color(1, 0, 0)  # Flash red
	else:
		animated_sprite.modulate = Color(1, 1, 1)  # Reset to white
	# Determine direction to push the player based on the enemy's position
	if direction == -1:
		# Enemy is to the right, push player to the left
		velocity.x = -flinch_strength
	else:
		# Enemy is to the left, push player to the right
		velocity.x = flinch_strength

func jump(delta, jump_velocity) -> void:
	velocity.y = jump_velocity
	is_jumping = true
	jump_time_remaining = JUMP_HOLD_TIME
	
func attack():
	if not attacking:
		attacking = true
		attack_hitbox.monitoring = true
		print("Attacking:" + str(attacking))
		print(attack_hitbox.position)
		
		print(attack_hitbox.get_child(1).position)
		
		
		# Position the hitbox a certain distance from the player
		attack_hitbox.global_position = global_position + mouseDirection * attack_range
		print("Player: " + str(position) + " Attack" + str(attack_hitbox.global_position))
		var sprite = attack_hitbox.get_child(1)
		sprite.visible = true
		sprite.position = Vector2.ZERO
		var angle = mouseDirection.angle()/2  # Angle in radians

		attack_hitbox.rotation = angle
		sprite.rotation = angle
		sprite.play("default")
		
		# After the attack duration, disable the hitbox again
		await get_tree().create_timer(attack_duration).timeout
		attack_hitbox.global_position = Vector2(-999999999, -999999999)
		
		
		attacking = false
		sprite.visible = false
		
		print("Attacking:" + str(attacking))
func dash():
	is_dashing = true
	dash_timer = dash_duration
	if is_on_floor():
		dashed_from_air = false
		if mouseDirection.x > 0:
			dash_velocity = dash_distance * Vector2(1,0)
		else:
			dash_velocity = dash_distance * Vector2(-1,0)
		
	else:
		dashed_from_air = true
		dash_velocity = mouseDirection * dash_distance


func _on_hurtbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		is_underwater = true
		velocity.y = 0


func _on_hurtbox_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("water"):
		is_underwater = false
