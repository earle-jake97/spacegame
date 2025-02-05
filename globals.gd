extends Node

var loading_screen = preload("res://assets/loading screens/loading_screen_overworld_underground.tscn")

var prev_scene: String = ("res://scenes/overworld/overworld_01.tscn")
var next_scene: String = ("res://scenes/overworld/overworld_01.tscn")
var spawn_location: int = 0
var spawn_direction: String = "left"
