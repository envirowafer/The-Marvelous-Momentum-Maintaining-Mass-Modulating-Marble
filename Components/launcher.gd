extends Node2D


@export_range(0,2000) var launch_impulse_magnitude = 1000.0
var local_launch_impulse = launch_impulse_magnitude * Vector2.UP
var global_launch_impulse = local_launch_impulse.rotated(global_rotation)


@onready var ball: RigidBody2D = $Ball


func _ready():
	ball.is_child_of_launcher = true
	ball.launch_impulse = global_launch_impulse
	ball.freeze = true


func _input(event: InputEvent):
	if event.is_action_pressed("activate_launcher"):
		ball.freeze = false
		ball.launch_queued = true
