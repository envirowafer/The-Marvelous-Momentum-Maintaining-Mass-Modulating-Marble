class_name TrajectoryHint extends Node2D
## Displays dots showing the trajectory of a projectile.
## Intended for use with the ball class, but not limited to just that case.


## Number of dots displayed in the trajectory hint.
@export var number_of_dots: int = 15

## The largest radius of the dots in the trajectory hint.
@export var dot_radius: float = 5.0

## How long it takes (in seconds) for the projectile to get from one dot to the
## next.
@export_range(0, 0.2, 0.001, "suffix:sec") var dot_time_separation: float = 0.1

## Toggles whether or not the trajectory hint is drawn.
@export var enabled: bool = true


## Set by the parent. Used for computing the trajectory.
## Expected in global coordinates.
var linear_velocity: Vector2

## Set by the parent. Used for computing the trajectory.
var linear_damp: float

## Set by the parent.
## When true, the dots in the projectile hint do not move.
## When false, the dots in the projectile hint move toward the ball, so if the
## ball's velocity matches [linear_velocity], the dots will appear to be still.
var frozen: bool


# Gravity vector in global coordinates.
var _gravity_vector: Vector2 = Vector2.DOWN * ProjectSettings.get_setting("physics/2d/default_gravity")
# Default linear damping. Used for computing combined (total) linear damping.
var _default_linear_damp: float = ProjectSettings.get_setting("physics/2d/default_linear_damp")


# Time that this node has existed for while not [frozen].
var _game_time: float = 0.0


var _frozen_last_frame = frozen
func _process(delta: float):
	# redraw trajectory hint every frame
	queue_redraw()
	
	# update the game time if not frozen
	# add a 1-frame delay to make pre-launch dots line up with post-launch dots
	if not frozen:
		_game_time += delta
	
	_frozen_last_frame = frozen


func _draw():
	# draw the trajectory hint
	
	# only draw if enabled
	if not enabled:
		return
	
	# compute the combined damping
	var combined_damp = linear_damp + _default_linear_damp
	
	# draw the dots
	for n in number_of_dots:
		
		# t is the time it is projected to take for the ball to reach this dot
		#var t = (n+1) * dot_time_separation - int(not frozen) * fposmod(_game_time, dot_time_separation)
		var t = (n+1) * dot_time_separation - fposmod(_game_time, dot_time_separation)
		
		# compute delta_x, factoring in air resistance
		var a = 1 - exp(-t * combined_damp)
		var b = linear_velocity/combined_damp - _gravity_vector/(combined_damp**2)
		var c = t * _gravity_vector / combined_damp
		var delta_x = a*b + c
		
		# delta_x is in global coordinates, so we need to convert it to local
		delta_x = delta_x.rotated(-global_rotation)
		
		# compute values for dot appearance
		var draw_radius = dot_radius * (dot_time_separation+1) / (t+1)
		var color = Color(0.662745, 0.662745, 0.662745, _dot_t_to_alpha(t))
		
		# draw the dot
		draw_circle(delta_x, draw_radius, color)


# Computes the alpha of each dot
# from the time it takes for the ball to reach it.
func _dot_t_to_alpha(t: float) -> float:
	var max_dot_time = number_of_dots * dot_time_separation
	t -= dot_time_separation
	var numerator   = t * (max_dot_time - t) * (max_dot_time + 2)**2
	var denominator = (t+1) * (max_dot_time - t + 1) * (max_dot_time)**2
	return clamp(numerator/denominator, 0, 1)
