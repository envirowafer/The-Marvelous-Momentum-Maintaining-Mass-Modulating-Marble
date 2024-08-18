extends Node2D


@onready var win_label: Label = $"Win Label"


func _ready():
	remove_child(win_label)


func win_level():
	add_child(win_label)
