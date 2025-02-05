extends Node2D

@export var speed: float = 200.0
@export var lifetime: float = 10  # Time before the projectile disappears
@export var damage_amount: float
@onready var damage_timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D

const projectile_scene = preload("res://scenes/turret_projectile.tscn")
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
	var cursor_position = get_global_mouse_position()
	var direction = (cursor_position - player.global_position).normalized()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("must_be_deflected") and area.get_parent().has_method("take_damage")) or (not area.is_in_group("must_be_deflected") and area.is_in_group("enemy") and area.get_parent().has_method("take_damage")):
		area.get_parent().take_damage(damage_amount)
		queue_free()




func _on_timer_timeout() -> void:
		has_damaged = false

func deflect() -> void:
	print("deflected")
