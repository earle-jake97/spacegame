extends Node2D

@export var spawn_value: int  # Exposed to the editor for easy reference
@onready var player = get_tree().get_first_node_in_group("player")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player and spawn_value == Globals.spawn_location:
		call_deferred("set_player_pos")
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_player_pos() -> void:
	player.global_position = global_position

		
	var children = player.get_children()
	for child in children:
		if child.name == "Camera2D":
			child.global_position = global_position
