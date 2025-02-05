extends Area2D

@export var damage: int = 10  # Damage the hitbox deals
@onready var player = get_tree().get_first_node_in_group("player")
var flinch_timer = 0.0
var is_hit = false
var knockback_force = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_hit:
		# Gradually reduce knockback over time
		flinch_timer -= delta
		if flinch_timer <= 0:
			knockback_force = Vector2.ZERO
			is_hit = false

func deal_damage(enemy: Node) -> void:
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(damage)  # Call a method on the enemy to apply damage

func _on_area_entered(area: Area2D) -> void:
	print(area.name)
	if area.is_in_group("enemy"):
		deal_damage(area.get_parent())
		# Calculate knockback force based on the direction to the enemy
		print("Player position: " + str(player.global_position) + " Enemy: " + str(area.global_position))
		knockback_force = (player.global_position - area.get_parent().global_position).normalized()

		print(player.velocity.y)
		# Apply immediate knockback
		if knockback_force.y > 0:  
			player.velocity.x += knockback_force.x * 500
		# Enemy below player
		else:
			if player.velocity.y >= -80:
				player.velocity.y = knockback_force.y * 100 -100
			
			player.velocity.x += knockback_force.x * 400 + 100

		is_hit = true
		flinch_timer = 0.1  # Adjust flinch duration as needed
