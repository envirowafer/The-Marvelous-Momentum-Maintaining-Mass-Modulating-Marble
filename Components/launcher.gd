extends Node2D


@export_range(0,2000) var launch_impulse_magnitude = 1000.0


@onready var ball: RigidBody2D = $Ball


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
	if event.is_action_pressed("activate_launcher"):
		ball.freeze = false
		ball.launch_queued = true


# teleport the ball back to the launcher
func reset_ball():
	ball.linear_velocity = Vector2.ZERO
	ball.position = Vector2.ZERO
	ball.angular_velocity = 0
	ball.rotation = 0
	ball.freeze = true


# reset the ball if it goes out of bounds
func _on_killzone_body_entered(body: Node2D) -> void:
	if is_same(body.get_path(), ball.get_path()):
		call_deferred("reset_ball")
