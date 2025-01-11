@tool
class_name CircleRenderer extends Node2D
## Draws a solid-color circle to the screen with an adjustable radius.


## Controls the ball's current size.
@export_range(15.0, 30.0) var radius: float = 20.0

## Controls the ball's color.
@export_color_no_alpha var ball_color := Color(0.75, 0.65, 0.65)


func _process(_delta: float):
	# redraw the sprite
	queue_redraw()


func _draw():
	# draw filled circle that scales with the radius
	draw_circle(Vector2.ZERO, radius, ball_color)
