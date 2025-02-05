extends Control

@onready var player_sprite: AnimatedSprite2D = $player_sprite
var next_scene = Globals.next_scene
var min_duration = 2.0
var timer = 0
@onready var fade_effect: Control = $Fade_Effect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(Globals.next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	player_sprite.global_position.x += progress[0]*0.2
	if timer == 0.2:
		fade_effect.fade_in()
	if timer == 1.8:
		fade_effect.fade_out()
	
	if progress[0] == 1 and timer >= min_duration:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
