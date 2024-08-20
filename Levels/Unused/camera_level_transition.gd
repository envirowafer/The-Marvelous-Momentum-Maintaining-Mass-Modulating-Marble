extends Node2D


# needed data transitioning between levels
const LEVEL_WIDTH = 1920


# variables for transitioning between levels
const TOTAL_TRANSITION_TIME = 3.0
var transition_time = 0.0
var transitioning = false


# load level scenes
const LEVEL_1 = preload("res://Levels/level_1.tscn")
const LEVEL_2 = preload("res://Levels/level_2.tscn")
const WIN_SCREEN = preload("res://Levels/win_screen.tscn")

# place level scenes into an array
var level_array = [LEVEL_1, LEVEL_2, WIN_SCREEN]

# initialize variable to keep track of current level in the level array
var level_index = 0


# declare variables to hold the current level and next level
var current_level: Node2D
var next_level: Node2D


# instantiate the first level add it to the scene
func _ready():
	current_level = level_array[level_index].instantiate()
	add_child(current_level)


# function to start transitioning between levels
func begin_transition():
	# instantiate the next level and add it to the current scene
	# to the right of the current level
	next_level = level_array[level_index + 1].instantiate()
	next_level.position.x = LEVEL_WIDTH
	add_child(next_level)
	
	# disable launcher inputs
	get_tree().call_group("Launchers", "set_input_enable", false)
	
	# set transitioning flag to true
	transitioning = true


# function to stop transitioning between levels
# only call when level nodes are in the correct positions
func end_transition():
	# advance the level-tracking variables
	current_level = next_level
	level_index += 1
	
	# set the transitioning flag to false
	transitioning = false
	
	# enable launcher input
	get_tree().call_group("Launchers", "set_input_enable", true)


# if transitioning between levels, move them to the left
var transition_speed = LEVEL_WIDTH / TOTAL_TRANSITION_TIME
func _process(delta: float):
	# check if transitioning between levels
	if transitioning:
		# move the current level
		current_level.position.x = move_toward(
			current_level.position.x, -LEVEL_WIDTH, transition_speed * delta
		)
		
		# move the next level
		next_level.position.x = move_toward(
			next_level.position.x, 0, transition_speed * delta
		)
		
		# if done transitioning, then stop transitioning
		if current_level.position.x == -LEVEL_WIDTH and next_level.position.x == 0:
			end_transition()


# whenever the player beats a level, transition to the next scene
# called by the "exit" scene via the "Level Root" global group
func win_level():
	print("level won")
	begin_transition()
