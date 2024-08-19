extends Node2D


@export_range(0,2000) var launch_impulse_magnitude = 1000.0


@onready var ball: RigidBody2D = $Ball


# variable for enabling and disabling input
# setter may be called via global group for screen transitions
var input_enabled = true:
	set(value):
		input_enabled = value
		if is_instance_valid(ball):
			ball.input_enabled = value


# compute local and global vectors for impulse applied to ball
@onready var local_launch_impulse = launch_impulse_magnitude * Vector2.UP
@onready var global_launch_impulse = local_launch_impulse.rotated(global_rotation)


func _ready():
	# share variables with child ball
	ball.is_child_of_launcher = true
	ball.launch_impulse = global_launch_impulse
	ball.freeze = true


# launch the ball when the player does the launch action
func _input(event: InputEvent):
	if input_enabled and event.is_action_pressed("activate_launcher"):
		if is_instance_valid(ball) and ball.freeze:
			ball.freeze = false
			ball.launch_queued = true


# teleport the ball back to the launcher
func reset_ball():
	ball.reset_ball()
