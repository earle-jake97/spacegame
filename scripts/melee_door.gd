extends StaticBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $collision
var is_open = false
@onready var melee_collision: CollisionShape2D = $melee_detect_area/meleeCollision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_melee_detect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_weapon") and not is_open:
		animated_sprite_2d.play("open")
		collision.set_deferred("disabled", true)
		melee_collision.set_deferred("disabled", true)
		is_open = true


func _on_player_detect_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and is_open:
		animated_sprite_2d.play("close")
		collision.set_deferred("disabled", false)
		melee_collision.set_deferred("disabled", false)
		is_open = false
		
		
