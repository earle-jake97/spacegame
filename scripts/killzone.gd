extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager = GameManager
@export var damage_amount: int = 1
@onready var damage_timer: Timer = $damage_timer
@onready var player = get_tree().get_first_node_in_group("player")
var is_entered = false


func _on_body_entered(body: Node2D) -> void:
	is_entered = true

func _on_body_exited(body: Node2D) -> void:
	is_entered = false

func _process(delta: float) -> void:
	if is_entered and game_manager.is_player_immune() == false and not player.is_dashing:
		game_manager.harm_player(damage_amount)
