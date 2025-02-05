extends Node

var player_health = 100
var player_max_health = 100
var immune = false
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var gameover_label: Label = $CanvasLayer/GameoverLabel
@onready var timer: Timer = $Timer
@onready var i_frames: Timer = $IFrames
@export var unlockAll: bool = false
var timer_started = false
var upgrades = []



func _ready() -> void:
	health_label = get_node("/root/GameManager/CanvasLayer/HealthLabel") as Label
	gameover_label = get_node("/root/GameManager/CanvasLayer/GameoverLabel") as Label
	timer = get_node("/root/GameManager/Timer") as Timer
	if unlockAll:
		upgrades.append("melee")
		upgrades.append("dash")
		upgrades.append("jump")
		

func is_player_immune():
	return immune
func set_player_immune(boolean):
	immune = boolean

func harm_player(damage):
	if not is_player_immune():
		set_player_immune(true)
		i_frames.start()
		print("taking dmg")
		player_health -= damage

func _process(delta: float) -> void:
	if player_health <= 0 && !timer_started:
		player_health = 0
		timer_started = true
		timer.start()
		gameover_label.visible = true
	elif player_health <= 0:
		player_health = 0
	health_label.text = "Health: " + str(player_health) + "/" + str(player_max_health)
	

func _on_timer_timeout() -> void:
	player_health = player_max_health
	immune = false
	health_label.text = "Health: " + str(player_health) + "/" + str(player_max_health)
	gameover_label.visible = false
	timer_started = false
	get_tree().reload_current_scene()

func _on_i_frames_timeout() -> void:
	set_player_immune(false)
