extends AudioStreamPlayer2D
## Controls the sound of the ball rolling.


## Set by ball script. Used to compute pitch of the roll sound.
var speed: float:
	set(value):
		speed = value
		var volume = 60 * (log(speed)/log(1000) - 1.1)
		volume_db = clamp(volume, -60, 0)

## Set by ball script. Used to compute volume of the roll sound.
var min_mass: float

## Set by ball script. Used to compute volume of the roll sound.
var max_mass: float

## Set by ball script. Used to compute volume of the roll sound.
var mass: float:
	set(value):
		mass = value
		assert(min_mass > 0, "min_mass not set")
		assert(max_mass > 0, "max_mass not set")
		pitch_scale = 1 - 0.05 * ((mass - min_mass)/(max_mass - min_mass) - 0.5)


# Loop the roll sound when it is done.
func _on_finished():
	play()

# Stop the roll sound when leaving the scene tree.
func _on_tree_exiting():
	stop()
