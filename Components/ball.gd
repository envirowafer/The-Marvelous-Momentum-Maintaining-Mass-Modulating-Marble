class_name Ball extends RigidBody2D
## A ball that changes size with mouse movement.
## Size changes conserve momentum and density, but do not conserve velocity,
## mass, or energy.
## Can be launched out of a launcher.
## Draws a dotted line that shows the ball's trajectory.


## Represents the state of the ball.
enum State {
	HELD, ## The ball is held by a launcher.
	ROLLING ## The ball is rolling around on the game board.
}


## Starting value of the radius.
const DEFAULT_RADIUS: float = 20.0
## Starting value of the mass.
const DEFAULT_MASS: float = 1.0
## Minimum allowed radius.
const MIN_RADIUS: float = 15.0
## Maximum allowed radius.
const MAX_RADIUS: float = 30.0


## Controls the ball's current state.
@export var state: State = State.HELD:
	# update physics and sound to match current state
	set(value):
		state = value
		
		# only proceed when this node is ready
		# ensures node references have been initialized
		if not is_node_ready():
			await ready
		
		# play or pause roll sound according to state
		if value == State.ROLLING:
			_roll_sound.play()
		_roll_sound.stream_paused = (value != State.ROLLING)
		
		# freeze or unfreeze ball according to state
		freeze = (value == State.HELD)
		set_deferred("lock_rotation", value == State.HELD)
		trajectory_hint.frozen = (value == State.HELD)

## The component that controls the ball's trajectory hint.
@onready var trajectory_hint: TrajectoryHint = $"Trajectory Hint"

## Set by parent launcher. Indicates whether this ball belongs to a launcher.
var is_child_of_launcher: bool = false

## Set by parent launcher. If ball is a child of a launcher, this is the
## impulse that launcher applies to this ball.
var launch_impulse: Vector2 

## Enables and disables input.
var is_input_enabled: bool = true


## The most the radius can change in a frame.
const MAX_RADIUS_DELTA: float = 5.0

# The amount that mouse movement changes the radius.
var _mouse_sensitivity: float = 0.05

## Set the mouse sensitivity to a particular value. The default is 1.
## This method is called by a global group.
func set_mouse_sensitivity(value: float):
	_mouse_sensitivity = 0.05 * value


## Controls the ball's current size.
var radius: float = DEFAULT_RADIUS:
	set(value):
		radius = value
		
		# update the sprite's radius
		_circle_renderer.radius = radius
		
		# update the collision shape's radius to match the ball's radius
		if is_instance_valid(_collision_shape_2d):
			_collision_shape_2d.shape.radius = radius
		
		# update mass and velocity to conserve momentum
		var new_mass = _radius_to_mass(radius)
		var new_linear_velocity = mass * linear_velocity / new_mass
		mass = new_mass
		linear_velocity = new_linear_velocity

# We can't have the radius change too fast,
# so instead of the player controlling the radius directly,
# the player controls this target radius
# that the actual radius will move toward every frame or physics frame.
var _target_radius: float = radius

# Computes the ball's mass from its radius.
func _radius_to_mass(r: float) -> float:
	var scale_factor = r / DEFAULT_RADIUS
	return DEFAULT_MASS * scale_factor**2


@onready var _circle_renderer: CircleRenderer = $"Circle Renderer"
@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var _bounce_sound: AudioStreamPlayer2D = $Sounds/Bounce
@onready var _roll_sound: AudioStreamPlayer2D = $Sounds/Roll
@onready var _fall_sound: AudioStreamPlayer2D = $Sounds/Fall

# If true, the ball will launch on the next physics update.
# Set by the public method [queue_launch].
var _is_launch_queued: bool = false


func _ready():
	# call the set function for the ball's state to update physics and sound
	state = state
	
	# set the default mass
	mass = DEFAULT_MASS
	
	# set the initial collision shape radius to match the ball's radius
	_collision_shape_2d.shape.radius = radius
	
	# share linear damping with trajectory hint
	trajectory_hint.linear_damp = linear_damp
	
	# share min and max mass with roll sound
	_roll_sound.min_mass = _radius_to_mass(MIN_RADIUS)
	_roll_sound.max_mass = _radius_to_mass(MAX_RADIUS)
	
	# share min and max mass with bounce sound
	_bounce_sound.min_mass = _radius_to_mass(MIN_RADIUS)
	_bounce_sound.max_mass = _radius_to_mass(MAX_RADIUS)
	
	# set the mouse mode to take input from it
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float):
	# move the actual radius toward the target radius
	# radius updates in _integrate_forces if not frozen
	if freeze and radius != _target_radius:
		radius = move_toward(radius, _target_radius, MAX_RADIUS_DELTA)
	
	# update the linear velocity used to compute the trajectory hint
	if state == State.HELD and is_child_of_launcher:
		trajectory_hint.linear_velocity = launch_impulse / mass
	else:
		trajectory_hint.linear_velocity = linear_velocity
	
	# update parameters used to compute roll sound volume and pitch
	_roll_sound.speed = linear_velocity.length()
	_roll_sound.mass = mass


func _integrate_forces(_state):
	# move the actual radius toward the target radius
	# radius updates in _process if frozen
	if radius != _target_radius:
		radius = move_toward(radius, _target_radius, MAX_RADIUS_DELTA)
	
	# if the parent launcher has queued a launch, then
	# launch the ball and unqueue the launch
	if _is_launch_queued:
		# make sure ball is not moving prior to launch
		linear_velocity = Vector2.ZERO
		position = Vector2.ZERO
		angular_velocity = 0
		rotation = 0
		
		# set ball state to rolling
		state = State.ROLLING
		
		# make sure trajectory hint is enabled
		trajectory_hint.enabled = true
		
		# launch the ball
		apply_impulse(launch_impulse)
		
		# unqueue the launch
		_is_launch_queued = false


# Use mouse input to change the target radius.
func _unhandled_input(event):
	if is_input_enabled and event is InputEventMouseMotion:
		var delta_radius = _mouse_sensitivity * event.screen_relative.y
		if delta_radius != 0:
			var r = _target_radius + delta_radius
			r = clamp(r, MIN_RADIUS, MAX_RADIUS)
			_target_radius = r


# Play sound effect when colliding with walls.
func _on_body_entered(_body: Node):
	var speed = linear_velocity.length()
	_bounce_sound.play_with_parameters(speed, mass)


## Launch the ball on the next physics frame.
func queue_launch():
	# Unfreeze outside [state] set function so that [_integrate_forces] is
	# called. State needs to change at the same time the impulse is applied
	# so trajectory hint does not break.
	freeze = false
	_is_launch_queued = true


## Play fall sound, reset ball position, and set ball state.
## Called by kill zones when ball falls into them.
func fall():
	_fall_sound.play()
	if is_child_of_launcher:
		linear_velocity = Vector2.ZERO
		position = Vector2.ZERO
		angular_velocity = 0
		rotation = 0
		state = State.HELD
