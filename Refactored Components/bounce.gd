extends AudioStreamPlayer2D
## Controls the sound of the ball bouncing off an object.


## Set by ball script. Used to compute pitch of the bounce sound.
var min_mass: float
## Set by ball script. Used to compute pitch of the bounce sound.
var max_mass: float


## Preferred instead of calling play.
## Adjusts the pitch and volume of the bounce sound to match the speed and mass
## given as parameters.
func play_with_parameters(speed: float, mass: float):
	assert(min_mass > 0, "min_mass is not set")
	assert(max_mass > 0, "max_mass is not set")
	
	if speed < 100:
		return
	var volume = 60.0 * (log(speed)/log(1000) - 1)
	volume_db = clamp(volume, -30, 0)
	pitch_scale = 0.7 - 0.5 * ((mass - min_mass)/(max_mass - min_mass) - 0.5)
	play()
