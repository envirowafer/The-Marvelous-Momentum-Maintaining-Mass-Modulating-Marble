extends Node2D


# get reference to timer
@onready var timer: Timer = $Timer


# load level scenes
const LEVEL_0 = preload("res://Levels/level_0.tscn")
const LEVEL_1 = preload("res://Levels/level_1.tscn")
const LEVEL_2 = preload("res://Levels/level_2.tscn")
const LEVEL_3 = preload("res://Levels/level_3.tscn")
const LEVEL_4 = preload("res://Levels/level_4.tscn")
const LEVEL_5 = preload("res://Levels/level_5.tscn")
const LEVEL_6 = preload("res://Levels/level_6.tscn")
const LEVEL_7 = preload("res://Levels/level_7.tscn")
const LEVEL_8 = preload("res://Levels/level_8.tscn")
const LEVEL_9 = preload("res://Levels/level_9.tscn")
const LEVEL_9_PLUS = preload("res://Levels/level_9_plus.tscn")
const WIN_SCREEN = preload("res://Levels/win_screen.tscn")


# place level scenes into an array
var level_array = [
	LEVEL_0, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5,
	LEVEL_6, LEVEL_7, LEVEL_8, LEVEL_9, LEVEL_9_PLUS, WIN_SCREEN
]

# initialize variable to keep track of current level in the level array
var level_index = 0


# declare variables to hold the current level and next level
var current_level: Node2D


# instantiate the first level add it to the scene
func _ready():
	current_level = level_array[level_index].instantiate()
	add_child(current_level)


# whenever the player beats a level, transition to the next scene
# called by the "exit" scene via the "Level Root" global group
func win_level_now():
	current_level.queue_free()
	level_index += 1
	current_level = level_array[level_index].instantiate()
	add_child(current_level)


# call above after a delay
func win_level():
	timer.start()

func _on_timer_timeout():
	win_level_now()


# reload the level when restart action done
func _input(event: InputEvent):
	if event.is_action_pressed("reload_level"):
		current_level.queue_free()
		current_level = level_array[level_index].instantiate()
		add_child(current_level)
