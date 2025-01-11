extends Node2D
## Main script. Handles level transitions and settings adjustments.


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
const LEVEL_10 = preload("res://Levels/level_10.tscn")
const LEVEL_11 = preload("res://Levels/level_11.tscn")
const LEVEL_12 = preload("res://Levels/level_12.tscn")
const WIN_SCREEN = preload("res://Levels/win_screen.tscn")

## Array that determines the order of the levels.
const LEVEL_ARRAY = [
	LEVEL_0, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5,
	LEVEL_6, LEVEL_7, LEVEL_8, LEVEL_9, LEVEL_10,
	LEVEL_11, LEVEL_12, WIN_SCREEN
]


## We store mouse sensitivity here so we can change it with the arrow keys.
var sensitivity: float = 1:
	set(value):
		get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", value)
		
		if sensitivity * value >= 0:
			var rounded_sensitivity = round(100 * abs(value)) / 100
			_sensitivity_notification_label.text = "Sensitivity " + str(rounded_sensitivity) + "x"
			_sensitivity_notification_label_alpha = 1.5
		
		sensitivity = value


# Keeps track of current level in the level array.
var _level_index: int = 0

# Holds the current level.
var _current_level: Node2D

@onready var _sensitivity_notification_label: Label = $"Sensitivity Notification Label"
@onready var _sensitivity_change_cooldown: Timer = $"Sensitivity Change Cooldown"
var _sensitivity_notification_label_alpha: float = 0

@onready var _level_transition_timer: Timer = $"Level Transition Timer"


func _ready():
	# instantiate the first level add it to the scene
	_current_level = LEVEL_ARRAY[_level_index].instantiate()
	add_child(_current_level)


func _process(delta):
	# lower the sensitivity notification label alpha by 1 per second
	_sensitivity_notification_label_alpha = move_toward(
		_sensitivity_notification_label_alpha, 0, delta
	)
	
	# update sensitivity notification label alpha
	var transparent_color = Color(1,1,1,_sensitivity_notification_label_alpha)
	_sensitivity_notification_label.modulate = transparent_color


func _input(event: InputEvent):
	# reload the level when restart action done
	if event.is_action_pressed("reload_level"):
		_current_level.queue_free()
		_current_level = LEVEL_ARRAY[_level_index].instantiate()
		add_child(_current_level)
		
		# update the sensitivity of the balls to match the sensitivity
		# set by the player, stored in this script
		get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", sensitivity)
	
	# adjust sensitivity
	if _sensitivity_change_cooldown.time_left == 0:
		if event.is_action("sensitivity_up"):
			sensitivity *= 1.1
			_sensitivity_change_cooldown.start()
		
		if event.is_action("sensitivity_down"):
			sensitivity /= 1.1
			_sensitivity_change_cooldown.start()
	
	# invert controls
	if event.is_action_pressed("invert controls"):
		sensitivity *= -1
	
	# reset game
	if event.is_action_pressed("reset_game"):
		get_tree().reload_current_scene()


# Move to next level when timer ends.
func _on_level_transition_timer_timeout():
	win_level_now()


## Move to the next level after a delay.
## Called by the "exit" scene via the "Level Root" global group.
func win_level():
	_level_transition_timer.start()


## Instantly move to the next level.
## Called by the "Level 0" scene via the "Level Root" global group.
func win_level_now():
	_current_level.queue_free()
	_level_index += 1
	_current_level = LEVEL_ARRAY[_level_index].instantiate()
	add_child(_current_level)
	
	# update the sensitivity of the balls to match the sensitivity
	# set by the player, stored in this script
	get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", sensitivity)
