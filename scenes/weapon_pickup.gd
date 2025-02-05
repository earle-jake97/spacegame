extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.upgrades.has("melee"):
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameManager.upgrades.append("melee")
		queue_free()
