extends Node2D


@onready var sensitivity_notification_label: Label = $"Sensitivity Notification Label"
@onready var sensitivity_change_cooldown: Timer = $"Sensitivity Change Cooldown"
var sensitivity_notification_label_alpha = 0


# mouse sensitivity
# we store it here so we can change it with the arrow keys
var sensitivity = 1:
	set(value):
		sensitivity = value
		get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", sensitivity)
		var rounded_sensitivity = round(100 * sensitivity) / 100
		sensitivity_notification_label.text = "Sensitivity " + str(rounded_sensitivity) + "x"
		sensitivity_notification_label_alpha = 1.5


# get reference to timer
@onready var level_transition_timer: Timer = $"Level Transition Timer"


# load level scenes
const LEVEL_0 = preload("res://Levels/level_0.tscn")
const LEVEL_1 = preload("res://Levels/level_1.tscn")
const LEVEL_2 = preload("res://Levels/level_2.tscn")
const LEVEL_3 = preload("res://Levels/level_3.tscn")
const LEVEL_7 = preload("res://Levels/level_7.tscn")
const LEVEL_8 = preload("res://Levels/level_8.tscn")
const LEVEL_4 = preload("res://Levels/level_4.tscn")
const LEVEL_5 = preload("res://Levels/level_5.tscn")
const LEVEL_6 = preload("res://Levels/level_6.tscn")
const LEVEL_B = preload("res://Levels/level_b.tscn")
const LEVEL_B_PLUS = preload("res://Levels/level_b_plus.tscn")
const LEVEL_9_PLUS = preload("res://Levels/level_9_plus.tscn")
const LEVEL_9_PLUS_PLUS = preload("res://Levels/level_9_plus_plus.tscn")
const WIN_SCREEN = preload("res://Levels/win_screen.tscn")


# place level scenes into an array
var level_array = [
	LEVEL_0, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_7, LEVEL_8,
	LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_B, LEVEL_B_PLUS,
	LEVEL_9_PLUS, LEVEL_9_PLUS_PLUS, WIN_SCREEN
]

# initialize variable to keep track of current level in the level array
var level_index = 0


# declare variables to hold the current level and next level
var current_level: Node2D


# instantiate the first level add it to the scene
func _ready():
	current_level = level_array[level_index].instantiate()
	add_child(current_level)


# lower the sensitivity notification label alpha by 1 per second
# update sensitivity notification label alpha
func _process(delta):
	var transparent_color = Color(1,1,1,sensitivity_notification_label_alpha)
	sensitivity_notification_label.modulate = transparent_color
	sensitivity_notification_label_alpha = move_toward(
		sensitivity_notification_label_alpha, 0, delta
	)


# whenever the player beats a level, transition to the next scene
# called by the "exit" scene via the "Level Root" global group
func win_level_now():
	current_level.queue_free()
	level_index += 1
	current_level = level_array[level_index].instantiate()
	add_child(current_level)
	
	# update the sensitivity of the balls to match the sensitivity
	# set by the player, stored in this script
	get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", sensitivity)


# call above after a delay
func win_level():
	level_transition_timer.start()

func _on_level_transition_timer_timeout():
	win_level_now()


# reload the level when restart action done
func _input(event: InputEvent):
	if event.is_action_pressed("reload_level"):
		current_level.queue_free()
		current_level = level_array[level_index].instantiate()
		add_child(current_level)
		
		# update the sensitivity of the balls to match the sensitivity
		# set by the player, stored in this script
		get_tree().call_group_flags(0, "Balls", "set_mouse_sensitivity", sensitivity)
	
	if sensitivity_change_cooldown.time_left == 0:
		if event.is_action("sensitivity_up"):
			sensitivity *= 1.1
			sensitivity_change_cooldown.start()
		
		if event.is_action("sensitivity_down"):
			sensitivity /= 1.1
			sensitivity_change_cooldown.start()
