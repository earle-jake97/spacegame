extends Node2D

@onready var player = Player
@onready var fire_timer: Timer = $Timer
@onready var detection_area: Area2D = $DetectionRange
@onready var collision_shape: CollisionShape2D = $DetectionRange/DetectionShape

@export var health: int = 20
@export var fire_rate: float = 1.0  # Time between shots (seconds)
@export var detection_range: float = 300.0  # Range to detect the player
const projectile_scene = preload("res://scenes/turret_projectile.tscn")

var player_in_range = false

func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()

func _ready() -> void:
	fire_timer.wait_time = fire_rate
	fire_timer.connect("timeout", Callable(self, "_on_fire_timer_timeout"))
	detection_area.connect("area_entered", Callable(self, "_on_detection_area_entered"))
	detection_area.connect("area_exited", Callable(self, "_on_detection_area_exited"))

	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = detection_range
func _physics_process(delta: float) -> void:
	if player_in_range and player:
		look_at(player.global_position)  # Rotate to face the player

func _on_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):  # Ensure it's the player entering the range
		player_in_range = true
		fire_timer.start()

func _on_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_in_range = false
		fire_timer.stop()

func _on_fire_timer_timeout() -> void:
	if player_in_range:
		fire_projectile()

func fire_projectile() -> void:
	if not player:  # Ensure player still exists
		return
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	projectile.rotation = rotation
	get_parent().add_child(projectile)
