@tool
class_name CircleRenderer extends Node2D
## Draws a solid-color circle to the screen with an adjustable radius.


## Controls the ball's current size.
@export_range(15.0, 30.0) var radius: float = 20.0

## Controls the ball's color.
@export_color_no_alpha var ball_color := Color(0.75, 0.65, 0.65)


# redraw the sprite every frame
func _process(_delta: float):
	queue_redraw()


# draw a custom sprite that scales with the radius
func _draw():
	# draw filled circle
	draw_circle(Vector2.ZERO, radius, ball_color)
