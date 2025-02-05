extends Node2D
@onready var fade_effect: Control = $"../Fade_Effect"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_effect.fade_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
