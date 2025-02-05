extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(100000):  # Adjust the number for the desired delay
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://assets/5DYDKrW.jpeg")  # Use an actual texture path
		sprite.position = Vector2(randf_range(0, 1000), randf_range(0, 1000))
		add_child(sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
