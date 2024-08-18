extends RigidBody2D


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# settings for trajectory hint
@export var trajectory_hint = true
const NUM_DOTS = 15
const DOT_RADIUS = 5.0
const DOT_TIME_SEPARATION = 0.1
const MIN_TRAJECTORY_HINT_SPEED = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var combined_damp = linear_damp + ProjectSettings.get_setting("physics/2d/default_linear_damp")

# keeps track of game time, used to render trajectory hint
var game_time = 0

# computes the alpha of each dot
var max_dot_time = NUM_DOTS * DOT_TIME_SEPARATION
func dot_t_to_alpha(t: float) -> float:
	t -= DOT_TIME_SEPARATION
	var numerator   = t * (max_dot_time - t) * (max_dot_time + 2)**2
	var denominator = (t+1) * (max_dot_time - t + 1) * (max_dot_time)**2
	return clamp(numerator/denominator, 0, 1)

# variables for handling trajectory preview when in launcher
var is_child_of_launcher = false # launcher will set this to true if ball is its child
var launch_impulse: Vector2 # launcher will set this if ball is its child


# variable for queuing a launch
# expected to be modified by parent launcher
var launch_queued = false


# settings for mouse control of radius
const MOUSE_SENSITIVITY = 0.05
const MAX_RADIUS_DELTA = 5.0


# settings for radius and mass
const DEFAULT_RADIUS = 20.0
const DEFAULT_MASS = 1
const MIN_RADIUS = 15.0
const MAX_RADIUS = 30.0

# compute the ball's mass from its radius
func radius_to_mass(r):
	var scale_factor = r / DEFAULT_RADIUS
	return DEFAULT_MASS * scale_factor**2


# controls the ball's current size
var radius = DEFAULT_RADIUS:
	set(value):
		radius = value
		# update the collision shape's radius to match the ball's radius
		if is_instance_valid(collision_shape_2d):
			collision_shape_2d.shape.radius = radius
			
			# update mass and velocity to conserve momentum
			var new_mass = radius_to_mass(radius)
			var new_linear_velocity = mass * linear_velocity / new_mass
			mass = new_mass
			linear_velocity = new_linear_velocity

# we can't have the radius change too fast,
# so instead of the player controlling the radius directly,
# the player controls this target radius
# that the actual radius will move toward every physics frame
var target_radius = radius


func _ready():
	# set the initial collision shape radius to match the ball's radius
	collision_shape_2d.shape.radius = radius
	
	# set the default mass
	mass = DEFAULT_MASS
	
	# set the mouse mode to take input from it
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# draw a custom sprite that scales with the radius
func _draw():
	# draw filled circle
	draw_circle(Vector2.ZERO, radius, Color.WHITE_SMOKE)
	
	# draw the trajectory hint if it is enabled
	if trajectory_hint:
		# pre-compute needed vectors
		# calculation expects vectors in global coordinates
		
		# use a dummy variable to customize preview velocity,
		# such as previewing lauch trajectory before launching.
		# also, linear_velocity is in global coordinates
		var simulated_velocity = linear_velocity
		
		# account for impulse of a launcher, if in one.
		# launch impulse is expected in global coordinates
		if is_child_of_launcher and (freeze or launch_queued):
			simulated_velocity += launch_impulse / mass
		
		
		# compute the gravity in global coordinates
		var gravity_vector = gravity * Vector2.DOWN
		
		# draw the dots
		for n in NUM_DOTS:
			# t is the time it is projected to take for the ball to reach this dot
			var t = (n+1) * DOT_TIME_SEPARATION - int(not freeze) * fposmod(game_time, DOT_TIME_SEPARATION)
			
			# compute delta_x, factoring in air resistance
			var a = 1 - exp(-t * combined_damp)
			var b = simulated_velocity/combined_damp - gravity_vector/(combined_damp**2)
			var c = t * gravity_vector / combined_damp
			var delta_x = a*b + c
			
			# compute remaining values needed
			var draw_radius = DOT_RADIUS * (DOT_TIME_SEPARATION+1) / (t+1)
			var color = Color(0.662745, 0.662745, 0.662745, dot_t_to_alpha(t))
			
			# delta_x is in global coordinates, so we need to convert it to local
			delta_x = delta_x.rotated(-global_rotation)
			
			# draw the dot
			draw_circle(delta_x, draw_radius, color)


func _process(delta: float):
	# redraw the circle its predicted trajectory every frame
	queue_redraw()
	
	# update game time
	game_time += delta
	
	# update the radius if frozen
	if freeze and radius != target_radius:
		radius = move_toward(radius, target_radius, MAX_RADIUS_DELTA)


# use mouse input to change the target radius
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var delta_radius = MOUSE_SENSITIVITY * event.screen_relative.y
		if delta_radius != 0:
			var r = target_radius + delta_radius
			r = clamp(r, MIN_RADIUS, MAX_RADIUS)
			target_radius = r


# move the actual radius toward the target radius
func _integrate_forces(_state):
	if radius != target_radius:
		radius = move_toward(radius, target_radius, MAX_RADIUS_DELTA)
	
	# if the parent launcher has queued a launch, then
	# launch the ball and unqueue the launch
	if launch_queued:
		linear_velocity = Vector2.ZERO
		position = Vector2.ZERO
		angular_velocity = 0
		rotation = 0
		apply_impulse(launch_impulse)
		launch_queued = false
