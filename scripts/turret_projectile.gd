extends Node2D

@export var speed: float = 200.0
@export var lifetime: float = 2.0  # Time before the projectile disappears
@export var damage_amount: float
@onready var damage_timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D
@onready var player = Player

const projectile_scene = preload("res://scenes/turret_projectile_reflected.tscn")
const deflectable = true

var is_entered = false
var game_manager = GameManager
var has_damaged = false  # Track if damage has been dealt



func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += Vector2(cos(rotation), sin(rotation)) * speed * delta

func _process(delta: float) -> void:
	if is_entered and not has_damaged:
		if game_manager and not game_manager.is_player_immune() and not player.is_dashing:
			game_manager.harm_player(damage_amount)
			var direction = 1 if player.global_position.x > global_position.x else -1
			player.flinch_from_enemy(direction)
			has_damaged = true
			damage_timer.start()
		else: return


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_entered = true
	if area.is_in_group("deflect_weapon"):
		deflect()
		queue_free()



func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_entered = false

func _on_timer_timeout() -> void:
		has_damaged = false

func deflect() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = player.global_position
	projectile.damage_amount = damage_amount * 2
	projectile.speed = speed
	var cursor_position = get_global_mouse_position()
	var new_direction = (cursor_position - player.global_position).normalized()
	projectile.rotation = new_direction.angle()
	get_tree().root.add_child(projectile)
	print("deflected")
