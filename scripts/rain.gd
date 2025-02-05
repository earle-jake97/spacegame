extends Node2D

@onready var rain: CPUParticles2D = $"."

# Export parameters for customizing the rain
@export var particle_count: int = 1000
@export var rain_speed: float = 100
@export var rain_width: float = 400
@export var rain_height: float = 600

func _ready():
	var material = ParticleProcessMaterial.new()
	material.velocity = Vector2(0, rain_speed)  # Falling down
	material.gravity = Vector2(0, 1000)  # Simulate gravity
	material.lifetime = 3.0  # Rain drop lifetime
	material.angle = deg_to_rad(90)  # Vertical falling

	rain.process_material = material
	rain.emitting = true
	rain.amount = particle_count
	rain.position = Vector2(rain_width / 2, rain_height)
