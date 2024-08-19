extends Node2D


@onready var win_label: Label = $"Win Label"


func _ready():
	remove_child(win_label)


func _input(event: InputEvent):
	if event.is_action_pressed("reload_level"):
		get_tree().reload_current_scene()


func win_level():
	add_child(win_label)
