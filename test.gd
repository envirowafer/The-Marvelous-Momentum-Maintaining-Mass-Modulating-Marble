extends Node2D


@onready var ball: RigidBody2D = $Ball


@export_range(0,1000) var impulse_magnitude = 200.0


func _ready():
	ball.apply_impulse(impulse_magnitude * Vector2(1, -1).normalized())


# DEBUGGING: reload scene for convenience
func _input(event: InputEvent):
	if event.is_action_pressed("debug_reload_scene"):
		get_tree().reload_current_scene()
