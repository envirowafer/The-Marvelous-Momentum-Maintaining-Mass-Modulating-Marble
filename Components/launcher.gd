extends Node2D


@export_range(0,2000) var launch_impulse_magnitude = 1000.0
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D
@onready var launch_cooldown: Timer = $"Launch Cooldown"
var can_launch = true


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
	ball.play_roll_sound = false
	ball.launch_impulse = global_launch_impulse
	ball.freeze = true


# launch the ball when the player does the launch action
func _input(event: InputEvent):
	if input_enabled and event.is_action_pressed("activate_launcher"):
		if not can_launch:
			return
		
		can_launch = false
		launch_cooldown.start()
		
		if is_instance_valid(ball) and ball.freeze:
			ball.trajectory_hint = true
			ball.freeze = false
			ball.launch_queued = true
			ball.play_roll_sound = true
			audio_stream_player_2d.play()
		
		# launch everything in here that is not the ball
		var overlapping_bodies = area_2d.get_overlapping_bodies()
		for body in overlapping_bodies:
			if (body != self) and (not body.freeze):
				body.trajectory_hint = true
				body.apply_impulse(global_launch_impulse)


# teleport the ball back to the launcher
func reset_ball():
	ball.reset_ball()


# allow launching when cooldown is up
func _on_launch_cooldown_timeout() -> void:
	can_launch = true


func _process(_delta: float):
	for body in area_2d.get_overlapping_bodies():
		if (body != self) and (not body.freeze):
			if body.trajectory_hint == true and body.linear_velocity.length() < 10:
				body.trajectory_hint = false
			if body.trajectory_hint == false and body.linear_velocity.length() >= 10:
				body.trajectory_hint = true
