extends RigidBody2D


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


const MOUSE_SENSITIVITY = 0.1
const MAX_RADIUS_DELTA = 5


const DEFAULT_RADIUS = 20.0
const DEFAULT_MASS = 1
const MIN_RADIUS = 10.0
const MAX_RADIUS = 50.0

# compute the ball's mass from its radius
func radius_to_mass(r):
	var scale_factor = r / DEFAULT_RADIUS
	return DEFAULT_MASS * scale_factor**3


# controls the ball's current size
var radius = DEFAULT_RADIUS:
	set(value):
		radius = value
		# update the collision shape's radius to match the ball's radius
		if is_instance_valid(collision_shape_2d):
			collision_shape_2d.shape.radius = radius
			mass = radius_to_mass(radius)

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


# redraw the circle every frame
func _process(_delta: float):
	queue_redraw()


# use mouse input to change the target radius
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var delta_radius = MOUSE_SENSITIVITY * (-event.screen_relative.y)
		if delta_radius != 0:
			var r = target_radius + delta_radius
			r = clamp(r, MIN_RADIUS, MAX_RADIUS)
			target_radius = r


# move the actual radius toward the target radius
func _integrate_forces(_state):
	#if radius != target_radius:
	radius = move_toward(radius, target_radius, MAX_RADIUS_DELTA)
