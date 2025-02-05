extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
var tween:Tween = create_tween()

# Fade in effect (slowly make the ColorRect transparent)
func fade_in() -> void:
	fade_rect.visible = true
	tween.tween_property(fade_rect, "modulate", Color(0,0,0,0), 1)
	tween.play()

# Fade out effect (slowly make the ColorRect opaque)
func fade_out() -> void:
	fade_rect.visible = true
	tween.tween_property(fade_rect, "modulate", Color(0,0,0,1), 1)
