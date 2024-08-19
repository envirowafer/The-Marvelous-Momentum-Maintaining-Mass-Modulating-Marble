extends Area2D


@export var is_up = false
@onready var goal_sound: AudioStreamPlayer2D = $"../Goal Sound"


func _on_body_exited(body: Node2D) -> void:
	if body.name.begins_with("Ball"):
		if (not is_up and body.linear_velocity.x > 0) or (is_up and body.linear_velocity.y > 0):
			body.queue_free()
			goal_sound.play()
			get_tree().call_group("Level Root", "win_level")
