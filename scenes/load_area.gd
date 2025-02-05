extends Node2D

@onready var globals = Globals
var current_scene = ""  # Initialize as an empty string to prevent errors
@export var next_scene: String
@export var loading_area: int
@export var direction: String
@onready var timer = 0
@onready var fade_effect: Control = $"../Fade_Effect"

func _ready() -> void:
	call_deferred("_set_current_scene")  # Defer getting current scene to avoid null errors

func _set_current_scene() -> void:
	var scene = get_tree().current_scene if get_tree().current_scene else get_tree().get_root().get_child(0)
	if scene:
		current_scene = scene.scene_file_path
	else:
		print("Warning: current_scene is null!")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		fade_effect.fade_out()
		globals.spawn_location = loading_area
		globals.prev_scene = current_scene
		globals.next_scene = next_scene
		print("Previous: ", globals.prev_scene, "Current: ", globals.next_scene)
		if direction == "left":
			get_tree().change_scene_to_packed(load("res://assets/loading screens/loading_screen_overworld_underground.tscn"))
		else:
			get_tree().change_scene_to_packed(load("res://assets/loading screens/loading_screen_overworld_underground_right.tscn"))
