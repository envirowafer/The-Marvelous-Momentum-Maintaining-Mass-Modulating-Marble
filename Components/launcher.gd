class_name Launcher extends Node2D
## Lauches the [Ball] with a fixed impulse.


## Impulse to launch the ball with.
@export_range(0,2000) var launch_impulse_magnitude: float = 1000.0


## Reference to this launcher's ball.
@onready var ball: Ball = $Ball

## Variable for enabling and disabling input for the ball.
## Setter may be called via global group for screen transitions.
var input_enabled: bool = true:
	set(value):
		input_enabled = value
		if is_instance_valid(ball):
			ball.input_enabled = value


@onready var _launch_sound: AudioStreamPlayer2D = $"Launch Sound"
@onready var _launch_area: Area2D = $"Launch Area"
@onready var _launch_cooldown: Timer = $"Launch Cooldown"

# Used for implementing launch cooldown.
var _can_launch: float = true

# Local impulse vector applied to ball.
@onready var _local_launch_impulse: Vector2 = launch_impulse_magnitude * Vector2.UP
# Global impulse vector applied to ball.
@onready var _global_launch_impulse: Vector2 = _local_launch_impulse.rotated(global_rotation)


func _ready():
	# set variables of child ball
	ball.is_child_of_launcher = true
	ball.launch_impulse = _global_launch_impulse


func _process(_delta: float):
	# show/hide trajectory hints for loose objects inside launcher
	for body in _launch_area.get_overlapping_bodies():
		if (body != self) and (not body.freeze):
			if body.trajectory_hint.enabled == true and body.linear_velocity.length() < 10:
				body.trajectory_hint.enabled = false
			if body.trajectory_hint.enabled == false and body.linear_velocity.length() >= 10:
				body.trajectory_hint.enabled = true


func _input(event: InputEvent):
	# launch the ball when the player does the launch action
	
	# check for user input
	if input_enabled and event.is_action_pressed("activate_launcher"):
		# stop if launching is currently disabled
		if not _can_launch:
			return
		
		# disable launching for duration of cooldown
		_can_launch = false
		_launch_cooldown.start()
		
		# if the ball is held, launch it
		if is_instance_valid(ball) and ball.state == ball.State.HELD:
			ball.queue_launch()
			_launch_sound.play()
		
		# launch everything in the launcher that is not the ball
		var overlapping_bodies = _launch_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if (body != self) and (not body.freeze):
				body.trajectory_hint.enabled = true
				body.apply_impulse(_global_launch_impulse)


# Allow launching when cooldown is up.
func _on_launch_cooldown_timeout():
	_can_launch = true
