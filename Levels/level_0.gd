extends Node2D


func _input(event: InputEvent):
	if event.is_action_pressed("activate_launcher"):
		get_tree().call_group("Level Root", "win_level_now")
